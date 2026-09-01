import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../games/memory_match.dart';
import '../games/sequence_recall.dart';
import '../games/what_changed.dart';
import '../games/object_recognition.dart';
import '../games/routine_recall.dart';

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // List of games config
    final List<Map<String, dynamic>> gamesList = [
      {
        'id': 'memory_match',
        'title': appState.translate('memory_match'),
        'desc': 'Remember and match familiar regional objects.',
        'icon': Icons.grid_view_rounded,
        'color': Colors.orange.shade700,
        'widget': const MemoryMatchGame(),
        'focus': 'Short-term Memory'
      },
      {
        'id': 'sequence_recall',
        'title': appState.translate('sequence_recall'),
        'desc': 'Repeat sequences of sounds, colors, and patterns.',
        'icon': Icons.repeat_on_rounded,
        'color': Colors.red.shade700,
        'widget': const SequenceRecallGame(),
        'focus': 'Attention & Memory'
      },
      {
        'id': 'what_changed',
        'title': appState.translate('what_changed'),
        'desc': 'Spot the subtle differences on a traditional shelf.',
        'icon': Icons.psychology_rounded,
        'color': Colors.indigo.shade700,
        'widget': const WhatChangedGame(),
        'focus': 'Visual Recall'
      },
      {
        'id': 'object_recognition',
        'title': appState.translate('object_recognition'),
        'desc': 'Identify regional items from multiple options.',
        'icon': Icons.image_search_rounded,
        'color': Colors.teal.shade700,
        'widget': const ObjectRecognitionGame(),
        'focus': 'Semantic Memory'
      },
      {
        'id': 'routine_recall',
        'title': appState.translate('routine_recall'),
        'desc': 'Answer questions about your scheduled daily routines.',
        'icon': Icons.assignment_turned_in_rounded,
        'color': Colors.brown.shade700,
        'widget': const RoutineRecallGame(),
        'focus': 'Orientation to Daily Life'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.translate('games'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7D5A50),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Keep your mind active and trained with daily challenges.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // List of games cards
              Expanded(
                child: ListView.builder(
                  itemCount: gamesList.length,
                  itemBuilder: (context, index) {
                    final game = gamesList[index];
                    final currentLvl = appState.gameDifficulties[game['id']] ?? 1;

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: const BorderSide(color: Color(0xFFE6DED4), width: 1.5),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => game['widget']),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: game['color'].withOpacity(0.1),
                                child: Icon(game['icon'], size: 36, color: game['color']),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            game['title'],
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF7D5A50),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFAF7F2),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: const Color(0xFFE6DED4)),
                                          ),
                                          child: Text(
                                            'Lvl $currentLvl',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF7D5A50),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      game['desc'],
                                      style: TextStyle(fontSize: 15, color: Colors.grey.shade600, height: 1.3),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Target: ${game['focus']}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: game['color'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
