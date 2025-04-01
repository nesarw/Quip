# quip

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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
