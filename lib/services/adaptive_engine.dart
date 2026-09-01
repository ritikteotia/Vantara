import '../models/models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
///  ADAPTIVE COGNITIVE GAMING ENGINE (AI / Heuristic Layer)
/// ─────────────────────────────────────────────────────────────────────────────
///
/// NOTE FOR AI DEVELOPER:
/// This class handles all cognitive performance tracking, adaptive difficulty
/// adjustments, and game recommendation algorithms for dementia patients.
///
/// You can replace or enhance the heuristics in this file with:
/// 1. Bayesian Knowledge Tracing (BKT) or Item Response Theory (IRT)
/// 2. Reinforcement Learning / Multi-Armed Bandit recommendation
/// 3. Deep Learning / ONNX / TFLite models running locally or via API
/// ─────────────────────────────────────────────────────────────────────────────

enum DifficultyTrend {
  increase,
  decrease,
  maintain,
}

class AdaptiveDifficultyResult {
  final int newDifficulty;
  final DifficultyTrend trend;
  final String reasoning;
  final double performanceScore;

  const AdaptiveDifficultyResult({
    required this.newDifficulty,
    required this.trend,
    required this.reasoning,
    required this.performanceScore,
  });
}

class GameRecommendation {
  final String gameId;
  final String reason;
  final String targetedDomain; // e.g. "Visual Recall", "Short-term Memory"
  final int recommendedDifficulty;

  const GameRecommendation({
    required this.gameId,
    required this.reason,
    required this.targetedDomain,
    required this.recommendedDifficulty,
  });
}

class AdaptiveGameEngine {
  static final AdaptiveGameEngine _instance = AdaptiveGameEngine._internal();
  factory AdaptiveGameEngine() => _instance;
  AdaptiveGameEngine._internal();

  /// Minimum and maximum game levels supported
  static const int minDifficulty = 1;
  static const int maxDifficulty = 5;

  /// Supported cognitive games
  static const List<String> availableGames = [
    'memory_match',
    'sequence_recall',
    'what_changed',
    'object_recognition',
    'routine_recall',
  ];

  static const Map<String, String> gameDomains = {
    'memory_match': 'Short-term Visual Memory',
    'sequence_recall': 'Working Memory & Attention',
    'what_changed': 'Visual Search & Recall',
    'object_recognition': 'Semantic & Object Memory',
    'routine_recall': 'Orientation to Daily Life',
  };

  /// ─────────────────────────────────────────────────────────────────────────
  /// 1. ADAPTIVE DIFFICULTY CALCULATION
  /// ─────────────────────────────────────────────────────────────────────────
  /// Evaluates player's recent game performance history to compute the next
  /// appropriate difficulty level.
  AdaptiveDifficultyResult evaluateDifficulty({
    required String gameId,
    required int currentDifficulty,
    required List<GameMetric> history,
  }) {
    // Filter history for this specific game
    final gameRuns = history.where((m) => m.gameId == gameId).toList();

    if (gameRuns.isEmpty) {
      return AdaptiveDifficultyResult(
        newDifficulty: currentDifficulty,
        trend: DifficultyTrend.maintain,
        reasoning: 'Baseline session completed.',
        performanceScore: 0.5,
      );
    }

    // Need at least 2 sessions to adapt difficulty
    if (gameRuns.length < 2) {
      final latest = gameRuns.last;
      return AdaptiveDifficultyResult(
        newDifficulty: currentDifficulty,
        trend: DifficultyTrend.maintain,
        reasoning: 'First baseline recorded (Accuracy: ${(latest.accuracy * 100).toInt()}%).',
        performanceScore: latest.accuracy,
      );
    }

    // Get last 2 game sessions
    final recent = gameRuns.sublist(gameRuns.length - 2);
    final double avgAccuracy =
        recent.map((m) => m.accuracy).reduce((a, b) => a + b) / 2.0;
    final double avgMistakes =
        recent.map((m) => m.mistakes.toDouble()).reduce((a, b) => a + b) / 2.0;
    final double avgSpeedSeconds =
        recent.map((m) => m.reactionTimeMs / 1000.0).reduce((a, b) => a + b) / 2.0;

    // Composite Performance Index (CPI): 70% Accuracy, 30% Speed/Mistakes penalty
    final double speedFactor = (10.0 - avgSpeedSeconds.clamp(1.0, 10.0)) / 10.0;
    final double compositeScore = (avgAccuracy * 0.75) + (speedFactor * 0.25);

    // Adaptation thresholds
    if (avgAccuracy >= 0.85 && currentDifficulty < maxDifficulty) {
      return AdaptiveDifficultyResult(
        newDifficulty: currentDifficulty + 1,
        trend: DifficultyTrend.increase,
        reasoning: 'High accuracy (${(avgAccuracy * 100).toInt()}%) achieved across recent sessions.',
        performanceScore: compositeScore,
      );
    } else if ((avgAccuracy < 0.60 || avgMistakes > 2.0) && currentDifficulty > minDifficulty) {
      return AdaptiveDifficultyResult(
        newDifficulty: currentDifficulty - 1,
        trend: DifficultyTrend.decrease,
        reasoning: 'Assistance needed (Accuracy: ${(avgAccuracy * 100).toInt()}%, Mistakes: ${avgMistakes.toStringAsFixed(1)}).',
        performanceScore: compositeScore,
      );
    } else {
      return AdaptiveDifficultyResult(
        newDifficulty: currentDifficulty,
        trend: DifficultyTrend.maintain,
        reasoning: 'Stable cognitive performance at level $currentDifficulty.',
        performanceScore: compositeScore,
      );
    }
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// 2. NEXT GAME RECOMMENDATION
  /// ─────────────────────────────────────────────────────────────────────────
  /// Recommends which cognitive domain / game the elder should play next.
  /// Prioritizes cognitive domains that haven't been trained recently or where
  /// the user's performance is lowest.
  GameRecommendation recommendNextGame({
    required List<GameMetric> history,
    required Map<String, int> difficulties,
  }) {
    if (history.isEmpty) {
      return GameRecommendation(
        gameId: 'memory_match',
        reason: 'Recommended starter activity to assess visual recall.',
        targetedDomain: gameDomains['memory_match']!,
        recommendedDifficulty: difficulties['memory_match'] ?? 1,
      );
    }

    // Find the game with lowest average accuracy or lowest level
    String lowestGameId = availableGames.first;
    double lowestScore = 1.0;

    for (final gameId in availableGames) {
      final runs = history.where((m) => m.gameId == gameId).toList();
      if (runs.isEmpty) {
        // Untrained game gets highest priority
        return GameRecommendation(
          gameId: gameId,
          reason: 'Explore new cognitive training domain.',
          targetedDomain: gameDomains[gameId] ?? 'Cognitive Exercise',
          recommendedDifficulty: difficulties[gameId] ?? 1,
        );
      }
      final double avgAcc =
          runs.map((m) => m.accuracy).reduce((a, b) => a + b) / runs.length;
      if (avgAcc < lowestScore) {
        lowestScore = avgAcc;
        lowestGameId = gameId;
      }
    }

    return GameRecommendation(
      gameId: lowestGameId,
      reason: 'Targeted reinforcement for ${gameDomains[lowestGameId]}.',
      targetedDomain: gameDomains[lowestGameId] ?? 'Cognitive Exercise',
      recommendedDifficulty: difficulties[lowestGameId] ?? 1,
    );
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// 3. DYNAMIC GAME CONFIGURATION GENERATOR
  /// ─────────────────────────────────────────────────────────────────────────
  /// Provides parameters (item count, memorization time) for each game level.
  Map<String, dynamic> getGameConfiguration({
    required String gameId,
    required int difficulty,
  }) {
    switch (gameId) {
      case 'memory_match':
        return {
          'gridSize': difficulty <= 1 ? 4 : (difficulty == 2 ? 6 : 8),
          'memorizeSeconds': (6 - (difficulty * 0.5)).clamp(3.0, 6.0).toInt(),
          'allowHints': difficulty <= 2,
        };
      case 'sequence_recall':
        return {
          'sequenceLength': 2 + difficulty,
          'playbackSpeedMs': (900 - (difficulty * 80)).clamp(500, 900),
        };
      case 'what_changed':
        return {
          'itemsCount': 3 + difficulty,
          'observationSeconds': (7 - difficulty).clamp(4, 7),
        };
      case 'object_recognition':
        return {
          'optionsCount': difficulty <= 2 ? 3 : 4,
          'timeLimitSeconds': (15 - (difficulty * 2)).clamp(8, 15),
        };
      case 'routine_recall':
      default:
        return {
          'optionsCount': 3,
          'includeTimeQuestions': difficulty >= 2,
        };
    }
  }
}
