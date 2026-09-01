import '../models/models.dart';

/// ─────────────────────────────────────────────────────────────────────────────
///  VANTARA AI ASSISTANT SERVICE (Natural Language / LLM Layer)
/// ─────────────────────────────────────────────────────────────────────────────
///
/// NOTE FOR AI DEVELOPER:
/// This class is the central gateway for conversational AI, voice prompt parsing,
/// and cognitive context-aware responses.
///
/// HOW TO CONNECT YOUR AI BACKEND (Gemini / OpenAI / FastAPI):
/// 1. Replace the rule-based logic in [generateResponse] with an HTTP POST request
///    to your AI endpoint (e.g. `http://your-backend-api.com/v1/chat`).
/// 2. You can pass the [PatientContext] containing recent reminders and game scores
///    as system prompt context to your LLM.
/// ─────────────────────────────────────────────────────────────────────────────

enum UserIntent {
  startMemoryGame,
  startSequenceGame,
  checkReminders,
  dailyPlan,
  generalGreeting,
  help,
  unknown,
}

class PatientContext {
  final String userName;
  final String language; // 'en-US', 'hi-IN', 'as-IN', 'mni-IN'
  final List<Reminder> activeReminders;
  final Map<String, int> gameDifficulties;
  final double averageAccuracy;

  const PatientContext({
    required this.userName,
    required this.language,
    required this.activeReminders,
    required this.gameDifficulties,
    required this.averageAccuracy,
  });
}

class AiAssistantResponse {
  final String spokenText;
  final UserIntent detectedIntent;
  final Map<String, dynamic>? actionPayload; // e.g. {'launchGameId': 'memory_match'}
  final double confidence;

  const AiAssistantResponse({
    required this.spokenText,
    required this.detectedIntent,
    this.actionPayload,
    this.confidence = 1.0,
  });
}

class VantaraAiService {
  static final VantaraAiService _instance = VantaraAiService._internal();
  factory VantaraAiService() => _instance;
  VantaraAiService._internal();

  /// ─────────────────────────────────────────────────────────────────────────
  /// 1. INTENT DETECTION
  /// ─────────────────────────────────────────────────────────────────────────
  /// Parses the user's spoken voice transcript to detect intent.
  UserIntent detectIntent(String prompt) {
    final lower = prompt.toLowerCase();

    if (lower.contains('memory') ||
        lower.contains('match') ||
        lower.contains('मेमोरी') ||
        lower.contains('दिमाग') ||
        lower.contains('स्मृति') ||
        lower.contains('খেল') ||
        lower.contains('শান্নবা')) {
      return UserIntent.startMemoryGame;
    }
    if (lower.contains('sequence') ||
        lower.contains('repeat') ||
        lower.contains('अनुक्रम') ||
        lower.contains('ক্ৰম')) {
      return UserIntent.startSequenceGame;
    }
    if (lower.contains('reminder') ||
        lower.contains('medicine') ||
        lower.contains('water') ||
        lower.contains('दवाई') ||
        lower.contains('रिमाइंडर') ||
        lower.contains('पानी') ||
        lower.contains('औষধ') ||
        lower.contains('হিদাক')) {
      return UserIntent.checkReminders;
    }
    if (lower.contains('plan') ||
        lower.contains('today') ||
        lower.contains('schedule') ||
        lower.contains('योजना') ||
        lower.contains('दिनचर्या') ||
        lower.contains('কাৰ্যসূচী')) {
      return UserIntent.dailyPlan;
    }
    if (lower.contains('hello') ||
        lower.contains('hi') ||
        lower.contains('good morning') ||
        lower.contains('नमस्ते') ||
        lower.contains('सुप्रभात') ||
        lower.contains('নমস্কাৰ') ||
        lower.contains('খুরুমজরি')) {
      return UserIntent.generalGreeting;
    }
    if (lower.contains('help') ||
        lower.contains('मदद') ||
        lower.contains('सहायता') ||
        lower.contains('সহায়') ||
        lower.contains('মতেং')) {
      return UserIntent.help;
    }

    return UserIntent.unknown;
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// 2. RESPONSE GENERATION (Local fallback / API Bridge)
  /// ─────────────────────────────────────────────────────────────────────────
  /// Generates a soothing, dementia-friendly response in the user's language.
  Future<AiAssistantResponse> generateResponse({
    required String userPrompt,
    required PatientContext context,
  }) async {
    final intent = detectIntent(userPrompt);
    final lang = context.language;

    // TODO FOR AI DEVELOPER:
    // If you have a remote server (e.g. Gemini / FastAPI), call it here:
    //
    // final response = await http.post(
    //   Uri.parse('https://your-api.com/chat'),
    //   body: jsonEncode({'prompt': userPrompt, 'lang': lang, 'patient': context.userName}),
    // );

    // Default intelligent rule-based responses:
    switch (intent) {
      case UserIntent.startMemoryGame:
        return AiAssistantResponse(
          spokenText: lang == 'hi-IN'
              ? "ज़रूर! मैं आपके लिए मेमोरी मैच गेम शुरू कर रही हूँ।"
              : lang == 'as-IN'
                  ? "নিশ্চয়! মই আপোনাৰ বাবে স্মৃতি খেল আৰম্ভ কৰিছোঁ।"
                  : "Sure! Starting your Memory Match activity now. Let's keep your brain sharp!",
          detectedIntent: intent,
          actionPayload: {'launchGameId': 'memory_match'},
        );

      case UserIntent.startSequenceGame:
        return AiAssistantResponse(
          spokenText: lang == 'hi-IN'
              ? "अनुक्रम स्मरण खेल शुरू कर रहे हैं।"
              : "Starting your Sequence Recall training now.",
          detectedIntent: intent,
          actionPayload: {'launchGameId': 'sequence_recall'},
        );

      case UserIntent.checkReminders:
        final nextPending = context.activeReminders.firstWhere(
          (r) => !r.isCompleted,
          orElse: () => context.activeReminders.first,
        );
        return AiAssistantResponse(
          spokenText: lang == 'hi-IN'
              ? "आपका अगला रिमाइंडर ${nextPending.title} है, निर्धारित समय ${nextPending.time}।"
              : "Your next reminder is ${nextPending.title} at ${nextPending.time}.",
          detectedIntent: intent,
          actionPayload: {'reminderId': nextPending.id},
        );

      case UserIntent.dailyPlan:
        final uncompletedCount =
            context.activeReminders.where((r) => !r.isCompleted).length;
        return AiAssistantResponse(
          spokenText: lang == 'hi-IN'
              ? "आज की योजना: आपके पास $uncompletedCount बाकी रिमाइंडर और 3 दिमागी खेल हैं।"
              : "Today's plan: You have $uncompletedCount reminders remaining and 3 cognitive exercises.",
          detectedIntent: intent,
        );

      case UserIntent.generalGreeting:
        return AiAssistantResponse(
          spokenText: lang == 'hi-IN'
              ? "नमस्ते ${context.userName}! आशा है आपका दिन बहुत अच्छा बीत रहा है।"
              : "Hello ${context.userName}! Hope you are having a wonderful, peaceful day.",
          detectedIntent: intent,
        );

      case UserIntent.help:
        return AiAssistantResponse(
          spokenText: lang == 'hi-IN'
              ? "मैं आपकी सहायता के लिए यहाँ हूँ। आप मुझसे खेल शुरू करने या रिमाइंडर के बारे में पूछ सकते हैं।"
              : "I am right here to help you. You can ask me to start games or read out your daily reminders.",
          detectedIntent: intent,
        );

      case UserIntent.unknown:
        return AiAssistantResponse(
          spokenText: lang == 'hi-IN'
              ? "मैंने सुन लिया। आज आपके लिए मेमोरी मैच खेलने का अच्छा समय है।"
              : "I heard you! Today is a great time to practice our daily Memory Match exercise.",
          detectedIntent: intent,
          actionPayload: {'launchGameId': 'memory_match'},
        );
    }
  }

  /// ─────────────────────────────────────────────────────────────────────────
  /// 3. CONTEXTUAL MORNING GREETING GENERATOR
  /// ─────────────────────────────────────────────────────────────────────────
  String getContextualGreeting({
    required String language,
    required String userName,
    required int completedRemindersCount,
  }) {
    if (language == 'hi-IN') {
      return completedRemindersCount > 0
          ? "नमस्ते $userName! आप आज बहुत अच्छा कर रहे हैं। आइए आज का खेल खेलें।"
          : "सुप्रभात $userName! आइए आज का दिन ताजगी और दिमागी व्यायाम से शुरू करें।";
    }
    return completedRemindersCount > 0
        ? "Good day $userName! You are doing wonderful today. Let's play today's game."
        : "Good morning $userName! Let's make today great with our daily brain exercises.";
  }
}
