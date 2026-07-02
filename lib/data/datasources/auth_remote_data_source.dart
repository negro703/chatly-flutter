import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:our_chat/core/error/exceptions.dart';
import 'package:our_chat/data/models/user_model.dart';

/// Remote data source for authentication via Firebase.
class AuthRemoteDataSource {
  /// Creates a new [AuthRemoteDataSource] with the given Firebase instances.
  AuthRemoteDataSource({
    required auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  /// Logs in with email and password via Firebase Auth.
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw const InvalidCredentialsException();
      }

      // Fetch the user profile from Firestore
      final userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!, userDoc.id);
      }

      // Create a basic user model if no Firestore doc exists
      return UserModel(
        id: user.uid,
        displayName: user.displayName ?? email.split('@').first,
        email: user.email,
        photoUrl: user.photoURL,
      );
    } on auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Logs in with phone number and password.
  Future<UserModel> loginWithPhone({
    required String phoneNumber,
    required String password,
  }) async {
    final syntheticEmail = '$phoneNumber@phone.ourchat.app';
    return loginWithEmail(email: syntheticEmail, password: password);
  }

  /// Registers a new user with email and password.
  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user == null) {
        throw ServerException.internal();
      }

      // Update the display name
      await user.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel(
        id: user.uid,
        displayName: displayName,
        email: user.email,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    } on auth.FirebaseAuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Returns the currently authenticated user's ID, or null.
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  /// Fetches a user profile by ID from Firestore.
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromJson(userDoc.data()!, userDoc.id);
      }
      return null;
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Updates the user's profile in Firestore and Firebase Auth.
  ///
  /// [photoUrl] is the download URL after uploading to Firebase Storage.
  Future<UserModel> updateProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (displayName != null) {
        updateData['displayName'] = displayName;
        // Also update Firebase Auth display name
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          await user.updateDisplayName(displayName);
        }
      }
      if (photoUrl != null) {
        updateData['photoUrl'] = photoUrl;
      }

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update(updateData);
      }

      // Return the updated user
      final updatedUser = await getUserById(userId);
      return updatedUser!;
    } catch (e) {
      throw ServerException.internal();
    }
  }

  /// Maps Firebase Auth exceptions to our typed exceptions.
  AuthException _mapAuthException(auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundException();
      case 'wrong-password':
        return const InvalidCredentialsException();
      case 'invalid-credential':
        return const InvalidCredentialsException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'user-disabled':
        return const UnauthorizedException();
      case 'too-many-requests':
        return AuthException(
          message: 'Too many login attempts. Please try again later.',
          code: 'too-many-requests',
        );
      default:
        return AuthException(
          message: e.message ?? 'An authentication error occurred.',
          code: e.code,
        );
    }
  }
}