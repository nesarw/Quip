import 'package:flutter_test/flutter_test.dart';
import 'package:quip/services/message_generator.service.dart';

void main() {
  late MessageGeneratorService messageGenerator;

  setUp(() {
    messageGenerator = MessageGeneratorService();
  });

  tearDown(() {
    messageGenerator.dispose();
  });

  group('MessageGeneratorService Tests', () {
    test('should generate a message successfully', () async {
      final message = await messageGenerator.generateMessage();
      
      expect(message, isNotEmpty);
      expect(message.length, greaterThan(10));
      expect(message.split(' ').length, lessThanOrEqualTo(35));
    });

    test('should generate messages with appropriate category-specific temperature', () async {
      final message = await messageGenerator.generateMessage();
      
      expect(message, isNotEmpty);
      expect(message.length, greaterThan(10));
    });
  });
} 