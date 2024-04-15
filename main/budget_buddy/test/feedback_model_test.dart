import 'package:budget_buddy/data/model/feedbackmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FeedbackModel Tests', () {
    test('FeedbackModel initializes with null values for optional fields', () {
      final feedback = FeedbackModel(environment: 'Production');

      expect(feedback.topic, isNull);
      expect(feedback.details, isNull);
      expect(feedback.environment, equals('Production'));
    });

    test('FeedbackModel initializes with all values provided', () {
      final feedback = FeedbackModel(
          topic: 'App Feature Request',
          details: 'Would like to see more customization options',
          environment: 'Staging');

      expect(feedback.topic, equals('App Feature Request'));
      expect(feedback.details,
          equals('Would like to see more customization options'));
      expect(feedback.environment, equals('Staging'));
    });

    test('FeedbackModel can update topic and details after initialization', () {
      final feedback = FeedbackModel(environment: 'Production');

      feedback.topic = 'Bug Report';
      feedback.details = 'There is a crash when opening the settings';

      expect(feedback.topic, equals('Bug Report'));
      expect(feedback.details,
          equals('There is a crash when opening the settings'));
    });
  });
}
