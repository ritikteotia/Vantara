import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';
import '../services/tts_service.dart';
import '../theme/glass_theme.dart';
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
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return ReminderStoryView(reminder: reminder);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (appState.reminders.isEmpty) {
      return const Scaffold(
        backgroundColor: VantaraColors.background,
        body: Center(
          child: CircularProgressIndicator(color: VantaraColors.primaryGreen),
        ),
      );
    }

    // Get active/completed reminder references
    final medicineRem = appState.reminders.firstWhere((r) => r.id == 'rem_med',
        orElse: () => appState.reminders[0]);
    final hydrationRem = appState.reminders.firstWhere((r) => r.id == 'rem_hyd',
        orElse: () => appState.reminders[1]);
    final walkRem = appState.reminders.firstWhere((r) => r.id == 'rem_walk',
        orElse: () => appState.reminders[2]);
    final apptRem = appState.reminders.firstWhere((r) => r.id == 'rem_appt',
        orElse: () => appState.reminders[3]);

    // Calculate recommended game
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
      backgroundColor: VantaraColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header (Good Morning Amma + Avatar) ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appState.currentLanguage == 'hi-IN'
                            ? "सुप्रभात,"
                            : "Good Morning,",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: VantaraColors.textSub,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: const [
                          Text(
                            "Amma",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: VantaraColors.textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text("👋", style: TextStyle(fontSize: 26)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appState.currentLanguage == 'hi-IN'
                            ? "आइए आज का दिन शानदार बनाएं!"
                            : "Let's make today great!",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: VantaraColors.textSub,
                        ),
                      ),
                    ],
                  ),
                  // Avatar Profile Ring
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF3EFE0),
                      border: Border.all(
                        color: VantaraColors.primaryGreen.withValues(alpha: 0.3),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.face_3_rounded,
                        size: 40,
                        color: Color(0xFF8D7B68),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Section: Today's Reminders [See All] ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appState.translate('reminders_title'),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: VantaraColors.textDark,
                    ),
                  ),
                  Text(
                    "See All",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: VantaraColors.primaryGreen.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 4 Reminder Cards Row (Medicine, Hydration, Daily Activity, Appointment)
              Row(
                children: [
                  Expanded(
                    child: _buildReminderCard(
                      context: context,
                      reminder: medicineRem,
                      icon: Icons.medication_rounded,
                      iconColor: VantaraColors.medicineColor,
                      bgColor: VantaraColors.medicineBg,
                      title: "Medicine",
                      time: medicineRem.time,
                      onTap: () => _openReminderStory(context, medicineRem),
                      onToggle: () => appState.toggleReminder(medicineRem.id),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildReminderCard(
                      context: context,
                      reminder: hydrationRem,
                      icon: Icons.local_drink_rounded,
                      iconColor: VantaraColors.hydrationColor,
                      bgColor: VantaraColors.hydrationBg,
                      title: "Hydration",
                      time: hydrationRem.time,
                      onTap: () => _openReminderStory(context, hydrationRem),
                      onToggle: () => appState.toggleReminder(hydrationRem.id),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildReminderCard(
                      context: context,
                      reminder: walkRem,
                      icon: Icons.directions_walk_rounded,
                      iconColor: VantaraColors.activityColor,
                      bgColor: VantaraColors.activityBg,
                      title: "Daily Activity",
                      time: walkRem.time,
                      onTap: () => _openReminderStory(context, walkRem),
                      onToggle: () => appState.toggleReminder(walkRem.id),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildReminderCard(
                      context: context,
                      reminder: apptRem,
                      icon: Icons.calendar_today_rounded,
                      iconColor: VantaraColors.appointmentColor,
                      bgColor: VantaraColors.appointmentBg,
                      title: "Appointment",
                      time: apptRem.time,
                      onTap: () => _openReminderStory(context, apptRem),
                      onToggle: () => appState.toggleReminder(apptRem.id),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Banner: Talk to Vantara ──
              GestureDetector(
                onTap: () {
                  appState.speakPrompt(appState.currentLanguage == 'hi-IN'
                      ? "नमस्ते अम्मा! आज आपका दिन बहुत अच्छा हो। आइए आज के दिमागी खेल शुरू करते हैं।"
                      : "Good morning Amma! Hope you're feeling great today. Let's start with today's brain exercises.");
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: VantaraColors.primaryGreen,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: VantaraColors.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appState.currentLanguage == 'hi-IN'
                                  ? "वंतारा से बात करें"
                                  : "Talk to Vantara",
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              appState.currentLanguage == 'hi-IN'
                                  ? "बोलने के लिए यहाँ दबाएँ"
                                  : "Tap to speak",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Section: Today's Plan [View Plan] ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    appState.currentLanguage == 'hi-IN'
                        ? "आज की योजना"
                        : "Today's Plan",
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: VantaraColors.textDark,
                    ),
                  ),
                  Text(
                    "View Plan",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: VantaraColors.primaryGreen.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Today's Plan Card (Brain exercise + Launch button)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: VantaraColors.border, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Brain Icon in soft lavender squircle
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3EEFA),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.psychology_rounded,
                          size: 36,
                          color: Color(0xFF8E7CC3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title and subtext
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.currentLanguage == 'hi-IN'
                                ? "आज 3 खेल निर्धारित हैं"
                                : "You have 3 games scheduled today",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: VantaraColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$recommendedGameName (Lvl ${appState.gameDifficulties[recommendedGameId] ?? 1})",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: VantaraColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action button (arrow)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => recommendedGameWidget),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: VantaraColors.primaryGreen,
                          boxShadow: [
                            BoxShadow(
                              color: VantaraColors.primaryGreen.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
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
  }

  Widget _buildReminderCard({
    required BuildContext context,
    required Reminder reminder,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String time,
    required VoidCallback onTap,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: reminder.isCompleted
                ? VantaraColors.primaryGreen.withValues(alpha: 0.4)
                : VantaraColors.border,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top icon in soft tinted circle
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: reminder.isCompleted
                    ? VantaraColors.textSub
                    : VantaraColors.textDark,
                decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            const SizedBox(height: 2),
            // Time
            Text(
              time,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: VantaraColors.textSub,
              ),
            ),
            const SizedBox(height: 8),
            // Circular Checkbox Toggle
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: reminder.isCompleted
                      ? VantaraColors.primaryGreen
                      : Colors.transparent,
                  border: Border.all(
                    color: reminder.isCompleted
                        ? VantaraColors.primaryGreen
                        : VantaraColors.border,
                    width: 1.8,
                  ),
                ),
                child: reminder.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  FULLSCREEN REMINDER STORY MODAL
// ─────────────────────────────────────────────

class ReminderStoryView extends StatefulWidget {
  final Reminder reminder;
  const ReminderStoryView({super.key, required this.reminder});

  @override
  State<ReminderStoryView> createState() => _ReminderStoryViewState();
}

class _ReminderStoryViewState extends State<ReminderStoryView> {
  double _progress = 0.0;
  Timer? _storyTimer;
  final int _durationSeconds = 15;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    appState.speakReminder(widget.reminder);
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
    IconData iconData = Icons.medication_rounded;
    Color rColor = VantaraColors.medicineColor;
    if (widget.reminder.type == ReminderType.hydration) {
      iconData = Icons.local_drink_rounded;
      rColor = VantaraColors.hydrationColor;
    } else if (widget.reminder.type == ReminderType.activity) {
      iconData = Icons.directions_walk_rounded;
      rColor = VantaraColors.activityColor;
    } else if (widget.reminder.type == ReminderType.appointment) {
      iconData = Icons.calendar_today_rounded;
      rColor = VantaraColors.appointmentColor;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E221E),
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
                  minHeight: 4,
                  backgroundColor: Colors.white24,
                  color: VantaraColors.primaryGreen,
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
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: _snoozeReminder,
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Center icon & instructions
            Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundColor: rColor.withValues(alpha: 0.2),
                  child: Icon(iconData, size: 80, color: rColor),
                ),
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    widget.reminder.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    appState.currentLanguage == 'hi-IN'
                        ? (widget.reminder.title.contains('Water')
                            ? "कृपया पानी पी लीजिए। स्वस्थ रहने के लिए हाइड्रेशन जरूरी है।"
                            : widget.reminder.title.contains('Medicine')
                                ? "दवाई लेने का समय हो गया है। कृपया अपनी गोली खा लीजिए।"
                                : widget.reminder.title.contains('Walk')
                                    ? "शाम की सैर का समय है। चलो पार्क चलते हैं।"
                                    : "आज डॉक्टर के पास जाने का समय है।")
                        : widget.reminder.speechPrompt,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded, size: 44, color: Colors.amberAccent),
                  onPressed: () => appState.speakReminder(widget.reminder),
                ),
              ],
            ),
            const Spacer(),

            // Bottom CTA buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white38, width: 1.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _snoozeReminder,
                        child: Text(
                          appState.translate('snooze'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VantaraColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _completeReminder,
                        child: Text(
                          appState.translate('mark_done'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
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
