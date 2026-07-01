/// Application-wide constants for configuration and behavior.
abstract class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // --- App Info ---
  static const String appName = 'Our Chat';

  // --- Encryption ---
  static const int aesKeySize = 32; // 256-bit
  static const int ivSize = 12; // 96-bit for GCM
  static const int saltLength = 32;
  static const int pbkdf2Iterations = 100000;
  static const String ecdhCurve = 'X25519';

  // --- Chat Limits ---
  static const int maxMessageLength = 5000;
  static const int maxVoiceNoteDurationSeconds = 300; // 5 minutes
  static const int maxFileSizeMB = 100;
  static const int maxImageSizeMB = 25;
  static const int maxVideoSizeMB = 100;

  // --- Pagination ---
  static const int messagesPageSize = 30;
  static const int contactsPageSize = 20;

  // --- Rate Limiting ---
  static const int maxLoginAttempts = 5;
  static const Duration loginCooldown = Duration(minutes: 15);

  // --- Timeouts ---
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration callTimeout = Duration(seconds: 45);
  static const Duration typingTimeout = Duration(seconds: 2);

  // --- Storage Keys ---
  static const String encryptionKeyPair = 'encryption_key_pair';
  static const String authTokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String lastVersionKey = 'last_app_version';

  // --- OTA / Update ---
  static const String remoteConfigForceUpdateKey = 'force_update_version';
  static const String remoteConfigLatestVersionKey = 'latest_version';
  static const String remoteConfigUpdateUrlKey = 'update_url';

  // --- Firebase Collections ---
  static const String usersCollection = 'users';
  static const String messagesCollection = 'messages';
  static const String chatsCollection = 'chats';
  static const String callsCollection = 'calls';
  static const String voiceNotesCollection = 'voice_notes';
  static const String mediaCollection = 'media';
}