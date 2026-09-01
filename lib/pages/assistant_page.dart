import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/glass_theme.dart';
import '../games/memory_match.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _lastResponse = "";
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.14).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _onMicTap() {
    if (_isListening) return;

    final appState = Provider.of<AppState>(context, listen: false);

    setState(() {
      _isListening = true;
      _lastResponse = "";
    });
    _pulseController.repeat(reverse: true);

    // Simulated voice recognition
    Timer(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      _pulseController.stop();
      _pulseController.reset();

      final responseText = appState.currentLanguage == 'hi-IN'
          ? "नमस्ते अम्मा! मैंने आपके लिए मेमोरी मैच गेम की सिफारिश की है। आप कभी भी खेल सकती हैं।"
          : "Hello Amma! I'm right here. I recommend starting today's Memory Match game to keep your memory sharp.";

      setState(() {
        _isListening = false;
        _lastResponse = responseText;
      });

      appState.speakPrompt(responseText);
    });
  }

  void _triggerPrompt(String promptKey) {
    final appState = Provider.of<AppState>(context, listen: false);

    if (promptKey == 'game') {
      final msg = appState.currentLanguage == 'hi-IN'
          ? "मेमोरी मैच गेम शुरू कर रहा हूँ।"
          : "Starting your Memory Match game now.";
      setState(() => _lastResponse = msg);
      appState.speakPrompt(msg);
      Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MemoryMatchGame()),
          );
        }
      });
    } else if (promptKey == 'reminder') {
      final rem = appState.reminders.firstWhere((r) => !r.isCompleted,
          orElse: () => appState.reminders.first);
      final msg = appState.currentLanguage == 'hi-IN'
          ? "आपका अगला रिमाइंडर ${rem.title} का है, समय ${rem.time}।"
          : "Your next reminder is ${rem.title} scheduled for ${rem.time}.";
      setState(() => _lastResponse = msg);
      appState.speakPrompt(msg);
    } else if (promptKey == 'plan') {
      final msg = appState.currentLanguage == 'hi-IN'
          ? "आज की योजना: 4 रिमाइंडर और 3 दिमागी खेल।"
          : "Today's plan: You have 4 reminders and 3 cognitive games scheduled.";
      setState(() => _lastResponse = msg);
      appState.speakPrompt(msg);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: VantaraColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appState.translate('assistant'),
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
                          ? "मैं आपकी सहायता के लिए यहाँ हूँ"
                          : "I'm here to help you",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: VantaraColors.textSub,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Mascot / Soundwave Center Avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  // Sound wave lines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildWaveBar(16),
                      const SizedBox(width: 4),
                      _buildWaveBar(28),
                      const SizedBox(width: 4),
                      _buildWaveBar(44),
                      const SizedBox(width: 4),
                      _buildWaveBar(22),
                      const SizedBox(width: 140), // Gap for Mascot
                      _buildWaveBar(22),
                      const SizedBox(width: 4),
                      _buildWaveBar(44),
                      const SizedBox(width: 4),
                      _buildWaveBar(28),
                      const SizedBox(width: 4),
                      _buildWaveBar(16),
                    ],
                  ),
                  // Mascot circle (Sprout character)
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF3EFE0),
                      border: Border.all(
                        color: VantaraColors.primaryGreen.withValues(alpha: 0.25),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.eco_rounded,
                            size: 48,
                            color: VantaraColors.primaryGreen,
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("•", style: TextStyle(fontSize: 18, color: VantaraColors.textDark)),
                              SizedBox(width: 10),
                              Text("‿", style: TextStyle(fontSize: 16, color: VantaraColors.textDark, fontWeight: FontWeight.bold)),
                              SizedBox(width: 10),
                              Text("•", style: TextStyle(fontSize: 18, color: VantaraColors.textDark)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Status / Response text
              if (_lastResponse.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: VantaraColors.border),
                  ),
                  child: Text(
                    _lastResponse,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: VantaraColors.textDark,
                      height: 1.4,
                    ),
                  ),
                ),

              // "You can say things like" Title
              Text(
                appState.currentLanguage == 'hi-IN'
                    ? "आप इस तरह कह सकते हैं"
                    : "You can say things like",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: VantaraColors.textSub,
                ),
              ),
              const SizedBox(height: 14),

              // Suggestion Pills
              _buildSuggestionPill(
                icon: Icons.volume_up_rounded,
                text: appState.currentLanguage == 'hi-IN'
                    ? "दिमागी खेल शुरू करें"
                    : "Start memory game",
                onTap: () => _triggerPrompt('game'),
              ),
              const SizedBox(height: 10),
              _buildSuggestionPill(
                icon: Icons.volume_up_rounded,
                text: appState.currentLanguage == 'hi-IN'
                    ? "मेरा अगला रिमाइंडर क्या है?"
                    : "What's my next reminder?",
                onTap: () => _triggerPrompt('reminder'),
              ),
              const SizedBox(height: 10),
              _buildSuggestionPill(
                icon: Icons.volume_up_rounded,
                text: appState.currentLanguage == 'hi-IN'
                    ? "मुझे आज की योजना बताएं"
                    : "Tell me today's plan",
                onTap: () => _triggerPrompt('plan'),
              ),
              const SizedBox(height: 32),

              // Big Green Microphone Button
              GestureDetector(
                onTap: _onMicTap,
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) {
                    final scale = _isListening ? _pulseAnim.value : 1.0;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening
                          ? const Color(0xFFE56B6F)
                          : VantaraColors.primaryGreen,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening
                                  ? const Color(0xFFE56B6F)
                                  : VantaraColors.primaryGreen)
                              .withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isListening
                    ? (appState.currentLanguage == 'hi-IN'
                        ? "सुन रहा हूँ..."
                        : "Listening...")
                    : (appState.currentLanguage == 'hi-IN'
                        ? "बोलने के लिए माइक दबाएँ"
                        : "Tap mic to speak"),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: VantaraColors.textSub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveBar(double height) {
    return Container(
      width: 3.5,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFD4C9BC),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSuggestionPill({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EFE0),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: VantaraColors.border, width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: VantaraColors.primaryGreen),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: VantaraColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
