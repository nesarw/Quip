import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

class MessageGeneratorService {
  static const String _apiToken = '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';
  static const String _apiUrl = 'https://api-inference.huggingface.co/models/nesar2004/message-generator-gpt2';
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);

  static const List<String> _categories = [
    'dating',
    'flirty',
    'love',
    'cheesy'
  ];

  // Category-specific temperature values
  static const Map<String, double> _temperatureValues = {
    'dating': 1.1,    // Increased for more creative dating messages
    'flirty': 1.3,    // Increased for more playful flirty messages
    'love': 0.8,      // Slightly increased for more emotional variety
    'cheesy': 1.2     // Increased for more fun cheesy messages
  };

  // Category-specific top-p values
  static const Map<String, double> _topPValues = {
    'dating': 0.98,   // Increased for more diverse dating messages
    'flirty': 0.98,   // Increased for more diverse flirty messages
    'love': 0.95,     // Slightly increased for more emotional variety
    'cheesy': 0.98    // Increased for more diverse cheesy messages
  };

  // Category-specific prompts
  static const Map<String, List<String>> _categoryPrompts = {
    'dating': [
      "<|dating|><|message|>",
      "<|dating|><|message|>Let's go on an adventure together",
      "<|dating|><|message|>I'd love to get to know you better",
      "<|dating|><|message|>Want to make some memories?"
    ],
    'flirty': [
      "<|flirty|><|message|>",
      "<|flirty|><|message|>You're absolutely amazing",
      "<|flirty|><|message|>I can't stop thinking about you",
      "<|flirty|><|message|>You make my heart skip a beat"
    ],
    'love': [
      "<|love|><|message|>",
      "<|love|><|message|>Every moment with you is precious",
      "<|love|><|message|>You mean the world to me",
      "<|love|><|message|>My heart belongs to you"
    ],
    'cheesy': [
      "<|cheesy|><|message|>",
      "<|cheesy|><|message|>You're sweeter than sugar",
      "<|cheesy|><|message|>You're the cheese to my macaroni",
      "<|cheesy|><|message|>You're the peanut butter to my jelly"
    ]
  };

  // Fallback messages for each category
  static const Map<String, List<String>> _fallbackMessages = {
    'dating': [
      "Want to join me for coffee and code review? ☕",
      "How about we pair program through life together? 👩‍💻",
      "Let's debug life's problems together! 🐛",
      "Want to be the exception to my try-catch block? 🎯"
    ],
    'flirty': [
      "Is your name Google? Because you've got everything I've been searching for! 😉",
      "Are you a magician? Because whenever I look at you, everyone else disappears! ✨",
      "Do you have a map? I keep getting lost in your eyes! 🗺️",
      "If you were a vegetable, you'd be a cute-cumber! 🥒"
    ],
    'love': [
      "You had me at 'Hello World'! 💻",
      "Every love story is beautiful, but ours could be my favorite! 📖",
      "You're the semicolon to my code! 😊",
      "Together, we could write the perfect love algorithm! ❤️"
    ],
    'cheesy': [
      "If you were a cheese, you'd be Gouda-looking! 🧀",
      "Are you French? Because Eiffel for you! 🗼",
      "You must be a keyboard, because you're just my type! ⌨️",
      "Are you a campfire? Because you are hot and I want s'more! 🔥"
    ]
  };

  final Random _random = Random();
  final http.Client _client = http.Client();
  bool _isModelInitialized = false;

  String _getRandomCategory() {
    return _categories[_random.nextInt(_categories.length)];
  }

  String _getRandomFallbackMessage(String category) {
    final messages = _fallbackMessages[category] ?? _fallbackMessages['dating']!;
    return messages[_random.nextInt(messages.length)];
  }

  String _constructPrompt(String category) {
    final prompts = _categoryPrompts[category] ?? _categoryPrompts['dating']!;
    return prompts[_random.nextInt(prompts.length)];
  }

  Future<void> _initializeModel() async {
    if (_isModelInitialized) return;

    try {
      final response = await _client.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': '<|dating|><|message|>',
          'parameters': {
            'max_length': 60,
            'num_return_sequences': 1,
            'temperature': 0.9,
            'top_p': 0.95,
            'do_sample': true
          }
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        _isModelInitialized = true;
        print('Model initialized successfully');
      } else {
        print('Model initialization response: ${response.body}');
        throw Exception('Failed to initialize model: ${response.statusCode}');
      }
    } catch (e) {
      print('Error initializing model: $e');
      rethrow;
    }
  }

  Future<String> generateMessage() async {
    int retryCount = 0;
    String lastError = '';

    while (retryCount < _maxRetries) {
      try {
        await _initializeModel();
        final category = _getRandomCategory();
        final prompt = _constructPrompt(category);
        final temperature = _temperatureValues[category] ?? 0.9;
        final topP = _topPValues[category] ?? 0.95;

        print('Generating message for category: $category (attempt ${retryCount + 1})');

        final response = await _client.post(
          Uri.parse(_apiUrl),
          headers: {
            'Authorization': 'Bearer $_apiToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'inputs': prompt,
            'parameters': {
              'max_length': 60,
              'num_return_sequences': 1,
              'temperature': temperature,
              'top_p': topP,
              'do_sample': true
            }
          }),
        ).timeout(_timeout);

        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final List<dynamic> jsonResponse = jsonDecode(response.body);
          if (jsonResponse.isNotEmpty) {
            String generatedText = jsonResponse[0]['generated_text'] ?? '';
            
            // Clean up the message according to the model's format
            generatedText = generatedText.replaceAll('<|message|>', '').trim();
            generatedText = generatedText.replaceAll('<|$category|>', '').trim();
            
            // Additional cleaning
            generatedText = generatedText.replaceAll(RegExp(r'^[^a-zA-Z0-9]+'), '');
            generatedText = generatedText.replaceAll(RegExp(r'[^a-zA-Z0-9\s.,!?]+$'), '');
            generatedText = generatedText.trim().replaceAll(RegExp(r'\s+'), ' ');
            
            if (!generatedText.endsWith('?') && !generatedText.endsWith('!') && !generatedText.endsWith('.')) {
              generatedText += category == 'flirty' || category == 'dating' ? ' 😉' : ' ❤️';
            }
            
            if (generatedText.isNotEmpty && generatedText.length > 10 && generatedText.split(' ').length <= 35) {
              return generatedText;
            }
          }
        } else if (response.statusCode == 503) {
          // Model is loading, wait and retry
          await Future.delayed(Duration(seconds: 2));
          retryCount++;
          continue;
        } else {
          print('Error response body: ${response.body}');
          throw Exception('API returned status code: ${response.statusCode}');
        }
      } catch (e) {
        lastError = e.toString();
        print('Error generating message (attempt ${retryCount + 1}): $e');
        retryCount++;
        if (retryCount < _maxRetries) {
          await Future.delayed(Duration(seconds: 1));
        }
      }
    }

    // If all retries failed, use fallback message
    print('All retry attempts failed. Last error: $lastError');
    return _getRandomFallbackMessage(_getRandomCategory());
  }

  void dispose() {
    _client.close();
  }
} 