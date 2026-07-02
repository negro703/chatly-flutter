import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:our_chat/core/constants/app_colors.dart';
import 'package:our_chat/domain/repositories/storage_repository.dart';
import 'package:our_chat/presentation/cubit/chat/chat_cubit.dart';
import 'package:our_chat/presentation/cubit/chat/chat_state.dart';
import 'package:our_chat/injection_container.dart' as di;

/// Page for customizing a chat room (name and image).
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

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
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
        fileName: 'room_${widget.chatId}_${DateTime.now().millisecondsSinceEpoch}',
        folder: 'room_images',
      );

      uploadResult.fold(
        (failure) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: ${failure.message}')),
            );
          }
          return;
        },
        (url) => roomImage = url,
      );

      if (roomImage == null) return;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Settings'),
        actions: [
          TextButton(
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Room Image
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 64,
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: _imagePath != null
                          ? FileImage(File(_imagePath!))
                          : (widget.initialRoomImage != null
                              ? NetworkImage(widget.initialRoomImage!)
                              : null),
                      child: (_imagePath == null && widget.initialRoomImage == null)
                          ? const Icon(
                              Icons.chat,
                              size: 64,
                              color: AppColors.textOnPrimary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Room Name
              TextFormField(
                controller: _roomNameController,
                decoration: const InputDecoration(
                  labelText: 'Room Name',
                  prefixIcon: Icon(Icons.chat_outlined),
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

              // Info text
              Text(
                'Changes to the room name and image will be visible to all members.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}