import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:our_chat/core/constants/app_constants.dart';

/// End-to-End Encryption service using AES-256-GCM with X25519 key exchange.
///
/// This service handles:
/// - Key pair generation (X25519)
/// - Shared secret derivation (ECDH)
/// - Message encryption/decryption (AES-256-GCM)
/// - Secure key storage via flutter_secure_storage
class E2EEService {
  /// Creates a new [E2EEService] with the given [secureStorage].
  E2EEService({required this.secureStorage});

  /// Secure storage for encryption keys.
  final FlutterSecureStorage secureStorage;

  /// The X25519 key exchange algorithm.
  final _keyExchange = X25519();

  /// The AES-256-GCM cipher algorithm.
  final _cipher = AesGcm.with256bits();

  /// Generates a new X25519 key pair and stores it securely.
  ///
  /// Returns the public key as a base64-encoded string.
  Future<String> generateKeyPair() async {
    final keyPair = await _keyExchange.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();

    final keyPairData = {
      'public_key': base64Encode(publicKey.bytes),
      'private_key': base64Encode(await keyPair.extractPrivateKeyBytes()),
    };

    await secureStorage.write(
      key: AppConstants.encryptionKeyPair,
      value: jsonEncode(keyPairData),
    );

    return base64Encode(publicKey.bytes);
  }

  /// Retrieves the stored key pair, or generates a new one if none exists.
  Future<SimpleKeyPairData> _getOrCreateKeyPair() async {
    final storedData = await secureStorage.read(
      key: AppConstants.encryptionKeyPair,
    );

    if (storedData != null) {
      final keyPairData = jsonDecode(storedData) as Map<String, dynamic>;
      final privateKeyBytes = base64Decode(
        keyPairData['private_key'] as String,
      );
      final publicKeyBytes = base64Decode(
        keyPairData['public_key'] as String,
      );

      return SimpleKeyPairData(
        privateKeyBytes,
        type: KeyPairType.x25519,
        publicKey: SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519),
      );
    }

    return (await _keyExchange.newKeyPair()) as SimpleKeyPairData;
  }

  /// Derives a shared AES-256 key using ECDH with the recipient's public key.
  Future<SecretKey> _deriveSharedSecret(
    String recipientPublicKeyBase64,
  ) async {
    final ourKeyPair = await _getOrCreateKeyPair();
    final theirPublicKeyBytes = base64Decode(recipientPublicKeyBase64);

    final theirPublicKey = SimplePublicKey(
      theirPublicKeyBytes,
      type: KeyPairType.x25519,
    );

    // Derive shared secret via ECDH
    final sharedSecret = await _keyExchange.sharedSecretKey(
      keyPair: ourKeyPair,
      remotePublicKey: theirPublicKey,
    );

    // Hash the shared secret bytes to get a 256-bit AES key
    final sharedSecretBytes = await sharedSecret.extractBytes();
    final hash = Sha256();
    final hashDigest = await hash.hash(sharedSecretBytes);
    final aesKeyBytes = hashDigest.bytes;

    return SecretKey(aesKeyBytes);
  }

  /// Encrypts plain text for a specific recipient.
  ///
  /// Returns a JSON string containing base64-encoded ciphertext, nonce,
  /// and the sender's public key.
  Future<String> encrypt({
    required String plainText,
    required String recipientPublicKeyBase64,
  }) async {
    final ourKeyPair = await _getOrCreateKeyPair();
    final ourPublicKey = await ourKeyPair.extractPublicKey();

    final aesKey = await _deriveSharedSecret(recipientPublicKeyBase64);

    // Generate a random 12-byte nonce (IV) for GCM
    final nonce = List<int>.generate(12, (_) => Random.secure().nextInt(256));

    // Encrypt the plaintext
    final secretBox = await _cipher.encrypt(
      utf8.encode(plainText),
      secretKey: aesKey,
      nonce: nonce,
    );

    final encryptedPayload = {
      'ciphertext': base64Encode(secretBox.cipherText),
      'nonce': base64Encode(secretBox.nonce),
      'mac': base64Encode(secretBox.mac.bytes),
      'sender_public_key': base64Encode(ourPublicKey.bytes),
    };

    return jsonEncode(encryptedPayload);
  }

  /// Decrypts an encrypted message from a specific sender.
  Future<String> decrypt({
    required String encryptedPayload,
    required String senderPublicKeyBase64,
  }) async {
    final payload = jsonDecode(encryptedPayload) as Map<String, dynamic>;

    final ciphertext = base64Decode(payload['ciphertext'] as String);
    final nonce = base64Decode(payload['nonce'] as String);
    final mac = base64Decode(payload['mac'] as String);

    // Derive the shared AES key using the sender's public key
    final aesKey = await _deriveSharedSecret(senderPublicKeyBase64);

    // Decrypt
    final secretBox = SecretBox(
      ciphertext,
      nonce: nonce,
      mac: Mac(mac),
    );

    final plaintextBytes = await _cipher.decrypt(
      secretBox,
      secretKey: aesKey,
    );

    return utf8.decode(plaintextBytes);
  }

  /// Retrieves the user's public key from secure storage.
  Future<String?> getPublicKey() async {
    final storedData = await secureStorage.read(
      key: AppConstants.encryptionKeyPair,
    );

    if (storedData == null) return null;

    final keyPairData = jsonDecode(storedData) as Map<String, dynamic>;
    return keyPairData['public_key'] as String?;
  }

  /// Stores a recipient's public key for future use.
  Future<void> storeRecipientPublicKey({
    required String userId,
    required String publicKeyBase64,
  }) async {
    await secureStorage.write(
      key: 'recipient_key_$userId',
      value: publicKeyBase64,
    );
  }

  /// Retrieves a recipient's stored public key.
  Future<String?> getRecipientPublicKey(String userId) async {
    return secureStorage.read(key: 'recipient_key_$userId');
  }
}