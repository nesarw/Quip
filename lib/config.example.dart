// This is an example configuration file
// Copy this file to config.dart and fill in your actual values
// DO NOT commit the actual config.dart file to version control

class Config {
  // API Keys
  static const String huggingFaceApiToken = 'YOUR_HUGGING_FACE_API_TOKEN';
  
  // Firebase Configuration
  static const Map<String, String> firebaseConfig = {
    'apiKey': 'YOUR_FIREBASE_API_KEY',
    'projectId': 'YOUR_FIREBASE_PROJECT_ID',
    'storageBucket': 'YOUR_FIREBASE_STORAGE_BUCKET',
    'messagingSenderId': 'YOUR_FIREBASE_MESSAGING_SENDER_ID',
    'appId': 'YOUR_FIREBASE_APP_ID',
  };
  
  // Add other sensitive configuration here
} 