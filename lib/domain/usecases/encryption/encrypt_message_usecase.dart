import 'package:dartz/dartz.dart';
import 'package:our_chat/core/error/failures.dart';

/// Use case for encrypting and decrypting messages (E2EE).
///
/// Single responsibility: handle end-to-end encryption business logic.
///
/// This use case defines the contract for encryption operations.
/// The actual cryptographic implementation resides in the data layer.
class EncryptMessageUseCase {
  /// Creates a new [EncryptMessageUseCase].
  const EncryptMessageUseCase();

  /// Encrypts a plain text message for a specific recipient.
  ///
  /// Returns the encrypted string on success or [Failure] on error.
  Future<Either<Failure, String>> encrypt({
    required String plainText,
    required String recipientId,
  }) async {
    // The actual encryption will be implemented in the data layer.
    // This use case defines the business logic contract.
    // For now, it returns the text as-is (will be replaced by real E2EE).
    try {
      final encrypted = _placeholderEncrypt(plainText, recipientId);
      return right(encrypted);
    } catch (e) {
      return left(
        EncryptionFailure.encryptionFailed(),
      );
    }
  }

  /// Decrypts an encrypted message from a specific sender.
  ///
  /// Returns the decrypted plain text on success or [Failure] on error.
  Future<Either<Failure, String>> decrypt({
    required String encryptedText,
    required String senderId,
  }) async {
    // The actual decryption will be implemented in the data layer.
    try {
      final decrypted = _placeholderDecrypt(encryptedText, senderId);
      return right(decrypted);
    } catch (e) {
      return left(
        EncryptionFailure.decryptionFailed(),
      );
    }
  }

  /// Placeholder encryption (will be replaced with AES-256-GCM + ECDH).
  String _placeholderEncrypt(String plainText, String recipientId) {
    // TODO: Replace with actual E2EE implementation in data layer
    return 'encrypted:$plainText:$recipientId';
  }

  /// Placeholder decryption (will be replaced with real implementation).
  String _placeholderDecrypt(String encryptedText, String senderId) {
    // TODO: Replace with actual E2EE implementation in data layer
    if (encryptedText.startsWith('encrypted:')) {
      final parts = encryptedText.split(':');
      if (parts.length >= 3 && parts[2] == senderId) {
        return parts[1];
      }
    }
    throw Exception('Decryption failed');
  }
}