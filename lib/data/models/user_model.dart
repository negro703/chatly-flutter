import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:our_chat/domain/entities/user.dart';

/// Data model for user with JSON serialization for Firestore.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.displayName,
    super.email,
    super.phoneNumber,
    super.photoUrl,
    super.status,
    super.isOnline,
    super.lastSeen,
    super.createdAt,
  });

  /// Creates a [UserModel] from a Firestore document snapshot.
  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      displayName: json['displayName'] as String? ?? '',
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      status: json['status'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: (json['lastSeen'] as Timestamp?)?.toDate(),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Creates a [UserModel] from a [User] entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      displayName: user.displayName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoUrl,
      status: user.status,
      isOnline: user.isOnline,
      lastSeen: user.lastSeen,
      createdAt: user.createdAt,
    );
  }

  /// Converts this [UserModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (status != null) 'status': status,
      'isOnline': isOnline,
      if (lastSeen != null) 'lastSeen': lastSeen,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  /// Converts to a [User] entity.
  User toEntity() => this;
}