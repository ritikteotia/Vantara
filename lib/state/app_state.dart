import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/tts_service.dart';

class AppState extends ChangeNotifier {
  List<Reminder> _reminders = [];
  List<GameMetric> _gameMetrics = [];
  final Map<String, int> _gameDifficulties = {
    'memory_match': 1,
    'sequence_recall': 1,
    'what_changed': 1,
    'object_recognition': 1,
    'routine_recall': 1,
  };
  String _currentLanguage = 'en-US'; // 'en-US', 'hi-IN', 'as-IN' (Assamese), 'mni-IN' (Manipuri)
  bool _isOnline = true;
  List<GameMetric> _unsyncedMetrics = [];
  bool _isSyncing = false;
  String _syncStatusMessage = "Synced";

  // Getters
  List<Reminder> get reminders => _reminders;
  List<GameMetric> get gameMetrics => _gameMetrics;
  Map<String, int> get gameDifficulties => _gameDifficulties;
  String get currentLanguage => _currentLanguage;
  bool get isOnline => _isOnline;
  List<GameMetric> get unsyncedMetrics => _unsyncedMetrics;
  bool get isSyncing => _isSyncing;
  String get syncStatusMessage => _syncStatusMessage;

  final TtsService _tts = TtsService();

  AppState() {
    _loadFromPrefs();
  }

  // --- Localization / Translation Helpers ---
  String translate(String key) {
    final Map<String, Map<String, String>> translations = {
      'en-US': {
        'app_name': 'Vantara',
        'home': 'Home',
        'games': 'Games',
        'assistant': 'Assistant',
        'profile': 'Profile',
        'reminders_title': 'Today\'s Reminders',
        'recommended_game': 'Today\'s Activity',
        'recommended_game_desc': 'Personalized for your cognitive training today.',
        'play_button': 'Start Activity',
        'voice_guide_active': 'Tap to hear guidelines',
        'sync_online': 'Online',
        'sync_offline': 'Offline Mode (Data Saved Locally)',
        'caregiver_title': 'Caregiver Dashboard',
        'cognitive_level': 'Cognitive Difficulty Level',
        'reminders_compliance': 'Reminder Compliance',
        'recent_activities': 'Recent Activities Log',
        'sync_now': 'Force Sync Now',
        'memory_match': 'Memory Match',
        'sequence_recall': 'Sequence Recall',
        'what_changed': 'What Changed?',
        'object_recognition': 'Object Recognition',
        'routine_recall': 'Daily Routine Recall',
        'completed': 'Completed',
        'snooze': 'Snooze',
        'mark_done': 'Done',
        'score': 'Score',
        'mistakes': 'Mistakes',
        'reaction_time': 'Speed',
        'difficulty': 'Difficulty',
        'assistant_greeting': 'Hello, I am Vantara. How can I help you today? Tap the screen to speak.',
        'reminders_completed_prompt': 'Excellent! You completed your reminder.',
        'game_completed_prompt': 'Wonderful job! Your performance data is saved.',
        'game_difficulty_up': 'Great effort! I am adjusting the next game to be slightly more challenging.',
        'game_difficulty_down': 'No worries! Let\'s practice a simpler version next time.',
      },
      'hi-IN': {
        'app_name': 'वंतरा',
        'home': 'होम',
        'games': 'खेल',
        'assistant': 'सहायक',
        'profile': 'प्रोफ़ाइल',
        'reminders_title': 'आज के रिमाइंडर',
        'recommended_game': 'आज की गतिविधि',
        'recommended_game_desc': 'आपके मस्तिष्क के व्यायाम के लिए अनुकूलित।',
        'play_button': 'शुरू करें',
        'voice_guide_active': 'निर्देश सुनने के लिए दबाएं',
        'sync_online': 'ऑनलाइन',
        'sync_offline': 'ऑफ़लाइन मोड (डेटा सुरक्षित है)',
        'caregiver_title': 'केयरगिवर डैशबोर्ड',
        'cognitive_level': 'संज्ञानात्मक स्तर',
        'reminders_compliance': 'रिमाइंडर अनुपालन',
        'recent_activities': 'हाल की गतिविधियां',
        'sync_now': 'अभी सिंक करें',
        'memory_match': 'मेमोरी मैच',
        'sequence_recall': 'अनुक्रम स्मरण',
        'what_changed': 'क्या बदला?',
        'object_recognition': 'वस्तु पहचान',
        'routine_recall': 'दैनिक दिनचर्या स्मरण',
        'completed': 'पूरा हुआ',
        'snooze': 'देरी करें',
        'mark_done': 'हो गया',
        'score': 'अंक',
        'mistakes': 'गलतियां',
        'reaction_time': 'गति',
        'difficulty': 'कठिनाई',
        'assistant_greeting': 'नमस्ते, मैं वंतरा हूँ। आज मैं आपकी क्या मदद कर सकती हूँ? बोलने के लिए स्क्रीन पर टैप करें।',
        'reminders_completed_prompt': 'बहुत बढ़िया! आपने अपना रिमाइंडर पूरा कर लिया है।',
        'game_completed_prompt': 'अद्भुत काम! आपकी गतिविधि दर्ज कर ली गई है।',
        'game_difficulty_up': 'शानदार प्रयास! अगली बार मैं इसे थोड़ा और चुनौतीपूर्ण बना रही हूँ।',
        'game_difficulty_down': 'कोई बात नहीं! अगली बार हम थोड़ा आसान खेलेंगे।',
      },
      'as-IN': {
        'app_name': 'বানতৰা',
        'home': 'গৃহ',
        'games': 'খেলসমূহ',
        'assistant': 'সহায়ক',
        'profile': 'পৰিচয়',
        'reminders_title': 'আজিৰ ৰিমাইণ্ডাৰ',
        'recommended_game': 'আজিৰ কাৰ্যসূচী',
        'recommended_game_desc': 'আজি আপোনাৰ মানসিক ব্যায়ামৰ বাবে তৈয়াৰ কৰা হৈছে।',
        'play_button': 'আৰম্ভ কৰক',
        'voice_guide_active': 'নিৰ্দেশনা শুনিবলৈ স্পৰ্শ কৰক',
        'sync_online': 'অনলাইন',
        'sync_offline': 'অফলাইন মোড (তথ্য সংৰক্ষিত কৰা হৈছে)',
        'caregiver_title': 'তত্বাৱধায়ক ড্যাশবৰ্ড',
        'cognitive_level': 'মানসিক জটিলতাৰ স্তৰ',
        'reminders_compliance': 'ৰিমাইণ্ডাৰ সফল সমাপ্তি',
        'recent_activities': 'শেহতীয়া গতিবিধি লগ',
        'sync_now': 'এতিয়াই সংযোগ কৰক',
        'memory_match': 'স্মৃতি মিলাওক',
        'sequence_recall': 'ক্ৰম মনত পেলাওক',
        'what_changed': 'কি সলনি হ’ল?',
        'object_recognition': 'বস্তু চিনাক্তকৰণ',
        'routine_recall': 'দিনচৰ্যা সোঁৱৰণ',
        'completed': 'সমাপ্ত',
        'snooze': 'পাছত কৰিব',
        'mark_done': 'হৈ গ’ল',
        'score': 'নম্বৰ',
        'mistakes': 'ভুলসমূহ',
        'reaction_time': 'গতি',
        'difficulty': 'কঠিনতা',
        'assistant_greeting': 'নমস্কাৰ, মই বানতৰা। আজ মই আপোনাক কেনেকৈ সহায় কৰিব পাৰোঁ? কবলৈ স্ক্ৰীনত স্পৰ্শ কৰক।',
        'reminders_completed_prompt': 'অতি সুন্দৰ! আপুনি আপোনাৰ কাম সম্পন্ন কৰিলে।',
        'game_completed_prompt': 'চমৎকার! আপোনাৰ তথ্যসমূহ জমা কৰা হৈছে।',
        'game_difficulty_up': 'বঢ়িয়া চেষ্টা! মই পৰৱৰ্তী খেলটো অলপ কঠিন কৰিছোঁ।',
        'game_difficulty_down': 'একো কথা নাই, পিছৰ বাৰ আমি ইয়াতকৈ সহজ খেল খেলি লম।',
      },
      'mni-IN': {
        'app_name': 'ৱান্তরা',
        'home': 'য়ুম',
        'games': 'শেল্লীং',
        'assistant': 'মতেং পাংবীবী',
        'profile': 'মফম',
        'reminders_title': 'ঙসিগী রিমাইন্দর',
        'recommended_game': 'ঙসিগী থবক',
        'recommended_game_desc': 'ঙসিগী ওইনা অদোমগী লৌশিং খংনবা শেম্বা।',
        'play_button': 'হৌগদবনি',
        'voice_guide_active': 'তাকপীবশিং তাশিনবা নাম্বীয়ু',
        'sync_online': 'অনলাইন',
        'sync_offline': 'ওফলাইন ওইরি (মফমদা থমখ্রে)',
        'caregiver_title': 'কেয়রগিভর দেসবোর্দ',
        'cognitive_level': 'লৌশিংগী থাক',
        'reminders_compliance': 'রিমাইন্দর থবক মপুং ফাবা',
        'recent_activities': 'ঙসিগী থবকশিংগী মমি',
        'sync_now': 'হৌজিক সিন্ক তৌউ',
        'memory_match': 'নিংসিংবা চুনহনবা',
        'sequence_recall': 'মথং-মনাও নিংসিংবা',
        'what_changed': 'করি হোংখ্রে?',
        'object_recognition': 'পোৎশক শকখংবা',
        'routine_recall': 'নুমিৎ খুদিংগী থবক নিংসিংবা',
        'completed': 'লোইখ্রে',
        'snooze': 'তুংদা',
        'mark_done': 'লোইরে',
        'score': 'পয়েন্ট',
        'mistakes': 'অশোইবশিং',
        'reaction_time': 'খোঙজেল',
        'difficulty': 'অরুবা',
        'assistant_greeting': 'খুরুমজরি, ঐহাক ৱান্তরানি। ঙসি ঐহাক অদোমগী করি মতেং পাংগদগে? ঙাংনবা স্ক্ৰীন্দা নমীয়ু।',
        'reminders_completed_prompt': 'য়াম্না ফৈ! অদোমগী রিমাইন্দর লোইরে।',
        'game_completed_prompt': 'য়াম্না ফৈ! অদোমগী থবকশিং থমখ্রে।',
        'game_difficulty_up': 'য়াম্না কন্না হোৎনখ্রে! মথংগী শান্নবা অসি অমুক্তা হেন্না অরুবা ওইহনখ্রে।',
        'game_difficulty_down': 'করি হুমদে! মথংদা হেন্না লায়বা শান্নরসি।',
      }
    };

    return translations[_currentLanguage]?[key] ?? translations['en-US']?[key] ?? key;
  }

  // Speak voice prompt
  void speakPrompt(String key) {
    _tts.speak(translate(key));
  }

  // Speak custom reminder voice
  void speakReminder(Reminder reminder) {
    // Translate standard reminder messages if in other languages
    String promptText = reminder.speechPrompt;
    if (_currentLanguage == 'hi-IN') {
      if (reminder.title.contains('Water')) {
        promptText = "कृपया पानी पी लीजिए। स्वस्थ रहने के लिए हाइड्रेशन जरूरी है।";
      } else if (reminder.title.contains('Medicine')) {
        promptText = "दवाई लेने का समय हो गया है। कृपया अपनी लाल रंग की गोली खा लीजिए।";
      } else if (reminder.title.contains('Walk')) {
        promptText = "शाम की सैर का समय है। चलो पार्क चलते हैं।";
      } else if (reminder.title.contains('Doctor')) {
        promptText = "आज डॉक्टर के पास जाने का समय है।";
      }
    } else if (_currentLanguage == 'as-IN') {
      if (reminder.title.contains('Water')) {
        promptText = "অনুগ্ৰহ কৰি অলপ পানী খাওক। শৰীৰটো সুস্থ ৰাখিবলৈ পানী খোৱাটো গুৰুত্বপূৰ্ণ।";
      } else if (reminder.title.contains('Medicine')) {
        promptText = "আপোনাৰ ঔষধ খোৱাৰ সময় হ’ল। অনুগ্ৰহ কৰি ৰঙা বড়ীটো খাই লওক।";
      } else if (reminder.title.contains('Walk')) {
        promptText = "সন্ধিয়া খোজ কঢ়াৰ সময় হৈছে। বলক অলপ ফুৰি আহোঁ।";
      } else if (reminder.title.contains('Doctor')) {
        promptText = "আজি ডাক্তৰৰ ওচৰলৈ যোৱাৰ সময় হৈছে।";
      }
    } else if (_currentLanguage == 'mni-IN') {
      if (reminder.title.contains('Water')) {
        promptText = "চানবীদুনা ঈশিং থকপীয়ু। হকচাং ফনা থম্নবা ঈশিং থকপা য়াম্না মরু ওই।";
      } else if (reminder.title.contains('Medicine')) {
        promptText = "অদোমগী হিদাক থকপগী মতম ওইরে। চানবীদুना অঙাংবা হিদাক থকপীয়ু।";
      } else if (reminder.title.contains('Walk')) {
        promptText = "খোঙ চৎপগী মতম ওইরে। চৎলসি কোইনা।";
      } else if (reminder.title.contains('Doctor')) {
        promptText = "ঙসি দা ক্তর থেংনবা চৎকদবনি।";
      }
    }
    _tts.speak(promptText);
  }

  // --- Actions ---

  Future<void> changeLanguage(String langCode) async {
    _currentLanguage = langCode;
    await _tts.setLanguage(langCode);
    notifyListeners();
    _saveToPrefs();

    // Greet user in new language
    speakPrompt('assistant_greeting');
  }

  Future<void> setOnlineStatus(bool online) async {
    _isOnline = online;
    _syncStatusMessage = online ? "Syncing..." : "Offline Mode";
    notifyListeners();
    _saveToPrefs();

    if (online) {
      await triggerSync();
    }
  }

  Future<void> toggleReminder(String id) async {
    final idx = _reminders.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _reminders[idx].isCompleted = !_reminders[idx].isCompleted;
      _reminders[idx].completedAt = _reminders[idx].isCompleted ? DateTime.now() : null;

      if (_reminders[idx].isCompleted) {
        speakPrompt('reminders_completed_prompt');
      }

      notifyListeners();
      _saveToPrefs();
    }
  }

  Future<void> addGameMetric(GameMetric metric) async {
    _gameMetrics.add(metric);
    _unsyncedMetrics.add(metric);

    // AI Personalization Engine
    _adjustDifficulty(metric.gameId);

    notifyListeners();
    _saveToPrefs();

    if (_isOnline) {
      await triggerSync();
    }
  }

  // AI-Based Personalization difficulty adjustment
  void _adjustDifficulty(String gameId) {
    // Filter history for this game
    final history = _gameMetrics.where((m) => m.gameId == gameId).toList();
    if (history.length < 2) return; // Wait for at least 2 sessions to adapt

    // Get last 2 metrics
    final lastRuns = history.sublist(history.length - 2);
    double avgAccuracy = lastRuns.map((m) => m.accuracy).reduce((a, b) => a + b) / 2;
    double avgMistakes = lastRuns.map((m) => m.mistakes.toDouble()).reduce((a, b) => a + b) / 2;

    int currentDiff = _gameDifficulties[gameId] ?? 1;

    if (avgAccuracy >= 0.85 && currentDiff < 5) {
      _gameDifficulties[gameId] = currentDiff + 1;
      speakPrompt('game_difficulty_up');
    } else if ((avgAccuracy < 0.60 || avgMistakes > 2.0) && currentDiff > 1) {
      _gameDifficulties[gameId] = currentDiff - 1;
      speakPrompt('game_difficulty_down');
    } else {
      speakPrompt('game_completed_prompt');
    }
  }

  Future<void> triggerSync() async {
    if (!_isOnline || _isSyncing || _unsyncedMetrics.isEmpty) return;

    _isSyncing = true;
    _syncStatusMessage = "Syncing data to Caregiver Portal...";
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    _unsyncedMetrics.clear();
    _isSyncing = false;
    _syncStatusMessage = "All Data Synchronized";
    notifyListeners();
    _saveToPrefs();
  }

  // --- Local Storage Management ---

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load Language
      _currentLanguage = prefs.getString('language') ?? 'en-US';
      await _tts.setLanguage(_currentLanguage);

      // Load Online State
      _isOnline = prefs.getBool('isOnline') ?? true;
      _syncStatusMessage = _isOnline ? "Synced" : "Offline Mode";

      // Load Game Difficulties
      final diffStr = prefs.getString('gameDifficulties');
      if (diffStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(diffStr);
        decoded.forEach((key, value) {
          _gameDifficulties[key] = value as int;
        });
      }

      // Load Reminders
      final remStr = prefs.getString('reminders');
      if (remStr != null) {
        final List<dynamic> decoded = jsonDecode(remStr);
        _reminders = decoded.map((item) => Reminder.fromJson(item)).toList();
      } else {
        _generateDefaultReminders();
      }

      // Load Metrics
      final metricsStr = prefs.getString('metrics');
      if (metricsStr != null) {
        final List<dynamic> decoded = jsonDecode(metricsStr);
        _gameMetrics = decoded.map((item) => GameMetric.fromJson(item)).toList();
      } else {
        _generateMockHistory();
      }

      // Load Unsynced Queue
      final unsyncedStr = prefs.getString('unsynced');
      if (unsyncedStr != null) {
        final List<dynamic> decoded = jsonDecode(unsyncedStr);
        _unsyncedMetrics = decoded.map((item) => GameMetric.fromJson(item)).toList();
      }

      notifyListeners();
    } catch (e) {
      // Create fallbacks if load fails
      _generateDefaultReminders();
      _generateMockHistory();
    }
  }

  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', _currentLanguage);
      await prefs.setBool('isOnline', _isOnline);
      await prefs.setString('gameDifficulties', jsonEncode(_gameDifficulties));
      await prefs.setString('reminders', jsonEncode(_reminders.map((r) => r.toJson()).toList()));
      await prefs.setString('metrics', jsonEncode(_gameMetrics.map((m) => m.toJson()).toList()));
      await prefs.setString('unsynced', jsonEncode(_unsyncedMetrics.map((m) => m.toJson()).toList()));
    } catch (e) {
      // Silent error fallback
    }
  }

  void _generateDefaultReminders() {
    _reminders = [
      Reminder(
        id: 'rem_med',
        title: 'Morning Medicine',
        type: ReminderType.medicine,
        time: '08:30 AM',
        speechPrompt: 'Time for your morning medicine. Please swallow the red pill with a glass of warm water.',
      ),
      Reminder(
        id: 'rem_hyd',
        title: 'Drink Water',
        type: ReminderType.hydration,
        time: '11:00 AM',
        speechPrompt: 'It is time to drink water. Let\'s drink a full glass to stay fresh and hydrated.',
      ),
      Reminder(
        id: 'rem_walk',
        title: 'Evening Walk',
        type: ReminderType.activity,
        time: '05:00 PM',
        speechPrompt: 'Time for your evening garden walk. Put on your comfortable walking shoes.',
      ),
      Reminder(
        id: 'rem_appt',
        title: 'Doctor Checkup',
        type: ReminderType.appointment,
        time: '06:30 PM',
        speechPrompt: 'Reminder: Doctor verification visit is scheduled today. Caregiver will accompany you.',
      ),
    ];
  }

  void _generateMockHistory() {
    final now = DateTime.now();
    _gameMetrics = [
      GameMetric(gameId: 'memory_match', timestamp: now.subtract(const Duration(days: 4)), accuracy: 0.60, reactionTimeMs: 4200, mistakes: 3, attempts: 1, completed: true),
      GameMetric(gameId: 'memory_match', timestamp: now.subtract(const Duration(days: 3)), accuracy: 0.70, reactionTimeMs: 3800, mistakes: 2, attempts: 1, completed: true),
      GameMetric(gameId: 'memory_match', timestamp: now.subtract(const Duration(days: 2)), accuracy: 0.85, reactionTimeMs: 2900, mistakes: 1, attempts: 1, completed: true),
      GameMetric(gameId: 'sequence_recall', timestamp: now.subtract(const Duration(days: 3)), accuracy: 0.50, reactionTimeMs: 5000, mistakes: 4, attempts: 2, completed: true),
      GameMetric(gameId: 'sequence_recall', timestamp: now.subtract(const Duration(days: 2)), accuracy: 0.75, reactionTimeMs: 3500, mistakes: 2, attempts: 1, completed: true),
      GameMetric(gameId: 'object_recognition', timestamp: now.subtract(const Duration(days: 1)), accuracy: 0.90, reactionTimeMs: 2100, mistakes: 0, attempts: 1, completed: true),
    ];
  }
}
