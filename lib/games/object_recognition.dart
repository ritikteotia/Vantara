import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class ObjectRecognitionGame extends StatefulWidget {
  const ObjectRecognitionGame({super.key});

  @override
  State<ObjectRecognitionGame> createState() => _ObjectRecognitionGameState();
}

class _ObjectRecognitionGameState extends State<ObjectRecognitionGame> {
  late int _difficulty;
  int _optionCount = 2;
  late Map<String, dynamic> _targetItem;
  List<String> _options = [];
  bool _canTap = true;

  // Metrics
  DateTime? _gameStartTime;
  int _mistakes = 0;
  int _attempts = 0;

  final List<Map<String, dynamic>> _itemDatabase = [
    {
      'icon': Icons.eco,
      'color': Colors.green.shade800,
      'label': 'Assam Tea Leaf',
      'labelHindi': 'असम चाय की पत्ती',
      'labelAssamese': 'অসম চাহ পাত',
      'choices': ['Assam Tea Leaf', 'Rose Flower', 'Mango Tree', 'Pineapple']
    },
    {
      'icon': Icons.music_note,
      'color': Colors.brown.shade700,
      'label': 'Dhol Drum',
      'labelHindi': 'ढोल / ड्रम',
      'labelAssamese': 'ঢোল',
      'choices': ['Dhol Drum', 'Guitar', 'Flute', 'Violin']
    },
    {
      'icon': Icons.home,
      'color': Colors.orange.shade800,
      'label': 'Traditional Hut',
      'labelHindi': 'पारंपरिक झोपड़ी',
      'labelAssamese': 'নামঘৰ / ঘৰ',
      'choices': ['Traditional Hut', 'Brick Mansion', 'Railway Station', 'Bridge']
    },
    {
      'icon': Icons.emoji_nature,
      'color': Colors.orange.shade600,
      'label': 'Hornbill Bird',
      'labelHindi': 'हॉर्नबिल पक्षी',
      'labelAssamese': 'ধনেশ পক্ষী',
      'choices': ['Hornbill Bird', 'Crow', 'Parrot', 'Eagle']
    },
    {
      'icon': Icons.coffee,
      'color': Colors.amber.shade900,
      'label': 'Bamboo Mug',
      'labelHindi': 'बांस का मग',
      'labelAssamese': 'বাঁহৰ চুঙা / মগ',
      'choices': ['Bamboo Mug', 'Glass Cup', 'Metal Plate', 'Plastic Bottle']
    },
    {
      'icon': Icons.directions_boat,
      'color': Colors.teal.shade800,
      'label': 'River Canoe',
      'labelHindi': 'नदी की नाव',
      'labelAssamese': 'নদীৰ নাও',
      'choices': ['River Canoe', 'Aeroplane', 'Motorcycle', 'Bicycle']
    },
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _difficulty = appState.gameDifficulties['object_recognition'] ?? 1;

    // Determine number of choices based on difficulty
    if (_difficulty <= 1) {
      _optionCount = 2;
    } else if (_difficulty == 2) {
      _optionCount = 3;
    } else {
      _optionCount = 4;
    }

    _setupGame();
  }

  void _setupGame() {
    final appState = Provider.of<AppState>(context, listen: false);

    // Pick a random target item
    final rand = _Rand(DateTime.now().millisecondsSinceEpoch);
    _targetItem = _itemDatabase[rand.nextInt(_itemDatabase.length)];

    // Get current name based on language
    String correctName = _getLocalizedLabel(_targetItem, appState.currentLanguage);

    // Build options pool (ensure correct label is always there)
    List<String> pool = List<String>.from(_targetItem['choices']);
    pool.remove(_targetItem['label']); // Remove default english correct choice

    // Translate wrong choices if language is hindi/assamese to match target
    List<String> translatedWrongChoices = pool.map((item) {
      // Find item matching English label in database to translate
      final matchingItem = _itemDatabase.firstWhere((element) => element['label'] == item, orElse: () => {});
      if (matchingItem.isNotEmpty) {
        return _getLocalizedLabel(matchingItem, appState.currentLanguage);
      }
      return item;
    }).toList();

    translatedWrongChoices.shuffle();
    _options = [correctName];
    for (int i = 0; i < _optionCount - 1; i++) {
      if (i < translatedWrongChoices.length) {
        _options.add(translatedWrongChoices[i]);
      }
    }
    _options.shuffle();

    _canTap = true;
    _gameStartTime = DateTime.now();

    // Trigger TTS reading question
    String voiceQ = appState.currentLanguage == 'hi-IN'
        ? "यह चित्र किस वस्तु का है? नीचे दिए गए विकल्पों में से चुनें।"
        : appState.currentLanguage == 'as-IN'
            ? "এইয়া কিহৰ ছবি? তলৰ বিকল্পবোৰৰ পৰা বাচি লওক।"
            : "What is this object? Choose the correct option from below.";
    
    // Append the question and let it play
    Timer(const Duration(milliseconds: 1000), () {
      appState.speakPrompt(voiceQ);
    });
  }

  String _getLocalizedLabel(Map<String, dynamic> item, String lang) {
    if (lang == 'hi-IN') {
      return item['labelHindi'] ?? item['label'];
    } else if (lang == 'as-IN') {
      return item['labelAssamese'] ?? item['label'];
    }
    return item['label'];
  }

  void _onOptionSelected(String option) {
    if (!_canTap) return;

    final appState = Provider.of<AppState>(context, listen: false);
    String correctName = _getLocalizedLabel(_targetItem, appState.currentLanguage);
    _attempts++;

    if (option == correctName) {
      // CORRECT!
      setState(() {
        _canTap = false;
      });
      _finishGame();
    } else {
      // INCORRECT
      setState(() {
        _mistakes++;
      });
      String warning = appState.currentLanguage == 'hi-IN' ? "नहीं, दोबारा सोचें।" : "That's not correct. Let's try again.";
      appState.speakPrompt(warning);
    }
  }

  void _finishGame() {
    final endTime = DateTime.now();
    final duration = _gameStartTime != null
        ? endTime.difference(_gameStartTime!).inMilliseconds
        : 6000;

    double accuracy = _attempts > 0 ? 1.0 / (_mistakes + 1) : 1.0;

    final metric = GameMetric(
      gameId: 'object_recognition',
      timestamp: DateTime.now(),
      accuracy: accuracy,
      reactionTimeMs: duration,
      mistakes: _mistakes,
      attempts: _attempts,
      completed: true,
    );

    final appState = Provider.of<AppState>(context, listen: false);
    appState.addGameMetric(metric);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF9F5),
        title: Center(
          child: Text(
            appState.translate('completed'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 70),
            const SizedBox(height: 16),
            Text(
              '${appState.translate('score')}: ${(accuracy * 100).toInt()}%',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${appState.translate('mistakes')}: $_mistakes',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '${appState.translate('reaction_time')}: ${(duration / 1000).toStringAsFixed(1)}s',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              appState.translate('recommended_game_desc'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8D7B68),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Back to Home', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    String correctName = _getLocalizedLabel(_targetItem, appState.currentLanguage);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF7D5A50)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          appState.translate('object_recognition'),
          style: const TextStyle(color: Color(0xFF7D5A50), fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3EFE0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                'Lvl $_difficulty',
                style: const TextStyle(color: Color(0xFF7D5A50), fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                String guidance = appState.currentLanguage == 'hi-IN'
                    ? "यह चित्र किस चीज़ का है? नीचे दिए गए सही नाम वाले बटन पर दबाएं।"
                    : "Look at the object shown in the box, then choose the correct option representing its name.";
                appState.speakPrompt(guidance);
              },
              child: Card(
                elevation: 0,
                color: const Color(0xFFF3EFE0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF8D7B68),
                        child: Icon(Icons.volume_up, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          appState.translate('voice_guide_active'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Object Card Display
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                  border: Border.all(color: const Color(0xFFE6DED4), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _targetItem['icon'],
                      size: 130,
                      color: _targetItem['color'],
                    ),
                    const SizedBox(height: 24),
                    // Large Voice speak button
                    InkWell(
                      onTap: () {
                        // Speak the name of the target item if patient needs hint
                        appState.speakPrompt("Hint: This object is a ${_targetItem['label']}.");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF7F2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE6DED4)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.help_outline, color: Color(0xFF8D7B68)),
                            SizedBox(width: 8),
                            Text("Need Hint?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8D7B68))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Multiple choice buttons list
            Expanded(
              flex: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _options.map((option) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D7B68),
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () => _onOptionSelected(option),
                        child: Text(
                          option,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rand {
  int seed;
  _Rand(this.seed);
  int nextInt(int max) {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return (seed >> 16) % max;
  }
}
