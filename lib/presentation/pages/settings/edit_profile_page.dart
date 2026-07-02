import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:our_chat/presentation/cubit/auth/auth_cubit.dart';
import 'package:our_chat/presentation/cubit/auth/auth_state.dart';
import 'package:our_chat/presentation/cubit/profile/profile_cubit.dart';
import 'package:our_chat/presentation/cubit/profile/profile_state.dart';

/// Page for editing the user's profile (name and photo).
///
/// Uses Material 3 design with clean layout and proper padding.
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _imagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _nameController = TextEditingController(
        text: authState.user.displayName,
      );
    } else {
      _nameController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    final userId = authState.user.id;
    final displayName = _nameController.text.trim();
    final profileCubit = context.read<ProfileCubit>();

    // Listen for the result
    profileCubit.stream
        .firstWhere((state) => state is! ProfileLoading)
        .then((state) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.of(context).pop();
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      }
    });

    if (_imagePath != null) {
      profileCubit.updateProfile(
        userId: userId,
        displayName: displayName,
        imagePath: _imagePath,
      );
    } else {
      profileCubit.updateDisplayName(
        userId: userId,
        displayName: displayName,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton(
              onPressed: _isLoading ? null : _saveProfile,
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
              // Profile Photo
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 72,
                        backgroundColor:
                            theme.colorScheme.primaryContainer,
                        backgroundImage: _imagePath != null
                            ? FileImage(File(_imagePath!))
                            : (user?.photoUrl != null
                                ? NetworkImage(user!.photoUrl!)
                                : null),
                        child: (_imagePath == null && user?.photoUrl == null)
                            ? Icon(
                                Icons.person,
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

              // Display Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerLowest,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name cannot be empty';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email (read-only)
              if (user?.email != null)
                TextFormField(
                  initialValue: user!.email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLowest,
                  ),
                  enabled: false,
                ),
            ],
          ),
        ),
      ),
    );
  }
}