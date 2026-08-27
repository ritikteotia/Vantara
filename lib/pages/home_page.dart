import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../services/tts_service.dart';
import '../games/memory_match.dart';
import '../games/sequence_recall.dart';
import '../games/what_changed.dart';
import '../games/object_recognition.dart';
import '../games/routine_recall.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openReminderStory(BuildContext context, Reminder reminder) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return ReminderStoryView(reminder: reminder);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final themeColor = const Color(0xFF8D7B68);

    if (appState.reminders.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFFAF7F2),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get active/completed reminder statuses
    final medicineRem = appState.reminders.firstWhere((r) => r.id == 'rem_med');
    final hydrationRem = appState.reminders.firstWhere((r) => r.id == 'rem_hyd');
    final walkRem = appState.reminders.firstWhere((r) => r.id == 'rem_walk');
    final apptRem = appState.reminders.firstWhere((r) => r.id == 'rem_appt');

    // Calculate game to recommend (based on lowest difficulty or simple rotation)
    String recommendedGameId = 'memory_match';
    String recommendedGameName = appState.translate('memory_match');
    Widget recommendedGameWidget = const MemoryMatchGame();

    final diffs = appState.gameDifficulties;
    int minVal = 100;
    diffs.forEach((key, val) {
      if (val < minVal) {
        minVal = val;
        recommendedGameId = key;
      }
    });

    if (recommendedGameId == 'sequence_recall') {
      recommendedGameName = appState.translate('sequence_recall');
      recommendedGameWidget = const SequenceRecallGame();
    } else if (recommendedGameId == 'what_changed') {
      recommendedGameName = appState.translate('what_changed');
      recommendedGameWidget = const WhatChangedGame();
    } else if (recommendedGameId == 'object_recognition') {
      recommendedGameName = appState.translate('object_recognition');
      recommendedGameWidget = const ObjectRecognitionGame();
    } else if (recommendedGameId == 'routine_recall') {
      recommendedGameName = appState.translate('routine_recall');
      recommendedGameWidget = const RoutineRecallGame();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2), // Warm, soft background
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.translate('app_name'),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7D5A50),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Text(
                        "Cognitive Companion",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  // Connection Indicator Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: appState.isOnline ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: appState.isOnline ? Colors.green.shade200 : Colors.orange.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: appState.isOnline ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appState.isOnline ? "Online" : "Offline",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: appState.isOnline ? Colors.green.shade800 : Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Instagram-story style Reminders section
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildStoryItem(context, medicineRem, Icons.medication, Colors.redAccent, _openReminderStory),
                  _buildStoryItem(context, hydrationRem, Icons.local_drink, Colors.blueAccent, _openReminderStory),
                  _buildStoryItem(context, walkRem, Icons.directions_walk, Colors.teal, _openReminderStory),
                  _buildStoryItem(context, apptRem, Icons.calendar_today, Colors.purple, _openReminderStory),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient Welcoming card with Voice
                    GestureDetector(
                      onTap: () {
                        appState.speakPrompt(appState.currentLanguage == 'hi-IN'
                            ? "नमस्ते! आज आपका दिन बहुत अच्छा हो। आइए नीचे दिए गए आज के दिमागी व्यायाम खेल से शुरू करते हैं।"
                            : "Hello! Hope you are having a wonderful day. Let's start with today's brain exercise game below.");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3EFE0),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: themeColor,
                              child: const Icon(Icons.volume_up, size: 36, color: Colors.white),
                            ),
                            const SizedBox(width: 20),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hello, Elder!",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF7D5A50),
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    "Tap me to hear today's greeting and instructions.",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF7D5A50),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Today's Recommended game block
                    Text(
                      appState.translate('recommended_game'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7D5A50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          )
                        ],
                        border: Border.all(color: const Color(0xFFE6DED4), width: 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                recommendedGameName,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7D5A50),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAF7F2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Level ${appState.gameDifficulties[recommendedGameId] ?? 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7D5A50),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            appState.translate('recommended_game_desc'),
                            style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 1,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => recommendedGameWidget),
                                );
                              },
                              child: Text(
                                appState.translate('play_button'),
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Reminders Checklist
                    Text(
                      appState.translate('reminders_title'),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7D5A50),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...appState.reminders.map((reminder) {
                      IconData iconData = Icons.medication;
                      Color rColor = Colors.redAccent;
                      if (reminder.type == ReminderType.hydration) {
                        iconData = Icons.local_drink;
                        rColor = Colors.blueAccent;
                      } else if (reminder.type == ReminderType.activity) {
                        iconData = Icons.directions_walk;
                        rColor = Colors.teal;
                      } else if (reminder.type == ReminderType.appointment) {
                        iconData = Icons.calendar_today;
                        rColor = Colors.purple;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: reminder.isCompleted
                                ? Colors.green.shade200
                                : const Color(0xFFE6DED4),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: rColor.withOpacity(0.1),
                              child: Icon(iconData, color: rColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reminder.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF7D5A50),
                                      decoration: reminder.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reminder.time,
                                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            // Checkbox/Completion button
                            IconButton(
                              icon: Icon(
                                reminder.isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 30,
                                color: reminder.isCompleted ? Colors.green : Colors.grey,
                              ),
                              onPressed: () {
                                appState.toggleReminder(reminder.id);
                              },
                            )
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryItem(
    BuildContext context,
    Reminder reminder,
    IconData icon,
    Color color,
    Function(BuildContext, Reminder) onTap,
  ) {
    final ringColor = reminder.isCompleted ? Colors.green : Colors.deepOrange;

    return GestureDetector(
      onTap: () => onTap(context, reminder),
      child: Padding(
        padding: const EdgeInsets.only(right: 18.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: reminder.isCompleted
                    ? const LinearGradient(
                        colors: [Colors.green, Colors.greenAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Colors.pinkAccent, Colors.orangeAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFFFAF7F2),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, size: 32, color: color),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              reminder.title.split(' ')[0], // First word
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: reminder.isCompleted ? Colors.green.shade700 : const Color(0xFF7D5A50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fullscreen Instagram Story Modal for Reminders
class ReminderStoryView extends StatefulWidget {
  final Reminder reminder;
  const ReminderStoryView({super.key, required this.reminder});

  @override
  State<ReminderStoryView> createState() => _ReminderStoryViewState();
}

class _ReminderStoryViewState extends State<ReminderStoryView> {
  double _progress = 0.0;
  Timer? _storyTimer;
  final int _durationSeconds = 15; // 15s standard story

  @override
  void initState() {
    super.initState();
    // Play voice prompt
    final appState = Provider.of<AppState>(context, listen: false);
    appState.speakReminder(widget.reminder);

    // Start story progress bar
    _startStory();
  }

  void _startStory() {
    const int updateMs = 50;
    int totalUpdates = (_durationSeconds * 1000) ~/ updateMs;
    int currentUpdate = 0;

    _storyTimer = Timer.periodic(const Duration(milliseconds: updateMs), (timer) {
      if (mounted) {
        setState(() {
          currentUpdate++;
          _progress = currentUpdate / totalUpdates;
          if (_progress >= 1.0) {
            timer.cancel();
            _snoozeReminder();
          }
        });
      }
    });
  }

  void _completeReminder() {
    _storyTimer?.cancel();
    final appState = Provider.of<AppState>(context, listen: false);
    if (!widget.reminder.isCompleted) {
      appState.toggleReminder(widget.reminder.id);
    }
    Navigator.of(context).pop();
  }

  void _snoozeReminder() {
    _storyTimer?.cancel();
    // Stop speaking if currently speaking
    TtsService().stop();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _storyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    IconData iconData = Icons.medication;
    Color rColor = Colors.redAccent;
    if (widget.reminder.type == ReminderType.hydration) {
      iconData = Icons.local_drink;
      rColor = Colors.blueAccent;
    } else if (widget.reminder.type == ReminderType.activity) {
      iconData = Icons.directions_walk;
      rColor = Colors.teal;
    } else if (widget.reminder.type == ReminderType.appointment) {
      iconData = Icons.calendar_today;
      rColor = Colors.purple;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Story Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 5,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                ),
              ),
            ),

            // Top exit bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: rColor,
                        child: Icon(iconData, size: 20, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.reminder.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: _snoozeReminder,
                  )
                ],
              ),
            ),
            const Spacer(),

            // Centered huge icon & text instructions
            Column(
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundColor: rColor.withOpacity(0.2),
                  child: Icon(
                    iconData,
                    size: 90,
                    color: rColor,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    widget.reminder.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    appState.currentLanguage == 'hi-IN'
                        ? (widget.reminder.title.contains('Water')
                            ? "कृपया पानी पी लीजिए। स्वस्थ रहने के लिए हाइड्रेशन जरूरी है।"
                            : widget.reminder.title.contains('Medicine')
                                ? "दवाई लेने का समय हो गया है। कृपया अपनी लाल रंग की गोली खा लीजिए।"
                                : widget.reminder.title.contains('Walk')
                                    ? "शाम की सैर का समय है। चलो पार्क चलते हैं।"
                                    : "आज डॉक्टर के पास जाने का समय है।")
                        : widget.reminder.speechPrompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 22,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Speaker prompt play button
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 45, color: Colors.amber),
                  onPressed: () {
                    appState.speakReminder(widget.reminder);
                  },
                ),
              ],
            ),
            const Spacer(),

            // Bottom large CTA buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 65,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white54, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _snoozeReminder,
                        child: Text(
                          appState.translate('snooze'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 65,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _completeReminder,
                        child: Text(
                          appState.translate('mark_done'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
