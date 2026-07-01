/// Centralized string constants for the application.
abstract class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

  // --- App Name ---
  static const String appName = 'Our Chat';
  static const String appTagline = 'Private & Secure Messaging';

  // --- Authentication Error (Arabic - Strict Requirement) ---
  static const String authErrorArabic = 'انتي مش منة';
  static const String authErrorTitle = 'Unauthorized Access';
  static const String authErrorMessage =
      'Invalid credentials. Please try again.';

  // --- Auth Labels ---
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String phoneNumber = 'Phone Number';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';

  // --- Onboarding ---
  static const String onboardingTitle1 = 'Private & Secure';
  static const String onboardingDesc1 =
      'Your messages are protected with end-to-end encryption.';
  static const String onboardingTitle2 = 'Rich Messaging';
  static const String onboardingDesc2 =
      'Send texts, voice notes, images, and videos seamlessly.';
  static const String onboardingTitle3 = 'Voice & Video Calls';
  static const String onboardingDesc3 =
      'Connect with crystal-clear audio and video calls.';
  static const String getStarted = 'Get Started';
  static const String next = 'Next';
  static const String skip = 'Skip';

  // --- Chat ---
  static const String searchChat = 'Search conversations';
  static const String typeMessage = 'Type a message';
  static const String send = 'Send';
  static const String recording = 'Recording...';
  static const String releaseToSend = 'Release to send';
  static const String voiceNote = 'Voice Note';
  static const String image = 'Image';
  static const String video = 'Video';
  static const String document = 'Document';
  static const String camera = 'Camera';
  static const String gallery = 'Gallery';

  // --- Calls ---
  static const String calling = 'Calling...';
  static const String ringing = 'Ringing...';
  static const String inCall = 'In Call';
  static const String endCall = 'End Call';
  static const String mute = 'Mute';
  static const String speaker = 'Speaker';
  static const String switchCamera = 'Switch Camera';

  // --- Settings ---
  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String notifications = 'Notifications';
  static const String privacy = 'Privacy';
  static const String security = 'Security';
  static const String encryptionKey = 'Encryption Key';
  static const String about = 'About';
  static const String version = 'Version';
  static const String checkForUpdates = 'Check for Updates';
  static const String updateAvailable = 'Update Available';
  static const String forceUpdateMessage =
      'A new version of the app is required. Please update to continue.';
  static const String updateNow = 'Update Now';

  // --- General ---
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String noInternet = 'No internet connection';
  static const String noMessages = 'No messages yet. Start a conversation!';
  static const String noContacts = 'No contacts found.';
}