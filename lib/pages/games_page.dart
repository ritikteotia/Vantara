import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/glass_theme.dart';
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

    final List<Map<String, dynamic>> gamesList = [
      {
        'id': 'memory_match',
        'title': appState.translate('memory_match'),
        'desc': 'Remember and match objects',
        'icon': Icons.psychology_rounded,
        'iconColor': const Color(0xFF8E7CC3),
        'bgColor': const Color(0xFFF3EEFA),
        'widget': const MemoryMatchGame(),
        'focus': 'Short-term Memory'
      },
      {
        'id': 'sequence_recall',
        'title': appState.translate('sequence_recall'),
        'desc': 'Remember the correct sequence',
        'icon': Icons.motion_photos_on_rounded,
        'iconColor': const Color(0xFF4E7A51),
        'bgColor': const Color(0xFFE8F1E7),
        'widget': const SequenceRecallGame(),
        'focus': 'Attention & Memory'
      },
      {
        'id': 'what_changed',
        'title': appState.translate('what_changed'),
        'desc': 'Find the changes in the scene',
        'icon': Icons.landscape_rounded,
        'iconColor': const Color(0xFFF4A261),
        'bgColor': const Color(0xFFFEF3EA),
        'widget': const WhatChangedGame(),
        'focus': 'Visual Recall'
      },
      {
        'id': 'object_recognition',
        'title': appState.translate('object_recognition'),
        'desc': 'Identify the correct object',
        'icon': Icons.apple_rounded,
        'iconColor': const Color(0xFFE56B6F),
        'bgColor': const Color(0xFFFDE8E9),
        'widget': const ObjectRecognitionGame(),
        'focus': 'Semantic Memory'
      },
      {
        'id': 'routine_recall',
        'title': appState.translate('routine_recall'),
        'desc': 'Answer questions about your daily routine',
        'icon': Icons.calendar_month_rounded,
        'iconColor': const Color(0xFF4EA8DE),
        'bgColor': const Color(0xFFE7F3FB),
        'widget': const RoutineRecallGame(),
        'focus': 'Orientation to Daily Life'
      },
    ];

    return Scaffold(
      backgroundColor: VantaraColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                appState.translate('games'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: VantaraColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                appState.currentLanguage == 'hi-IN'
                    ? "खेलने के लिए एक खेल चुनें"
                    : "Choose a game to play",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: VantaraColors.textSub,
                ),
              ),
              const SizedBox(height: 20),

              // Game cards list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 110),
                  itemCount: gamesList.length,
                  itemBuilder: (context, index) {
                    final game = gamesList[index];
                    final currentLvl = appState.gameDifficulties[game['id']] ?? 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => game['widget']),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: VantaraColors.border, width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Icon Squircle Container
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: game['bgColor'] as Color,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Icon(
                                    game['icon'] as IconData,
                                    size: 32,
                                    color: game['iconColor'] as Color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Title & Description
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
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: VantaraColors.textDark,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: VantaraColors.background,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'Lvl $currentLvl',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: game['iconColor'] as Color,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      game['desc'],
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: VantaraColors.textSub,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: VantaraColors.textGrey,
                                size: 28,
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
