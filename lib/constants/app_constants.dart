class AppConstants {
  // Colors
  static const primaryColor = 0xFF1A237E;
  static const accentColor = 0xFF635BFF;

  // Image Processing
  static const imageWidth = 256;
  static const imageHeight = 256;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Error Messages
  static const String imagePickError = 'Error picking image';
  static const String imageProcessError = 'Error processing image';
  static const String modelError = 'Error running model';
  static const String networkError = 'Network error occurred';

  // Asset Paths
  static const String modelPath = 'assets/models/model.tflite';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxLoginAttempts = 5;

  // Timeouts
  static const int defaultTimeoutSeconds = 30;
}
