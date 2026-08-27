import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  bool _isListening = false;
  List<Map<String, dynamic>> _messages = [];
  Timer? _waveTimer;
  double _waveHeight = 20.0;

  @override
  void initState() {
    super.initState();
    // Pre-populate with first greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      setState(() {
        _messages = [
          {
            'isUser': false,
            'text': appState.translate('assistant_greeting'),
          }
        ];
      });
    });
  }

  void _onMicTap() {
    if (_isListening) return;

    final appState = Provider.of<AppState>(context, listen: false);

    setState(() {
      _isListening = true;
      _waveHeight = 35.0;
    });

    // Start wave animation simulation
    _waveTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (mounted) {
        setState(() {
          _waveHeight = _waveHeight == 35.0 ? 15.0 : 40.0;
        });
      }
    });

    // Speak simulated voice response after 2.5 seconds
    Timer(const Duration(milliseconds: 2500), () {
      _waveTimer?.cancel();
      if (!mounted) return;

      setState(() {
        _isListening = false;
        // User speech simulation
        _messages.add({
          'isUser': true,
          'text': appState.currentLanguage == 'hi-IN' ? "मुझे आज के खेल खेलने हैं" : "I want to play my daily games."
        });
      });

      // Assistant responds
      Timer(const Duration(milliseconds: 1000), () {
        if (!mounted) return;
        String responseText = appState.currentLanguage == 'hi-IN'
            ? "ज़रूर! खेल टैब पर जाएँ, या यहाँ दबाएँ। मैंने आपके मस्तिष्क को सक्रिय रखने के लिए मेमोरी मैच गेम की सिफारिश की है।"
            : "Sure! Go to the Games tab, or tap here. I highly recommend playing Memory Match today to keep your brain active.";

        setState(() {
          _messages.add({
            'isUser': false,
            'text': responseText
          });
        });

        // Play voice
        appState.speakPrompt(responseText);
      });
    });
  }

  @override
  void dispose() {
    _waveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final themeColor = const Color(0xFF8D7B68);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.translate('assistant'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7D5A50),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Voice-guided navigation and virtual assistant.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Chat Message Logs
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[_messages.length - 1 - index];
                    final isUser = msg['isUser'];

                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: isUser ? themeColor : const Color(0xFFF3EFE0),
                          borderRadius: BorderRadius.circular(24).copyWith(
                            bottomLeft: isUser ? const Radius.circular(24) : Radius.zero,
                            bottomRight: isUser ? Radius.zero : const Radius.circular(24),
                          ),
                          border: isUser ? null : Border.all(color: const Color(0xFFE6DED4)),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Text(
                          msg['text'],
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isUser ? Colors.white : const Color(0xFF7D5A50),
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Listening / Wave Indicator
              if (_isListening)
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Listening...",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: (index % 2 == 0) ? _waveHeight : _waveHeight * 0.6,
                          decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // Giant microphone interaction button
              Center(
                child: GestureDetector(
                  onTap: _onMicTap,
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.redAccent.withOpacity(0.15) : themeColor.withOpacity(0.1),
                      border: Border.all(
                        color: _isListening ? Colors.redAccent : themeColor,
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: _isListening ? Colors.redAccent : themeColor,
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _isListening ? "Simulating voice analysis" : "Tap to Speak",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
