import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class MemoryMatchGame extends StatefulWidget {
  const MemoryMatchGame({super.key});

  @override
  State<MemoryMatchGame> createState() => _MemoryMatchGameState();
}

class _MemoryMatchGameState extends State<MemoryMatchGame> {
  late int _difficulty;
  late int _gridSize; // Total cards
  List<Map<String, dynamic>> _cards = [];
  List<int> _selectedIndices = [];
  bool _isMemorizationPhase = true;
  bool _canTap = false;
  int _memorizeSeconds = 5;
  Timer? _memorizeTimer;
  int _secondsRemaining = 5;

  // Game tracking metrics
  DateTime? _gameStartTime;
  int _mistakes = 0;
  int _attempts = 0;
  int _pairsMatched = 0;

  // Culturally familiar items
  final List<Map<String, dynamic>> _allItems = [
    {'icon': Icons.eco, 'label': 'Tea Leaf', 'color': Colors.green.shade700},
    {'icon': Icons.nature_people, 'label': 'One-horned Rhino', 'color': Colors.grey.shade700},
    {'icon': Icons.music_note, 'label': 'Dhol Drum', 'color': Colors.brown.shade600},
    {'icon': Icons.wb_sunny, 'label': 'Bihu Sun', 'color': Colors.amber.shade800},
    {'icon': Icons.filter_hdr, 'label': 'Himalayas', 'color': Colors.teal.shade700},
    {'icon': Icons.emoji_nature, 'label': 'Hornbill', 'color': Colors.orange.shade800},
    {'icon': Icons.waves, 'label': 'Brahmaputra', 'color': Colors.blue.shade700},
    {'icon': Icons.home_repair_service, 'label': 'Bamboo Basket', 'color': Colors.yellow.shade900},
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _difficulty = appState.gameDifficulties['memory_match'] ?? 1;

    // Speak initial guidelines
    String welcomeMsg = appState.currentLanguage == 'hi-IN'
        ? "मेमोरी मैच में आपका स्वागत है। कार्ड को याद रखें और जोड़ियां ढूंढें।"
        : appState.currentLanguage == 'as-IN'
            ? "স্মৃতি মিলাওকলৈ আদৰণি জনাইছোঁ। কাৰ্ডসমূহ মনত ৰাখক আৰু জোৰা মিলাওক।"
            : appState.currentLanguage == 'mni-IN'
                ? "নিংসিংবা চুনহনবদা তরাম্না ওকচরি। কার্দশিং নিংসিংদুনা চুনহনবীয়ু।"
                : "Welcome to Memory Match. Remember the cards and find the matching pairs.";
    appState.speakPrompt(welcomeMsg); // Speak welcome or custom text directly

    _setupGame();
  }

  void _setupGame() {
    // Configure game parameters based on difficulty level
    if (_difficulty <= 1) {
      _gridSize = 4; // 2x2
      _memorizeSeconds = 6;
    } else if (_difficulty == 2) {
      _gridSize = 6; // 2x3
      _memorizeSeconds = 6;
    } else if (_difficulty == 3) {
      _gridSize = 8; // 2x4
      _memorizeSeconds = 5;
    } else if (_difficulty == 4) {
      _gridSize = 12; // 3x4
      _memorizeSeconds = 5;
    } else {
      _gridSize = 16; // 4x4
      _memorizeSeconds = 4;
    }

    _secondsRemaining = _memorizeSeconds;

    // Pick subset of items
    int pairsNeeded = _gridSize ~/ 2;
    List<Map<String, dynamic>> selectedItems = List.from(_allItems)..shuffle();
    selectedItems = selectedItems.sublist(0, pairsNeeded);

    // Duplicate for matching pairs
    List<Map<String, dynamic>> gameItems = [];
    for (var item in selectedItems) {
      gameItems.add({...item, 'id': '${item['label']}_1', 'isFlipped': true, 'isMatched': false});
      gameItems.add({...item, 'id': '${item['label']}_2', 'isFlipped': true, 'isMatched': false});
    }
    gameItems.shuffle();
    _cards = gameItems;

    // Start memorization countdown
    _isMemorizationPhase = true;
    _canTap = false;
    _startMemorizeTimer();
  }

  void _startMemorizeTimer() {
    _memorizeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 1) {
          _secondsRemaining--;
        } else {
          timer.cancel();
          _isMemorizationPhase = false;
          _canTap = true;
          // Flip all cards down
          for (var card in _cards) {
            card['isFlipped'] = false;
          }
          _gameStartTime = DateTime.now();
        }
      });
    });
  }

  void _onCardTap(int index) {
    if (!_canTap || _cards[index]['isFlipped'] || _cards[index]['isMatched']) return;

    setState(() {
      _cards[index]['isFlipped'] = true;
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      _canTap = false;
      _attempts++;
      int firstIdx = _selectedIndices[0];
      int secondIdx = _selectedIndices[1];

      if (_cards[firstIdx]['label'] == _cards[secondIdx]['label']) {
        // MATCH!
        setState(() {
          _cards[firstIdx]['isMatched'] = true;
          _cards[secondIdx]['isMatched'] = true;
          _pairsMatched++;
          _selectedIndices.clear();
          _canTap = true;
        });

        if (_pairsMatched == _gridSize ~/ 2) {
          _finishGame();
        }
      } else {
        // MISMATCH
        _mistakes++;
        Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            _cards[firstIdx]['isFlipped'] = false;
            _cards[secondIdx]['isFlipped'] = false;
            _selectedIndices.clear();
            _canTap = true;
          });
        });
      }
    }
  }

  void _finishGame() {
    final endTime = DateTime.now();
    final duration = _gameStartTime != null
        ? endTime.difference(_gameStartTime!).inMilliseconds
        : 10000;

    double accuracy = _attempts > 0 ? (_gridSize ~/ 2) / _attempts : 1.0;

    final metric = GameMetric(
      gameId: 'memory_match',
      timestamp: DateTime.now(),
      accuracy: accuracy,
      reactionTimeMs: duration,
      mistakes: _mistakes,
      attempts: _attempts,
      completed: true,
    );

    // Save score to AppState (which recalibrates difficulty auto)
    final appState = Provider.of<AppState>(context, listen: false);
    appState.addGameMetric(metric);

    // Show completion dialogue
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF9F5), // Elder-friendly warm cream
        title: Center(
          child: Text(
            appState.translate('completed'),
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 70),
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
                Navigator.of(ctx).pop(); // Dismiss dialog
                Navigator.of(context).pop(); // Back to games page
              },
              child: const Text('Back to Home', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _memorizeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final themeColor = const Color(0xFF8D7B68);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2), // Warm, soft background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF7D5A50)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          appState.translate('memory_match'),
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
            // Voice assistant prompt trigger card
            GestureDetector(
              onTap: () {
                String guidance = appState.currentLanguage == 'hi-IN'
                    ? "कार्ड को ध्यान से देखें। फिर बंद होने पर समान कार्ड जोड़ियां चुनें।"
                    : appState.currentLanguage == 'as-IN'
                        ? "কাৰ্ডসমূহ মন দি চাওক। তাৰ পিছত জোৰা কাৰ্ড বাচি উলিওৱক।"
                        : "Look at the cards carefully, then tap the matching pairs when they turn face down.";
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

            // Phase indicator / timer bar
            if (_isMemorizationPhase)
              Column(
                children: [
                  Text(
                    'Memorize the cards! ($_secondsRemaining s)',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _secondsRemaining / _memorizeSeconds,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFEFEFEF),
                      color: Colors.amber,
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Matches: $_pairsMatched / ${_gridSize ~/ 2}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
                  ),
                  Text(
                    'Mistakes: $_mistakes',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Card grid
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _gridSize <= 6 ? 2 : (_gridSize == 8 ? 2 : (_gridSize == 12 ? 3 : 4)),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _gridSize,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  final bool isRevealed = card['isFlipped'] || card['isMatched'];

                  return GestureDetector(
                    onTap: () => _onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: isRevealed ? Colors.white : themeColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                        border: isRevealed
                            ? Border.all(color: card['color'], width: 3)
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Center(
                        child: isRevealed
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(card['icon'], size: 40, color: card['color']),
                                  const SizedBox(height: 6),
                                  Text(
                                    card['label'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: _gridSize > 8 ? 11 : 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF7D5A50),
                                    ),
                                  )
                                ],
                              )
                            : Image.asset(
                                'assets/logo_placeholder.png', // Fallback, we'll draw a symbol instead if not loaded
                                errorBuilder: (c, o, s) => const Icon(
                                  Icons.question_mark,
                                  size: 45,
                                  color: Colors.white54,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
