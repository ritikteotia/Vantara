import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class WhatChangedGame extends StatefulWidget {
  const WhatChangedGame({super.key});

  @override
  State<WhatChangedGame> createState() => _WhatChangedGameState();
}

class _WhatChangedGameState extends State<WhatChangedGame> {
  late int _difficulty;
  int _itemCount = 3;
  List<Map<String, dynamic>> _originalItems = [];
  List<Map<String, dynamic>> _currentItems = [];
  int _changedIndex = -1;
  bool _isShowingOriginal = true;
  bool _isTransitioning = false;
  bool _canTap = false;

  // Metrics
  DateTime? _gameStartTime;
  int _mistakes = 0;
  int _attempts = 0;

  final List<Map<String, dynamic>> _pool = [
    {'icon': Icons.eco, 'color': Colors.green, 'label': 'Tea Pot'},
    {'icon': Icons.music_note, 'color': Colors.brown, 'label': 'Dhol Drum'},
    {'icon': Icons.home, 'color': Colors.orange, 'label': 'Assam House'},
    {'icon': Icons.emoji_nature, 'color': Colors.blue, 'label': 'Hornbill'},
    {'icon': Icons.umbrella, 'color': Colors.red, 'label': 'Umbrella'},
    {'icon': Icons.coffee, 'color': Colors.amber, 'label': 'Bamboo Mug'},
    {'icon': Icons.waves, 'color': Colors.teal, 'label': 'River Canoe'},
    {'icon': Icons.wb_sunny, 'color': Colors.yellow.shade800, 'label': 'Warm Sun'},
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _difficulty = appState.gameDifficulties['what_changed'] ?? 1;

    // Adjust item pool based on difficulty
    if (_difficulty <= 1) {
      _itemCount = 3;
    } else if (_difficulty == 2) {
      _itemCount = 4;
    } else if (_difficulty == 3) {
      _itemCount = 5;
    } else if (_difficulty == 4) {
      _itemCount = 6;
    } else {
      _itemCount = 8;
    }

    // Speak initial welcome instruction
    String welcomeMsg = appState.currentLanguage == 'hi-IN'
        ? "क्या बदला है? अलमारी में रखी वस्तुओं को ध्यान से देखें। फिर बताएं कि कौन सी वस्तु गायब या बदल गई है।"
        : "What changed? Look at the items on the shelf. Then identify which item changed.";
    appState.speakPrompt(welcomeMsg);

    _setupGame();
  }

  void _setupGame() {
    // Select unique items
    List<Map<String, dynamic>> selected = List.from(_pool)..shuffle();
    _originalItems = selected.sublist(0, _itemCount);

    // Copy to current items
    _currentItems = _originalItems.map((item) => Map<String, dynamic>.from(item)).toList();

    // Determine change index
    final rand = _Rand(DateTime.now().millisecondsSinceEpoch);
    _changedIndex = rand.nextInt(_itemCount);

    // Apply the change: make it missing (replace with a question mark) or change its color drastically
    // For simplicity, let's make it missing or changed to a grey question mark icon
    _currentItems[_changedIndex] = {
      'icon': Icons.help_outline,
      'color': Colors.grey.shade400,
      'label': 'Missing Item',
      'isChanged': true
    };

    _isShowingOriginal = true;
    _isTransitioning = false;
    _canTap = false;

    // Start transition timer
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _triggerTransition();
      }
    });
  }

  void _triggerTransition() {
    setState(() {
      _isTransitioning = true;
    });

    // Simulate "Blinking eyes" transition
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isShowingOriginal = false;
          _isTransitioning = false;
          _canTap = true;
          _gameStartTime = DateTime.now();
        });
      }
    });
  }

  void _onItemTap(int index) {
    if (!_canTap) return;

    _attempts++;
    if (index == _changedIndex) {
      // Correct!
      _finishGame();
    } else {
      // Mistake
      setState(() {
        _mistakes++;
      });
      final appState = Provider.of<AppState>(context, listen: false);
      appState.speakPrompt(appState.currentLanguage == 'hi-IN' ? "नहीं, वह नहीं बदला। ध्यान से देखें।" : "Not that one. Look closer!");
    }
  }

  void _finishGame() {
    final endTime = DateTime.now();
    final duration = _gameStartTime != null
        ? endTime.difference(_gameStartTime!).inMilliseconds
        : 5000;

    double accuracy = _attempts > 0 ? 1.0 / (_mistakes + 1) : 1.0;

    final metric = GameMetric(
      gameId: 'what_changed',
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
            const Icon(Icons.psychology, color: Colors.indigo, size: 70),
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
          appState.translate('what_changed'),
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
                    ? "अलमारी की मूल वस्तुओं को देखें। आंखों के झपकने के बाद, खाली डिब्बे पर दबाएं कि कौन सा सामान वहां से हटाया गया।"
                    : "Look at the items. After the transition, tap on the box where the item is missing.";
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
            const SizedBox(height: 25),

            // Game state title
            Text(
              _isTransitioning
                  ? "Blinking eyes... (Blink)"
                  : _isShowingOriginal
                      ? "Memorize the items on the shelf!"
                      : "Tap the box where the item is missing!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _isShowingOriginal ? const Color(0xFF7D5A50) : Colors.indigo.shade800,
              ),
            ),
            const SizedBox(height: 40),

            // Shelf Scene
            Expanded(
              child: _isTransitioning
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.remove_red_eye_outlined, size: 80, color: Colors.white54),
                            SizedBox(height: 16),
                            Text(
                              "Blinking...",
                              style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        // Wooden shelf design
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8D7B68).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: const Color(0xFF8D7B68), width: 3),
                          ),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: _itemCount <= 4 ? 2 : 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: _itemCount,
                            itemBuilder: (context, idx) {
                              final item = _isShowingOriginal ? _originalItems[idx] : _currentItems[idx];
                              final bool isChangedSlot = !_isShowingOriginal && idx == _changedIndex;

                              return GestureDetector(
                                onTap: () => _onItemTap(idx),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isChangedSlot
                                        ? Colors.white.withOpacity(0.5)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isChangedSlot
                                          ? Colors.redAccent.withOpacity(0.4)
                                          : Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item['icon'],
                                        size: 48,
                                        color: item['color'],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        item['label'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7D5A50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Wooden shelf base accent
                        Container(
                          height: 15,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF8D7B68),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
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
