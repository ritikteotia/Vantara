enum ReminderType {
  medicine,
  hydration,
  activity,
  appointment
}

class Reminder {
  final String id;
  final String title;
  final ReminderType type;
  final String time;
  final String speechPrompt;
  bool isCompleted;
  DateTime? completedAt;

  Reminder({
    required this.id,
    required this.title,
    required this.type,
    required this.time,
    required this.speechPrompt,
    this.isCompleted = false,
    this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.index,
    'time': time,
    'speechPrompt': speechPrompt,
    'isCompleted': isCompleted,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'],
    title: json['title'],
    type: ReminderType.values[json['type']],
    time: json['time'],
    speechPrompt: json['speechPrompt'],
    isCompleted: json['isCompleted'] ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
  );
}

class GameMetric {
  final String gameId;
  final DateTime timestamp;
  final double accuracy; // 0.0 to 1.0
  final int reactionTimeMs;
  final int mistakes;
  final int attempts;
  final bool completed;

  GameMetric({
    required this.gameId,
    required this.timestamp,
    required this.accuracy,
    required this.reactionTimeMs,
    required this.mistakes,
    required this.attempts,
    required this.completed,
  });

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'timestamp': timestamp.toIso8601String(),
    'accuracy': accuracy,
    'reactionTimeMs': reactionTimeMs,
    'mistakes': mistakes,
    'attempts': attempts,
    'completed': completed,
  };

  factory GameMetric.fromJson(Map<String, dynamic> json) => GameMetric(
    gameId: json['gameId'],
    timestamp: DateTime.parse(json['timestamp']),
    accuracy: (json['accuracy'] as num).toDouble(),
    reactionTimeMs: json['reactionTimeMs'],
    mistakes: json['mistakes'],
    attempts: json['attempts'],
    completed: json['completed'] ?? true,
  );
}
