import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class MessageGeneratorService {
  static const String _apiToken = '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';
  // Using a more suitable model for creative text generation
  static const String _apiUrl = 'https://api-inference.huggingface.co/models/facebook/opt-350m';

  static const List<String> _categories = [
    'flirty',
    'cheesy',
    'love',
    'dating'
  ];

  // Category intensity mappings
  static const Map<String, double> _intensityLevels = {
    'flirty': 0.95,
    'cheesy': 0.85,
    'love': 0.94,
    'dating': 0.94
  };

  // Fallback messages for each category
  static const Map<String, List<String>> _fallbackMessages = {
    'flirty': [
      "Is your name Google? Because you've got everything I've been searching for! 😉",
      "Are you a magician? Because whenever I look at you, everyone else disappears! ✨",
      "Do you have a map? I keep getting lost in your eyes! 🗺️",
      "If you were a vegetable, you'd be a cute-cumber! 🥒",
      "Are you a camera? Because every time I look at you, I smile! 📸",
      "Is your name WiFi? Because I'm really feeling a connection! 📶",
      "You must be tired because you've been running through my mind all day! 🏃‍♂️",
      "Are you a parking ticket? Because you've got FINE written all over you! 🎫"
    ],
    'cheesy': [
      "If you were a cheese, you'd be Gouda-looking! 🧀",
      "Are you French? Because Eiffel for you! 🗼",
      "You must be a keyboard, because you're just my type! ⌨️",
      "Is this the Hogwarts Express? Because platform 9 and 3/4 isn't the only thing with a nice bump here 😉",
      "Are you a campfire? Because you are hot and I want s'more! 🔥",
      "Do you like science? Because I've got my ion you! ⚗️",
      "Are you a bank loan? Because you've got my interest! 💰",
      "Is your name Ariel? Because we mermaid for each other! 🧜‍♀️"
    ],
    'love': [
      "You had me at 'Hello World'! 💻",
      "Every love story is beautiful, but ours could be my favorite! 📖",
      "You're the semicolon to my code! 😊",
      "Together, we could write the perfect love algorithm! ❤️",
      "You must be a CSS file, because you've got great style! 🎨",
      "Are you JavaScript? Because you make my world dynamic! 🌟",
      "You're like my favorite function - you always return happiness! 🎯",
      "Let's commit to a lifetime repository of love! 💕"
    ],
    'dating': [
      "Want to join me for coffee and code review? ☕",
      "How about we pair program through life together? 👩‍💻",
      "Let's debug life's problems together! 🐛",
      "Want to be the exception to my try-catch block? 🎯",
      "You've successfully bypassed my firewall to my heart! 🔒",
      "Let's merge our branches and create something beautiful! 🌳",
      "You're the perfect match to my query! 🔍",
      "Want to develop a relationship without any bugs? 🪲"
    ]
  };

  final Random _random = Random();

  String _getRandomCategory() {
    return _categories[_random.nextInt(_categories.length)];
  }

  String _getRandomFallbackMessage(String category) {
    final messages = _fallbackMessages[category] ?? _fallbackMessages['flirty']!;
    return messages[_random.nextInt(messages.length)];
  }

  String _constructPrompt(String category) {
    final intensity = _intensityLevels[category] ?? 0.9;
    final basePrompt = """
Generate a highly engaging $category message for a dating app with ${(intensity * 100).toInt()}% intensity.
Rules:
- Must be creative and chessy
- Must be flirty and intriguing
- Must encourage a response
- Must be a single message
- Must be under 35 words
- Must not include hashtags or emojis
- Must not include quotes or context
Output format: Direct message only""";
    
    return basePrompt;
  }

  Future<String> generateMessage() async {
    try {
      final category = _getRandomCategory();
      final prompt = _constructPrompt(category);

      debugPrint('Generating message for category: $category');
      debugPrint('Prompt: $prompt');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Authorization': 'Bearer $_apiToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': prompt,
          'parameters': {
            'max_new_tokens': 35,
            'temperature': _intensityLevels[category] ?? 0.9,
            'top_p': 0.95,
            'do_sample': true,
            'num_return_sequences': 1,
            'return_full_text': false,
            'repetition_penalty': 1.2,
            'stop': ['\n', '"', '"', '.', '?', '!'],
            'early_stopping': true
          }
        }),
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.isNotEmpty) {
          final String generatedText = jsonResponse[0]['generated_text'] ?? '';
          // Enhanced text cleaning
          String cleanedText = generatedText.replaceAll(prompt, '');
          cleanedText = cleanedText.replaceAll('"', '').replaceAll("'", '');
          cleanedText = cleanedText.replaceAll(RegExp(r'^[^a-zA-Z0-9]+'), '');
          cleanedText = cleanedText.replaceAll(RegExp(r'[^a-zA-Z0-9\s.,!?]+$'), '');
          cleanedText = cleanedText.trim().replaceAll(RegExp(r'\s+'), ' ');
          
          // Add appropriate punctuation if missing
          if (!cleanedText.endsWith('?') && !cleanedText.endsWith('!') && !cleanedText.endsWith('.')) {
            cleanedText += category == 'flirty' || category == 'dating' ? ' 😉' : ' ❤️';
          }
          
          if (cleanedText.isNotEmpty && cleanedText.length > 10 && cleanedText.split(' ').length <= 35) {
            return cleanedText;
          }
        }
      }

      // If API call fails or returns invalid response, use fallback
      return _getRandomFallbackMessage(category);
    } catch (e) {
      debugPrint('Error generating message: $e');
      return _getRandomFallbackMessage(_getRandomCategory());
    }
  }
} 