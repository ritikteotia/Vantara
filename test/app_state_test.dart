import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantara/state/app_state.dart';
import 'package:vantara/models/models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the flutter_tts platform channel
  const MethodChannel channel = MethodChannel('flutter_tts');

  setUp(() {
    // Register mock implementation for tts methods
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getLanguages') {
        return ['en-US', 'hi-IN', 'as-IN', 'mni-IN'];
      }
      return 1; // Return success code
    });
  });

  group('AppState Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'metrics': '[]', // Prevents generating pre-populated mock metrics history
        'gameDifficulties': '{}',
      });
    });

    test('Initial AppState loading and values', () async {
      final appState = AppState();
      // Wait for async load from prefs to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(appState.currentLanguage, 'en-US');
      expect(appState.isOnline, true);
      expect(appState.reminders.length, 4); // Default reminders are generated
      expect(appState.gameDifficulties['memory_match'], 1);
    });

    test('Toggle Reminder changes completion status', () async {
      final appState = AppState();
      await Future.delayed(const Duration(milliseconds: 100));

      final reminderId = appState.reminders.first.id;
      final initialStatus = appState.reminders.first.isCompleted;

      await appState.toggleReminder(reminderId);

      expect(appState.reminders.first.isCompleted, !initialStatus);
    });

    test('Adaptive difficulty adjusts up after high accuracy', () async {
      final appState = AppState();
      await Future.delayed(const Duration(milliseconds: 100));

      // Make sure initial difficulty is 1 and metrics history is empty
      expect(appState.gameDifficulties['memory_match'], 1);
      expect(appState.gameMetrics.where((m) => m.gameId == 'memory_match').length, 0);

      // Add two perfect game metrics for memory_match to trigger adjustment
      final metric1 = GameMetric(
        gameId: 'memory_match',
        timestamp: DateTime.now(),
        accuracy: 0.90,
        reactionTimeMs: 2000,
        mistakes: 0,
        attempts: 1,
        completed: true,
      );
      final metric2 = GameMetric(
        gameId: 'memory_match',
        timestamp: DateTime.now(),
        accuracy: 0.95,
        reactionTimeMs: 1800,
        mistakes: 0,
        attempts: 1,
        completed: true,
      );

      await appState.addGameMetric(metric1);
      // After metric1, history length is 1 (< 2), so difficulty remains 1
      expect(appState.gameDifficulties['memory_match'], 1);

      await appState.addGameMetric(metric2);
      // After metric2, history length is 2, average accuracy is 0.925 >= 0.85, so difficulty increases to 2
      expect(appState.gameDifficulties['memory_match'], 2);
    });

    test('Adaptive difficulty adjusts down after low performance', () async {
      final appState = AppState();
      await Future.delayed(const Duration(milliseconds: 100));

      // Set difficulty to 3 initially
      appState.gameDifficulties['memory_match'] = 3;

      // Add two poor game metrics for memory_match
      final metric1 = GameMetric(
        gameId: 'memory_match',
        timestamp: DateTime.now(),
        accuracy: 0.50,
        reactionTimeMs: 8000,
        mistakes: 4,
        attempts: 2,
        completed: true,
      );
      final metric2 = GameMetric(
        gameId: 'memory_match',
        timestamp: DateTime.now(),
        accuracy: 0.55,
        reactionTimeMs: 7500,
        mistakes: 3,
        attempts: 2,
        completed: true,
      );

      await appState.addGameMetric(metric1);
      // After metric1, history length is 1, so difficulty remains 3
      expect(appState.gameDifficulties['memory_match'], 3);

      await appState.addGameMetric(metric2);
      // After metric2, average accuracy is 0.525 < 0.60, so difficulty adapts down to 2
      expect(appState.gameDifficulties['memory_match'], 2);
    });

    test('Offline mode sync buffer', () async {
      final appState = AppState();
      await Future.delayed(const Duration(milliseconds: 100));

      // Turn offline
      await appState.setOnlineStatus(false);
      expect(appState.isOnline, false);

      // Add game metric while offline
      final metric = GameMetric(
        gameId: 'memory_match',
        timestamp: DateTime.now(),
        accuracy: 1.0,
        reactionTimeMs: 1500,
        mistakes: 0,
        attempts: 1,
        completed: true,
      );
      await appState.addGameMetric(metric);

      // Metric should be in unsynced queue
      expect(appState.unsyncedMetrics.length, 1);

      // Go online
      await appState.setOnlineStatus(true);
      
      // Let sync run (sync delays 2 seconds)
      await Future.delayed(const Duration(seconds: 3));

      // Should be synced now
      expect(appState.unsyncedMetrics.isEmpty, true);
    });
  });
}
