import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class SequenceRecallGame extends StatefulWidget {
  const SequenceRecallGame({super.key});

  @override
  State<SequenceRecallGame> createState() => _SequenceRecallGameState();
}

class _SequenceRecallGameState extends State<SequenceRecallGame> {
  late int _difficulty;
  List<int> _sequence = [];
  final List<int> _playerInput = [];
  bool _isPlayingSequence = true;
  int _activeHighlightIndex = -1;
  int _sequenceLength = 3;

  // Metrics
  DateTime? _gameStartTime;
  int _mistakes = 0;
  int _attempts = 0;

  final List<Map<String, dynamic>> _blocks = [
    {'name': 'Tea Garden', 'color': Colors.green.shade600, 'icon': Icons.eco},
    {'name': 'Bihu Drum', 'color': Colors.red.shade600, 'icon': Icons.music_note},
    {'name': 'Bamboo Mug', 'color': Colors.amber.shade700, 'icon': Icons.coffee},
    {'name': 'Hornbill', 'color': Colors.blue.shade600, 'icon': Icons.emoji_nature},
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _difficulty = appState.gameDifficulties['sequence_recall'] ?? 1;
    _sequenceLength = _difficulty + 1; // Level 1 = 2 items, Level 5 = 6 items

    // Speak initial welcome instruction
    String welcomeMsg = appState.currentLanguage == 'hi-IN'
        ? "क्रम याद रखें। रंगीन खानों के चमकने के क्रम को दोहराएं।"
        : appState.currentLanguage == 'as-IN'
            ? "ক্ৰম মনত ৰাখক। জিলিকি উঠা বাকচকেইটাৰ ক্ৰমটো আকৌ টিপক।"
            : "Remember the sequence. Tap the blocks in the exact order they blink.";
    appState.speakPrompt(welcomeMsg);

    _generateSequence();
  }

  void _generateSequence() {
    final rand = javaScriptLikeRandom();
    _sequence = List.generate(_sequenceLength, (index) => rand.nextInt(4));
    _playerInput.clear();
    _isPlayingSequence = true;
    _attempts++;

    // Wait a moment then play the sequence
    Timer(const Duration(milliseconds: 1500), () {
      _playSequence();
    });
  }

  // Pure Dart simple pseudo-random generator to avoid external dependency issues
  _Rand javaScriptLikeRandom() {
    return _Rand(DateTime.now().millisecondsSinceEpoch);
  }

  void _playSequence() async {
    if (!mounted) return;
    _gameStartTime = DateTime.now();
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() {
        _activeHighlightIndex = _sequence[i];
      });
      // Play a small tone/vibration representation
      // We can trigger TTS briefly or just display
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _activeHighlightIndex = -1;
      });
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (!mounted) return;
    setState(() {
      _isPlayingSequence = false;
    });
  }

  void _onBlockTap(int blockIndex) {
    if (_isPlayingSequence) return;

    setState(() {
      _activeHighlightIndex = blockIndex;
      _playerInput.add(blockIndex);
    });

    // Reset highlight after tap
    Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _activeHighlightIndex = -1;
        });
      }
    });

    // Check correctness
    int currentStep = _playerInput.length - 1;
    if (_playerInput[currentStep] != _sequence[currentStep]) {
      // WRONG TAP!
      _mistakes++;
      // Speak warning
      final appState = Provider.of<AppState>(context, listen: false);
      appState.speakPrompt(appState.currentLanguage == 'hi-IN' ? "गलत! पुनः प्रयास करें।" : "Oops! Try to remember the sequence.");

      setState(() {
        _playerInput.clear();
        _isPlayingSequence = true;
      });
      // Re-play sequence
      Timer(const Duration(milliseconds: 1200), () {
        _playSequence();
      });
      return;
    }

    if (_playerInput.length == _sequence.length) {
      // Completed successfully!
      _finishGame();
    }
  }

  void _finishGame() {
    final endTime = DateTime.now();
    final duration = _gameStartTime != null
        ? endTime.difference(_gameStartTime!).inMilliseconds
        : 8000;

    double accuracy = _attempts > 0 ? 1.0 / (_mistakes + 1) : 1.0;

    final metric = GameMetric(
      gameId: 'sequence_recall',
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
          appState.translate('sequence_recall'),
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
                    ? "चमकते खानों के अनुक्रम को ध्यान से देखें और उसी क्रम में दबाएं।"
                    : "Watch the blocks flash, then repeat the sequence in the same order.";
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
            const SizedBox(height: 30),

            // Instruction prompt
            Text(
              _isPlayingSequence
                ? "Watching the pattern..."
                : "Your Turn! Repeat the sequence (${_playerInput.length}/${_sequence.length})",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _isPlayingSequence ? const Color(0xFF7D5A50) : Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 40),

            // 2x2 Grid of sequence blocks
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.0,
                ),
                itemCount: 4,
                itemBuilder: (context, idx) {
                  final block = _blocks[idx];
                  final isHighlighted = _activeHighlightIndex == idx;

                  return GestureDetector(
                    onTapDown: (_) => _onBlockTap(idx),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? block['color']
                            : block['color'].withOpacity(0.35),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: isHighlighted ? Colors.white : block['color'],
                          width: 5,
                        ),
                        boxShadow: isHighlighted
                            ? [
                                BoxShadow(
                                  color: block['color'].withOpacity(0.5),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                )
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            block['icon'],
                            size: 55,
                            color: isHighlighted ? Colors.white : block['color'].withOpacity(0.8),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            block['name'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isHighlighted ? Colors.white : const Color(0xFF7D5A50),
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
