import 'package:equatable/equatable.dart';

import 'package:our_chat/domain/entities/user.dart';

/// States for the profile cubit.
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state.
final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Profile update is in progress.
final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile was updated successfully.
final class ProfileUpdated extends ProfileState {
  const ProfileUpdated({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// Profile update error occurred.
final class ProfileError extends ProfileState {
  const ProfileError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}