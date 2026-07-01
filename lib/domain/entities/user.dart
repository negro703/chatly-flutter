import 'package:equatable/equatable.dart';

/// Represents a user in the chat application.
class User extends Equatable {
  /// Creates a new [User] instance.
  const User({
    required this.id,
    required this.displayName,
    this.email,
    this.phoneNumber,
    this.photoUrl,
    this.status,
    this.isOnline = false,
    this.lastSeen,
    this.createdAt,
  });

  /// Unique identifier for the user.
  final String id;

  /// Email address of the user.
  final String? email;

  /// Phone number of the user.
  final String? phoneNumber;

  /// Display name shown in the chat.
  final String displayName;

  /// URL to the user's profile photo.
  final String? photoUrl;

  /// Custom status message.
  final String? status;

  /// Whether the user is currently online.
  final bool isOnline;

  /// Last time the user was seen online.
  final DateTime? lastSeen;

  /// When the user account was created.
  final DateTime? createdAt;

  /// Returns a copy of this user with the given fields replaced.
  User copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    String? status,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        email,
        phoneNumber,
        displayName,
        photoUrl,
        status,
        isOnline,
        lastSeen,
        createdAt,
      ];
}