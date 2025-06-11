# Addiction Detection App

A Flutter application that uses machine learning to detect potential signs of addiction from images. The app provides a user-friendly interface for uploading and analyzing images, with secure authentication and real-time results.

## Features

- 🔒 Secure authentication with email/password and Google Sign-in
- 📸 Image capture from camera or gallery
- 🧠 ML-powered addiction detection
- 🎨 Modern and responsive UI
- ⚡ Real-time analysis results
- 🔐 User profile management
- 📱 Cross-platform support (iOS & Android)

## Getting Started

### Prerequisites

- Flutter SDK (^3.7.2)
- Dart SDK (^3.0.0)
- Firebase project setup
- TensorFlow Lite model

### Installation

1. Clone the repository:
```bash
git clone https://github.com/mahmoudmuhammediv/addiction_detection_app.git
cd addiction_detection_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a new Firebase project
   - Add your Android and iOS apps
   - Download and place the configuration files:
     - Android: `google-services.json` in `android/app/`
     - iOS: `GoogleService-Info.plist` in `ios/Runner/`

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── constants/      # App-wide constants
├── models/         # Data models and ML classifier
├── providers/         # auth providers
├── screens/        # UI screens
├── services/       # Authentication and other services
├── utils/          # Utility functions
├── widgets/        # Reusable widgets
└── main.dart       # App entry point
```

## Dependencies

- `firebase_core`: ^2.0.0
- `firebase_auth`: ^4.5.0
- `cloud_firestore`: ^4.7.0
- `google_sign_in`: ^6.3.0
- `image_picker`: ^1.1.2
- `tflite_flutter`: ^0.11.0
- `path_provider`: ^2.0.5
- `image`: ^4.5.4
- `camera`: ^0.11.1

## Security Features

- Secure authentication with Firebase
- Input validation and sanitization
- Rate limiting for login attempts
- Secure file handling
- User session management

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for authentication and backend services
- TensorFlow team for ML capabilities
