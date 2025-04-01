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
    'dating': 1.2,    // Increased for more creative dating messages
    'flirty': 1.4,    // Increased for more playful flirty messages
    'love': 1.1,      // Increased for more emotional variety
    'cheesy': 1.3     // Increased for more fun cheesy messages
  };

  // Category-specific top-p values
  static const Map<String, double> _topPValues = {
    'dating': 0.98,   // Increased for more diverse dating messages
    'flirty': 0.98,   // Increased for more diverse flirty messages
    'love': 0.97,     // Increased for more emotional variety
    'cheesy': 0.98    // Increased for more diverse cheesy messages
  };

  // Category-specific prompts
  static const Map<String, List<String>> _categoryPrompts = {
    'dating': [
      "Let's create a beautiful story together",
      "I'd love to explore the world with you",
      "Want to make unforgettable memories",
      "Let's write our own adventure"
    ],
    'flirty': [
      "Your smile lights up my world",
      "You're absolutely breathtaking",
      "I can't stop thinking about you",
      "You make my heart skip a beat"
    ],
    'love': [
      "Every moment with you is precious",
      "You're my favorite hello and hardest goodbye",
      "You make my world complete",
      "My heart belongs to you"
    ],
    'cheesy': [
      "You're sweeter than sugar",
      "You're the cheese to my macaroni",
      "You're the peanut butter to my jelly",
      "You're the sprinkles to my ice cream"
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
    final prompt = prompts[_random.nextInt(prompts.length)];
    // Add a random seed to encourage variation
    return "<|$category|><|message|>$prompt ${_random.nextInt(100)}";
  }

  bool _isValidGeneratedText(String text, String prompt, String category) {
    // Remove the prompt and any special tokens
    String cleanPrompt = prompt.replaceAll('<|$category|><|message|>', '').trim();
    String cleanText = text.replaceAll('<|$category|><|message|>', '').trim();
    
    // Remove any numbers from both prompt and text
    cleanPrompt = cleanPrompt.replaceAll(RegExp(r'\d+'), '');
    cleanText = cleanText.replaceAll(RegExp(r'\d+'), '');
    
    // Check if the generated text is too similar to the prompt
    // Only check if it's an exact match or starts with the prompt
    if (cleanText.toLowerCase() == cleanPrompt.toLowerCase() || 
        cleanText.toLowerCase().startsWith(cleanPrompt.toLowerCase())) {
      return false;
    }
    
    // Check minimum length and word count
    if (cleanText.length < 3 || cleanText.split(' ').length < 1) {
      return false;
    }
    
    return true;
  }

  Future<void> _initializeModel() async {
    if (_isModelInitialized) return;

    int retryCount = 0;
    const maxInitRetries = 3;
    const initialBackoff = Duration(seconds: 2);

    while (retryCount < maxInitRetries) {
      try {
        print('Attempting to initialize model (attempt ${retryCount + 1})');
        
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
          return;
        } else if (response.statusCode == 503) {
          print('Model is loading (attempt ${retryCount + 1})');
          // Exponential backoff with jitter
          final backoffDuration = initialBackoff * pow(2, retryCount) + 
              Duration(milliseconds: _random.nextInt(1000));
          await Future.delayed(backoffDuration);
          retryCount++;
          continue;
        } else {
          print('Model initialization failed with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Failed to initialize model: ${response.statusCode}');
        }
      } catch (e) {
        print('Error during model initialization (attempt ${retryCount + 1}): $e');
        if (retryCount < maxInitRetries - 1) {
          final backoffDuration = initialBackoff * pow(2, retryCount);
          await Future.delayed(backoffDuration);
          retryCount++;
        } else {
          throw Exception('Failed to initialize model after $maxInitRetries attempts: $e');
        }
      }
    }
  }

  Future<String> generateMessage() async {
    int retryCount = 0;
    String lastError = '';
    const initialBackoff = Duration(seconds: 2);

    while (retryCount < _maxRetries) {
      try {
        await _initializeModel();
        final category = _getRandomCategory();
        final prompt = _constructPrompt(category);
        final temperature = _temperatureValues[category] ?? 0.9;
        final topP = _topPValues[category] ?? 0.95;

        print('Generating message for category: $category (attempt ${retryCount + 1})');
        print('Using prompt: $prompt');
        print('Temperature: $temperature, Top-p: $topP');

        final response = await _client.post(
          Uri.parse(_apiUrl),
          headers: {
            'Authorization': 'Bearer $_apiToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'inputs': prompt,
            'parameters': {
              'max_length': 50,  // Increased for more complete messages
              'num_return_sequences': 1,
              'temperature': temperature,
              'top_p': topP,
              'do_sample': true,
              'repetition_penalty': 1.2,  // Increased to prevent repetition
              'length_penalty': 1.0,      // Balanced length penalty
              'early_stopping': true,
              'no_repeat_ngram_size': 2,  // Increased to prevent repetition
              'top_k': 30,                // Increased for more variety
              'num_beams': 1,
              'pad_token_id': 50256,
              'eos_token_id': 50256,
              'return_full_text': false,   // Added to get only the generated part
              'min_length': 3,             // Set minimum length to 3
              'max_new_tokens': 25,        // Increased to allow longer messages
              'seed': _random.nextInt(1000) // Added to ensure variation
            }
          }),
        ).timeout(_timeout);

        print('API Response Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final List<dynamic> jsonResponse = jsonDecode(response.body);
          if (jsonResponse.isNotEmpty) {
            String generatedText = jsonResponse[0]['generated_text'] ?? '';
            
            // Clean up the message according to the model's format
            generatedText = generatedText.replaceAll('<|message|>', '').trim();
            generatedText = generatedText.replaceAll('<|$category|>', '').trim();
            
            // Additional cleaning - remove numbers and clean up text
            generatedText = generatedText.replaceAll(RegExp(r'\d+'), ''); // Remove all numbers
            generatedText = generatedText.replaceAll(RegExp(r'^[^a-zA-Z0-9]+'), ''); // Remove leading special chars
            generatedText = generatedText.replaceAll(RegExp(r'[^a-zA-Z0-9\s.,!?]+$'), ''); // Remove trailing special chars
            generatedText = generatedText.trim().replaceAll(RegExp(r'\s+'), ' ');
            
            // Ensure the message starts with a capital letter
            if (generatedText.isNotEmpty) {
              generatedText = generatedText[0].toUpperCase() + generatedText.substring(1);
            }
            
            // Validate the generated text
            if (!_isValidGeneratedText(generatedText, prompt, category)) {
              print('Generated text is invalid or too similar to prompt, retrying...');
              retryCount++;
              continue;
            }
            
            if (!generatedText.endsWith('?') && !generatedText.endsWith('!') && !generatedText.endsWith('.')) {
              generatedText += category == 'flirty' || category == 'dating' ? ' 😉' : ' ❤️';
            }
            
            if (generatedText.isNotEmpty && generatedText.length >= 3 && generatedText.split(' ').length <= 35) {
              print('Successfully generated unique message from API: $generatedText');
              return generatedText;
            }
          }
        } else if (response.statusCode == 503) {
          print('Model is loading, waiting before retry...');
          // Exponential backoff with jitter for 503 errors
          final backoffDuration = initialBackoff * pow(2, retryCount) + 
              Duration(milliseconds: _random.nextInt(1000));
          await Future.delayed(backoffDuration);
          retryCount++;
          continue;
        } else {
          print('Error response body: ${response.body}');
          throw Exception('API returned status code: ${response.statusCode}');
        }
      } catch (e) {
        lastError = e.toString();
        print('Error generating message (attempt ${retryCount + 1}): $e');
        
        if (retryCount < _maxRetries - 1) {
          final backoffDuration = initialBackoff * pow(2, retryCount);
          await Future.delayed(backoffDuration);
          retryCount++;
        } else {
          print('All retry attempts failed. Last error: $lastError');
          return _getRandomFallbackMessage(_getRandomCategory());
        }
      }
    }

    print('Using fallback message after all retries failed');
    return _getRandomFallbackMessage(_getRandomCategory());
  }

  void dispose() {
    _client.close();
  }
} 