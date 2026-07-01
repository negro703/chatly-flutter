import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

/// Base failure class for use with Either type from dartz.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Authentication failures.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid credentials provided.',
        code: 'invalid-credentials',
      );

  factory AuthFailure.unauthorized() => const AuthFailure(
        message: 'Unauthorized access detected.',
        code: 'unauthorized',
      );

  factory AuthFailure.userNotFound() => const AuthFailure(
        message: 'User not found.',
        code: 'user-not-found',
      );

  factory AuthFailure.emailAlreadyInUse() => const AuthFailure(
        message: 'Email already in use.',
        code: 'email-already-in-use',
      );

  factory AuthFailure.weakPassword() => const AuthFailure(
        message: 'Password is too weak.',
        code: 'weak-password',
      );

  factory AuthFailure.serverError() => const AuthFailure(
        message: 'Authentication server error.',
        code: 'server-error',
      );
}

/// Network failures.
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});

  factory NetworkFailure.noInternet() => const NetworkFailure(
        message: 'No internet connection.',
        code: 'no-internet',
      );

  factory NetworkFailure.timeout() => const NetworkFailure(
        message: 'Connection timed out.',
        code: 'timeout',
      );
}

/// Server failures.
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});

  factory ServerFailure.internal() => const ServerFailure(
        message: 'Internal server error.',
        code: 'internal-server-error',
      );

  factory ServerFailure.badRequest() => const ServerFailure(
        message: 'Bad request.',
        code: 'bad-request',
      );
}

/// Encryption failures.
class EncryptionFailure extends Failure {
  const EncryptionFailure({required super.message, super.code});

  factory EncryptionFailure.keyGenerationFailed() => const EncryptionFailure(
        message: 'Failed to generate encryption keys.',
        code: 'key-generation-failed',
      );

  factory EncryptionFailure.decryptionFailed() => const EncryptionFailure(
        message: 'Failed to decrypt data.',
        code: 'decryption-failed',
      );

  factory EncryptionFailure.encryptionFailed() => const EncryptionFailure(
        message: 'Failed to encrypt data.',
        code: 'encryption-failed',
      );
}

/// Cache failures.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});

  factory CacheFailure.notFound() => const CacheFailure(
        message: 'Data not found in cache.',
        code: 'cache-not-found',
      );

  factory CacheFailure.writeFailed() => const CacheFailure(
        message: 'Failed to write to cache.',
        code: 'cache-write-failed',
      );
}

/// Permission failures.
class PermissionFailure extends Failure {
  const PermissionFailure({required super.message, super.code});

  factory PermissionFailure.denied() => const PermissionFailure(
        message: 'Permission denied.',
        code: 'permission-denied',
      );
}

/// File failures.
class FileFailure extends Failure {
  const FileFailure({required super.message, super.code});

  factory FileFailure.tooLarge() => const FileFailure(
        message: 'File size exceeds the maximum allowed.',
        code: 'file-too-large',
      );

  factory FileFailure.unsupportedFormat() => const FileFailure(
        message: 'Unsupported file format.',
        code: 'unsupported-format',
      );
}

/// Call failures.
class CallFailure extends Failure {
  const CallFailure({required super.message, super.code});

  factory CallFailure.connectionFailed() => const CallFailure(
        message: 'Failed to establish call connection.',
        code: 'call-connection-failed',
      );
}

/// Update failures.
class UpdateFailure extends Failure {
  const UpdateFailure({required super.message, super.code});

  factory UpdateFailure.noUpdateAvailable() => const UpdateFailure(
        message: 'No update available.',
        code: 'no-update',
      );
}

/// Type alias for Either with Failure.
typedef Result<T> = Either<Failure, T>;