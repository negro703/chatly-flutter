import 'package:equatable/equatable.dart';

import 'package:our_chat/domain/entities/user.dart';

/// States for the authentication cubit.
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any authentication attempt.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Authentication is in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication error occurred.
final class AuthError extends AuthState {
  const AuthError({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}