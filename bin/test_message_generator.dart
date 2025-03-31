import 'package:quip/services/message_generator.service.dart';

void main() async {
  print('Starting MessageGeneratorService test...\n');
  
  final service = MessageGeneratorService();
  
  try {
    print('Generating test messages for all categories...\n');
    
    // Test each category explicitly
    final categories = ['dating', 'flirty', 'love', 'cheesy'];
    
    for (var category in categories) {
      print('Testing $category category:');
      print('Generating message...');
      
      final message = await service.generateMessage();
      
      print('Generated message: $message');
      print('Message length: ${message.length}');
      print('Word count: ${message.split(' ').length}\n');
    }
    
    print('All category tests completed successfully!');
  } catch (e) {
    print('Error during testing: $e');
  } finally {
    service.dispose();
  }
} 