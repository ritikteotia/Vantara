import 'package:flutter_test/flutter_test.dart';
import 'package:vantara/models/models.dart';
import 'package:vantara/services/adaptive_engine.dart';
import 'package:vantara/services/ai_service.dart';

void main() {
  group('AdaptiveGameEngine Tests', () {
    final engine = AdaptiveGameEngine();

    test('Initial evaluation with single history returns maintain', () {
      final metric = GameMetric(
        gameId: 'memory_match',
        timestamp: DateTime.now(),
        accuracy: 0.90,
        reactionTimeMs: 2000,
        mistakes: 0,
        attempts: 1,
        completed: true,
      );

      final result = engine.evaluateDifficulty(
        gameId: 'memory_match',
        currentDifficulty: 1,
        history: [metric],
      );

      expect(result.trend, DifficultyTrend.maintain);
      expect(result.newDifficulty, 1);
    });

    test('Two high accuracy sessions trigger difficulty increase', () {
      final m1 = GameMetric(
        gameId: 'memory_match',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        accuracy: 0.90,
        reactionTimeMs: 1800,
        mistakes: 0,
        attempts: 1,
        completed: true,
      );
      final m2 = GameMetric(
        gameId: 'memory_match',
        timestamp: DateTime.now(),
        accuracy: 0.95,
        reactionTimeMs: 1600,
        mistakes: 0,
        attempts: 1,
        completed: true,
      );

      final result = engine.evaluateDifficulty(
        gameId: 'memory_match',
        currentDifficulty: 1,
        history: [m1, m2],
      );

      expect(result.trend, DifficultyTrend.increase);
      expect(result.newDifficulty, 2);
    });

    test('Low accuracy triggers difficulty decrease', () {
      final m1 = GameMetric(
        gameId: 'sequence_recall',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        accuracy: 0.40,
        reactionTimeMs: 7000,
        mistakes: 4,
        attempts: 2,
        completed: true,
      );
      final m2 = GameMetric(
        gameId: 'sequence_recall',
        timestamp: DateTime.now(),
        accuracy: 0.50,
        reactionTimeMs: 6500,
        mistakes: 3,
        attempts: 2,
        completed: true,
      );

      final result = engine.evaluateDifficulty(
        gameId: 'sequence_recall',
        currentDifficulty: 3,
        history: [m1, m2],
      );

      expect(result.trend, DifficultyTrend.decrease);
      expect(result.newDifficulty, 2);
    });

    test('Recommend untrained game first', () {
      final m1 = GameMetric(
        gameId: 'memory_match',
        timestamp: DateTime.now(),
        accuracy: 0.90,
        reactionTimeMs: 2000,
        mistakes: 0,
        attempts: 1,
        completed: true,
      );

      final rec = engine.recommendNextGame(
        history: [m1],
        difficulties: {'memory_match': 1, 'sequence_recall': 1},
      );

      expect(rec.gameId, isNot('memory_match'));
    });
  });

  group('VantaraAiService Tests', () {
    final ai = VantaraAiService();

    test('Detect memory game intent', () {
      expect(ai.detectIntent('I want to play memory match'), UserIntent.startMemoryGame);
      expect(ai.detectIntent('मुझे मेमोरी गेम खेलना है'), UserIntent.startMemoryGame);
    });

    test('Detect reminder intent', () {
      expect(ai.detectIntent('what is my next medicine reminder?'), UserIntent.checkReminders);
      expect(ai.detectIntent('दवाई का समय कब है?'), UserIntent.checkReminders);
    });

    test('Generate assistant response for daily plan', () async {
      final context = PatientContext(
        userName: 'Amma',
        language: 'en-US',
        activeReminders: [
          Reminder(
            id: 'r1',
            title: 'Water',
            type: ReminderType.hydration,
            time: '11:00 AM',
            speechPrompt: 'Drink water',
          ),
        ],
        gameDifficulties: {'memory_match': 1},
        averageAccuracy: 0.85,
      );

      final res = await ai.generateResponse(
        userPrompt: "What is my plan for today?",
        context: context,
      );

      expect(res.detectedIntent, UserIntent.dailyPlan);
      expect(res.spokenText.isNotEmpty, true);
    });
  });
}
