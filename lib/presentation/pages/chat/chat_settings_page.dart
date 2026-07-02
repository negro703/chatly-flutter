import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:our_chat/domain/repositories/storage_repository.dart';
import 'package:our_chat/injection_container.dart' as di;
import 'package:our_chat/presentation/cubit/chat/chat_cubit.dart';

/// Page for customizing a chat room (name and image).
///
/// Uses Material 3 design with clean layout and proper padding.
class ChatSettingsPage extends StatefulWidget {
  const ChatSettingsPage({
    super.key,
    required this.chatId,
    this.initialRoomName,
    this.initialRoomImage,
  });

  final String chatId;
  final String? initialRoomName;
  final String? initialRoomImage;

  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roomNameController;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roomNameController = TextEditingController(
      text: widget.initialRoomName ?? '',
    );
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (pickedFile != null && mounted) {
      setState(() => _imagePath = pickedFile.path);
    }
  }

  Future<void> _saveRoomSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? roomImage;

    // Upload new room image if selected
    if (_imagePath != null) {
      final storageRepository = di.sl<StorageRepository>();
      final uploadResult = await storageRepository.uploadImage(
        filePath: _imagePath!,
        fileName:
            'room_${widget.chatId}_${DateTime.now().millisecondsSinceEpoch}',
        folder: 'room_images',
      );

      uploadResult.fold(
        (failure) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload image: ${failure.message}'),
              ),
            );
          }
          return;
        },
        (url) => roomImage = url,
      );

      if (roomImage == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    final roomName = _roomNameController.text.trim();

    // Update via ChatCubit
    final chatCubit = context.read<ChatCubit>();
    await chatCubit.updateChatRoom(
      chatId: widget.chatId,
      roomName: roomName.isNotEmpty ? roomName : null,
      roomImage: roomImage,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat room updated successfully')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Settings'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _isLoading ? null : _saveRoomSettings,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Room Image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 72,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: _imagePath != null
                            ? FileImage(File(_imagePath!))
                            : (widget.initialRoomImage != null
                                ? NetworkImage(widget.initialRoomImage!)
                                : null),
                        child: (_imagePath == null &&
                                widget.initialRoomImage == null)
                            ? Icon(
                                Icons.chat,
                                size: 72,
                                color: theme.colorScheme.onPrimaryContainer,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.surface,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 22,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Room Name
              TextFormField(
                controller: _roomNameController,
                decoration: InputDecoration(
                  labelText: 'Room Name',
                  prefixIcon: const Icon(Icons.chat_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLowest,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Room name cannot be empty';
                  }
                  if (value.trim().length < 2) {
                    return 'Room name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Info card
              Card(
                elevation: 0,
                color: theme.colorScheme.secondaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onSecondaryContainer,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Changes to the room name and image will be visible to all members.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}