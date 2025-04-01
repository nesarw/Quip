// This file contains sensitive configuration information
// DO NOT commit this file to version control
// Create a config.example.dart file with the same structure but without actual values

class Config {
  // API Keys
  static const String huggingFaceApiToken = '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';
  
  // Firebase Configuration
  static const Map<String, String> firebaseConfig = {
    'apiKey': 'AIzaSyAKKFbMBCG4ocbzwVIyuAgdZXFZvYQsR3k',
    'projectId': 'quip-cf207',
    'storageBucket': 'quip-cf207.firebasestorage.app',
    'messagingSenderId': '810458437553',
    'appId': '1:810458437553:ios:032d88bb96b1a377cf0f90',
  };
  
  // Add other sensitive configuration here
} 