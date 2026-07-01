/// Base application exception.
class AppException implements Exception {
  const AppException({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() =>
      'AppException: $message${code != null ? ' ($code)' : ''}';
}

/// Authentication-related exceptions.
class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

/// Exception for invalid credentials.
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException()
      : super(
          message: 'Invalid credentials provided.',
          code: 'invalid-credentials',
        );
}

/// Exception for unauthorized access.
class UnauthorizedException extends AuthException {
  const UnauthorizedException()
      : super(
          message: 'Unauthorized access detected.',
          code: 'unauthorized',
        );
}

/// Exception for user not found.
class UserNotFoundException extends AuthException {
  const UserNotFoundException()
      : super(
          message: 'User not found.',
          code: 'user-not-found',
        );
}

/// Exception for email already in use.
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException()
      : super(
          message: 'Email already in use.',
          code: 'email-already-in-use',
        );
}

/// Exception for weak password.
class WeakPasswordException extends AuthException {
  const WeakPasswordException()
      : super(
          message: 'Password is too weak.',
          code: 'weak-password',
        );
}

/// Network-related exceptions.
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});

  factory NetworkException.noInternet() => const NetworkException(
        message: 'No internet connection.',
        code: 'no-internet',
      );

  factory NetworkException.timeout() => const NetworkException(
        message: 'Connection timed out.',
        code: 'timeout',
      );
}

/// Server-related exceptions.
class ServerException extends AppException {
  const ServerException({required super.message, super.code});

  factory ServerException.internal() => const ServerException(
        message: 'Internal server error.',
        code: 'internal-server-error',
      );

  factory ServerException.badRequest() => const ServerException(
        message: 'Bad request.',
        code: 'bad-request',
      );
}

/// Encryption-related exceptions.
class EncryptionException extends AppException {
  const EncryptionException({required super.message, super.code});

  factory EncryptionException.keyGenerationFailed() =>
      const EncryptionException(
        message: 'Failed to generate encryption keys.',
        code: 'key-generation-failed',
      );

  factory EncryptionException.decryptionFailed() =>
      const EncryptionException(
        message: 'Failed to decrypt data.',
        code: 'decryption-failed',
      );

  factory EncryptionException.encryptionFailed() =>
      const EncryptionException(
        message: 'Failed to encrypt data.',
        code: 'encryption-failed',
      );
}

/// Cache/storage-related exceptions.
class CacheException extends AppException {
  const CacheException({required super.message, super.code});

  factory CacheException.notFound() => const CacheException(
        message: 'Data not found in cache.',
        code: 'cache-not-found',
      );

  factory CacheException.writeFailed() => const CacheException(
        message: 'Failed to write to cache.',
        code: 'cache-write-failed',
      );
}

/// Permission-related exceptions.
class PermissionException extends AppException {
  const PermissionException({required super.message, super.code});

  factory PermissionException.denied() => const PermissionException(
        message: 'Permission denied.',
        code: 'permission-denied',
      );

  factory PermissionException.permanentlyDenied() =>
      const PermissionException(
        message:
            'Permission permanently denied. Please enable in settings.',
        code: 'permission-permanently-denied',
      );
}

/// File/media-related exceptions.
class FileException extends AppException {
  const FileException({required super.message, super.code});

  factory FileException.tooLarge() => const FileException(
        message: 'File size exceeds the maximum allowed.',
        code: 'file-too-large',
      );

  factory FileException.unsupportedFormat() => const FileException(
        message: 'Unsupported file format.',
        code: 'unsupported-format',
      );
}

/// Call-related exceptions.
class CallException extends AppException {
  const CallException({required super.message, super.code});

  factory CallException.connectionFailed() => const CallException(
        message: 'Failed to establish call connection.',
        code: 'call-connection-failed',
      );

  factory CallException.alreadyInCall() => const CallException(
        message: 'Already in a call.',
        code: 'already-in-call',
      );
}

/// Update-related exceptions.
class UpdateException extends AppException {
  const UpdateException({required super.message, super.code});

  factory UpdateException.noUpdateAvailable() => const UpdateException(
        message: 'No update available.',
        code: 'no-update',
      );

  factory UpdateException.downloadFailed() => const UpdateException(
        message: 'Failed to download update.',
        code: 'download-failed',
      );
}