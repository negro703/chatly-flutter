import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/core/constants/app_dimensions.dart';
import 'package:our_chat/core/constants/app_strings.dart';
import 'package:our_chat/presentation/cubit/auth/auth_cubit.dart';
import 'package:our_chat/presentation/cubit/auth/auth_state.dart';
import 'package:our_chat/presentation/cubit/chat/chat_cubit.dart';
import 'package:our_chat/domain/entities/message.dart';
import 'package:our_chat/presentation/cubit/chat/chat_state.dart';

class ChatRoomPage extends StatefulWidget {
  final String? receiverId;
  final String? receiverName;

  const ChatRoomPage({
    super.key,
    this.receiverId,
    this.receiverName,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  String? _currentUserId;
  bool _isRecording = false;
  String? _currentRecordingPath;
  int? _recordingDuration;
  Timer? _recordingTimer;
  Timer? _typingDebounce;
  bool _isTyping = false;
  String? _chatId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeChat();
    });
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _recordingTimer?.cancel();
    _typingDebounce?.cancel();
    // Close streams when leaving the chat room
    context.read<ChatCubit>().closeStreams();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      setState(() {
        _currentUserId = authState.user.id;
      });

      final chatId = widget.receiverId != null
          ? _generateChatId(authState.user.id, widget.receiverId!)
          : 'room1';

      _chatId = chatId;

      context.read<ChatCubit>().loadMessages(chatId: chatId);

      // Start typing indicator stream
      context.read<ChatCubit>().startTypingStream(chatId);

      // Start online status stream for the receiver
      if (widget.receiverId != null) {
        context.read<ChatCubit>().startOnlineStatusStream(widget.receiverId!);
      }
    }
  }

  String _generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  void _onTextChanged() {
    if (_chatId == null || _currentUserId == null) return;

    final hasText = _messageController.text.trim().isNotEmpty;

    // Debounce typing indicator updates
    _typingDebounce?.cancel();
    if (hasText != _isTyping) {
      _isTyping = hasText;
      context.read<ChatCubit>().updateTypingIndicator(
        chatId: _chatId!,
        userId: _currentUserId!,
        isTyping: hasText,
      );
    }

    // Auto-stop typing after 2 seconds of no input
    if (hasText) {
      _typingDebounce = Timer(const Duration(seconds: 2), () {
        if (_isTyping) {
          _isTyping = false;
          context.read<ChatCubit>().updateTypingIndicator(
            chatId: _chatId!,
            userId: _currentUserId!,
            isTyping: false,
          );
        }
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _currentUserId == null || _chatId == null) return;

    // Stop typing indicator
    _isTyping = false;
    context.read<ChatCubit>().updateTypingIndicator(
      chatId: _chatId!,
      userId: _currentUserId!,
      isTyping: false,
    );

    context.read<ChatCubit>().sendMessage(
      chatId: _chatId!,
      senderId: _currentUserId!,
      text: text,
    );
    _messageController.clear();
  }

  Future<void> _pickAndSendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image == null || _currentUserId == null || _chatId == null) return;

      final fileName = const Uuid().v4() + '.jpg';

      context.read<ChatCubit>().sendMediaMessage(
        chatId: _chatId!,
        senderId: _currentUserId!,
        filePath: image.path,
        fileName: fileName,
        mediaType: 'image',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/voice_${const Uuid().v4()}.m4a';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath,
        );

        setState(() {
          _isRecording = true;
          _currentRecordingPath = filePath;
          _recordingDuration = 0;
        });

        _startRecordingTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      _recordingTimer?.cancel();

      setState(() {
        _isRecording = false;
        _currentRecordingPath = path;
      });

      if (path != null && _currentUserId != null && _chatId != null) {
        final fileName = 'voice_${const Uuid().v4()}.m4a';

        context.read<ChatCubit>().sendVoiceNote(
          chatId: _chatId!,
          senderId: _currentUserId!,
          filePath: path,
          fileName: fileName,
          durationSeconds: _recordingDuration ?? 0,
        );
      }

      setState(() {
        _currentRecordingPath = null;
        _recordingDuration = null;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to stop recording: $e')),
        );
      }
      setState(() {
        _isRecording = false;
        _currentRecordingPath = null;
        _recordingDuration = null;
      });
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingDuration = (_recordingDuration ?? 0) + 1;
        });
      }
    });
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.stop();
      _recordingTimer?.cancel();

      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        _isRecording = false;
        _currentRecordingPath = null;
        _recordingDuration = null;
      });
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName ?? 'Chat Room'),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoaded && state.receiverIsOnline) {
                  return const Text(
                    'Online',
                    style: TextStyle(fontSize: 12, color: AppColors.success),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () => Navigator.pushNamed(context, '/call/voice'),
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => Navigator.pushNamed(context, '/call/video'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChatError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: 16),
                        Text(state.message),
                      ],
                    ),
                  );
                }
                if (state is ChatLoaded) {
                  // Messages are sorted ascending (oldest first).
                  // With reverse: true, the list starts from the bottom
                  // so newest messages appear at the bottom.
                  final activeMessages = state.messages;

                  if (activeMessages.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noMessages,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  // Auto-scroll to bottom when new messages arrive
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients &&
                        _scrollController.position.pixels < 100) {
                      _scrollToBottom();
                    }
                  });

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppDimensions.paddingM),
                          reverse: true,
                          itemCount: activeMessages.length,
                          itemBuilder: (context, index) {
                            // With reverse: true, index 0 is the last item
                            // (newest message at bottom)
                            final message = activeMessages[
                                activeMessages.length - 1 - index];
                            final isMe =
                                message.senderId == _currentUserId;
                            return GestureDetector(
                              onLongPress: () =>
                                  _deleteMessage(message.id),
                              child: _buildMessageBubble(message, isMe),
                            );
                          },
                        ),
                      ),
                      // Typing indicator
                      if (state.typingStatus != null &&
                          state.typingStatus!.isNotEmpty)
                        _buildTypingIndicator(state.typingStatus!),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(Map<String, dynamic> typingStatus) {
    // Find who is typing (excluding the current user)
    final typingUsers = typingStatus.entries
        .where((e) => e.key != _currentUserId && e.value == true)
        .toList();

    if (typingUsers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${widget.receiverName ?? 'Someone'} is typing...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final timeFormat = DateFormat('hh:mm a');
    final formattedTime = timeFormat.format(message.timestamp);

    // Handle deleted messages
    if (message.isDeleted) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'This message was deleted',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.bubbleSent : AppColors.bubbleReceived,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image media
            if (message.mediaType == 'image' && message.mediaUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    message.mediaUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 200,
                        height: 200,
                        color: AppColors.divider,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 200,
                        color: AppColors.divider,
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  ),
                ),
              ),

            // Voice note
            if (message.voiceNoteUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mic,
                      size: 20,
                      color: isMe
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Voice Note ${message.voiceNoteDuration != null ? '(${message.voiceNoteDuration}s)' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        Icons.play_arrow,
                        size: 20,
                        color: isMe
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                      ),
                      onPressed: () => _playVoiceNote(message.voiceNoteUrl!),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            // Text content
            if ((message.encryptedText ?? '').isNotEmpty ||
                (message.text ?? '').isNotEmpty)
              Text(
                message.encryptedText ?? message.text ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

            const SizedBox(height: 4),

            // Edited indicator + timestamp
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (message.isEdited)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      'edited',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Text(
                  formattedTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead
                        ? AppColors.accent
                        : AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playVoiceNote(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to play voice note: $e')),
        );
      }
    }
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
        vertical: AppDimensions.paddingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _isRecording
            ? _buildRecordingBar()
            : Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    color: AppColors.textSecondary,
                    onPressed: _pickAndSendImage,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: AppStrings.typeMessage,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.divider,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      _isRecording ? Icons.stop : Icons.mic,
                      color: _isRecording
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                    onPressed:
                        _isRecording ? _stopRecording : _startRecording,
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.accent,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: AppColors.textOnPrimary,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Message'),
          content:
              const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        context.read<ChatCubit>().deleteMessage(messageId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message deleted')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: $e')),
        );
      }
    }
  }

  Widget _buildRecordingBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.cancel, color: AppColors.error),
          onPressed: _cancelRecording,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recording...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                '${_recordingDuration ?? 0}s',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.stop, color: AppColors.accent),
          onPressed: _stopRecording,
        ),
      ],
    );
  }
}