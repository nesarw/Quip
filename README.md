# Quip

A modern Flutter application for managing connections and social interactions.

## Features

- 🔐 Secure Google Sign-in authentication
- 👥 User profile management
- 🔄 Real-time connections
- 🎨 Beautiful and intuitive UI
- 📱 Cross-platform support (iOS & Android)
- ⚡ Fast and responsive performance

## Getting Started

### Prerequisites

- Flutter SDK (>=2.12.0 <3.0.0)
- Dart SDK
- Firebase account
- Google Cloud Platform account (for Google Sign-in)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/quip.git
```

2. Navigate to the project directory:
```bash
cd quip
```

3. Install dependencies:
```bash
flutter pub get
```

4. Configure Firebase:
   - Create a new Firebase project
   - Add your Android and iOS apps
   - Download and add the configuration files:
     - For Android: `google-services.json` in `android/app/`
     - For iOS: `GoogleService-Info.plist` in `ios/Runner/`

5. Run the app:
```bash
flutter run
```

## Dependencies

- `firebase_core`: ^3.13.0 - Firebase core functionality
- `firebase_auth`: ^5.5.2 - Firebase Authentication
- `cloud_firestore`: ^5.6.6 - Cloud Firestore database
- `google_sign_in`: ^6.1.6 - Google Sign-in integration
- `flutter_contacts`: ^1.1.7+1 - Contact management
- `shared_preferences`: ^2.2.2 - Local data storage
- `http`: ^1.1.2 - HTTP requests
- `shimmer`: ^3.0.0 - Loading effects
- `image_picker`: ^1.1.2 - Image selection
- `animated_text_kit`: ^4.2.2 - Text animations
- `flutter_native_splash`: ^2.3.6 - Splash screen
- `flutter_launcher_icons`: ^0.13.1 - App icons
- `url_launcher`: ^6.3.1 - URL handling

## Project Structure

```
lib/
├── main.dart              # App entry point
├── pages/                 # Screen pages
│   ├── login.page.dart    # Login screen
│   ├── connections.page.dart
│   └── user_profile.page.dart
├── widgets/               # Reusable widgets
│   ├── button.dart
│   ├── textLogin.dart
│   └── verticalText.dart
└── assets/               # Images and other assets
    └── images/
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who have helped this project grow

## Security

This project contains sensitive information that should not be committed to version control. Before running the project:

1. Copy `lib/config.example.dart` to `lib/config.dart`
2. Fill in your actual API keys and sensitive configuration in `lib/config.dart`
3. Never commit `lib/config.dart` to version control
4. Keep your Firebase configuration files (`google-services.json` and `GoogleService-Info.plist`) secure and never commit them to version control

### Sensitive Files to Protect
- `lib/config.dart` - Contains API keys and sensitive configuration
- `android/app/google-services.json` - Firebase configuration for Android
- `ios/Runner/GoogleService-Info.plist` - Firebase configuration for iOS
- Any keystore files (`.keystore`, `.jks`, `.p12`, `.key`)

### Environment Variables
The project uses environment variables for sensitive configuration. Make sure to:
1. Never commit actual values to version control
2. Keep a backup of your sensitive configuration
3. Share sensitive information securely with team members
