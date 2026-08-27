import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/models.dart';

class RoutineRecallGame extends StatefulWidget {
  const RoutineRecallGame({super.key});

  @override
  State<RoutineRecallGame> createState() => _RoutineRecallGameState();
}

class _RoutineRecallGameState extends State<RoutineRecallGame> {
  late int _difficulty;
  int _questionIndex = 0;
  bool _canTap = true;
  DateTime? _gameStartTime;
  int _mistakes = 0;
  int _attempts = 0;

  // Question bank with answers
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'What was your first task scheduled for 08:30 AM today?',
      'questionHindi': 'आज सुबह 08:30 बजे आपका पहला काम क्या था?',
      'questionAssamese': 'আজি পুৱা ০৮:৩০ বজাত আপোনাৰ প্ৰথম কাম কি আছিল?',
      'choices': ['Morning Medicine', 'Evening Walk', 'Doctor Checkup', 'Drink Juice'],
      'correct': 'Morning Medicine',
      'correctHindi': 'Morning Medicine', // Keep english value or local representation
    },
    {
      'question': 'What are you supposed to drink at 11:00 AM to stay hydrated?',
      'questionHindi': 'स्वस्थ रहने के लिए आपको सुबह 11:00 बजे क्या पीना चाहिए?',
      'questionAssamese': 'শৰীৰটো সুস্থ ৰাখিবলৈ পুৱা ১১:০০ বজাত আপুনি কি খোৱা উচিত?',
      'choices': ['Water', 'Milk Tea', 'Soda Cola', 'Black Coffee'],
      'correct': 'Water',
    },
    {
      'question': 'Where should you go for your walk at 05:00 PM today?',
      'questionHindi': 'आज शाम 05:00 बजे आपको टहलने कहाँ जाना चाहिए?',
      'questionAssamese': 'আজি আবেলি ০৫:০০ বজাত খোজ কাঢ়িবলৈ আপুনি ক’লৈ যোৱা উচিত?',
      'choices': ['Garden / Park', 'Railway Station', 'Market Mall', 'Office'],
      'correct': 'Garden / Park',
    },
    {
      'question': 'Who helps you manage Vantara and logs your games?',
      'questionHindi': 'वंतरा ऐप चलाने और खेल दर्ज करने में आपकी मदद कौन करता है?',
      'questionAssamese': 'আপোনাক বানতৰা এপটো চলোৱাত কোনে সহায় কৰে?',
      'choices': ['My Caregiver', 'A Stranger', 'Nobody', 'Shopkeeper'],
      'correct': 'My Caregiver',
    }
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    _difficulty = appState.gameDifficulties['routine_recall'] ?? 1;

    // Pick a random question
    final rand = _Rand(DateTime.now().millisecondsSinceEpoch);
    _questionIndex = rand.nextInt(_questions.length);

    _setupGame();
  }

  void _setupGame() {
    _canTap = true;
    _gameStartTime = DateTime.now();

    // Trigger TTS reading of the question
    final appState = Provider.of<AppState>(context, listen: false);
    final q = _questions[_questionIndex];
    String voiceQ = appState.currentLanguage == 'hi-IN'
        ? q['questionHindi'] ?? q['question']
        : appState.currentLanguage == 'as-IN'
            ? q['questionAssamese'] ?? q['question']
            : q['question'];

    Timer(const Duration(milliseconds: 1000), () {
      appState.speakPrompt(voiceQ);
    });
  }

  void _onOptionSelected(String option) {
    if (!_canTap) return;

    final appState = Provider.of<AppState>(context, listen: false);
    final q = _questions[_questionIndex];
    String correct = q['correct'];
    _attempts++;

    if (option.toLowerCase() == correct.toLowerCase() || 
        (appState.currentLanguage == 'hi-IN' && option.contains('मदद') && correct.contains('Caregiver')) || // Fallbacks for matching translated text
        (option.contains('Medicine') && correct.contains('Medicine')) ||
        (option.contains('Water') && correct.contains('Water')) ||
        (option.contains('Garden') && correct.contains('Garden')) ||
        (option.contains('Caregiver') && correct.contains('Caregiver'))) {
      
      setState(() {
        _canTap = false;
      });
      _finishGame();
    } else {
      setState(() {
        _mistakes++;
      });
      String warning = appState.currentLanguage == 'hi-IN' ? "नहीं, वह नहीं। याद करें!" : "That is incorrect. Try to remember today's schedule.";
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
      gameId: 'routine_recall',
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
            const Icon(Icons.task_alt, color: Colors.green, size: 70),
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
    final q = _questions[_questionIndex];
    String displayedQuestion = appState.currentLanguage == 'hi-IN'
        ? q['questionHindi'] ?? q['question']
        : appState.currentLanguage == 'as-IN'
            ? q['questionAssamese'] ?? q['question']
            : q['question'];

    // Provide localized translations for choices
    List<String> rawChoices = List<String>.from(q['choices']);
    
    // Filter choices count by difficulty (simulated)
    int count = _difficulty <= 1 ? 2 : (_difficulty <= 3 ? 3 : 4);
    if (count > rawChoices.length) count = rawChoices.length;
    
    // Ensure correct answer is always included in choices displayed
    String correctChoice = q['choices'][0]; // index 0 is always correct in db config before shuffling
    List<String> displayedChoices = rawChoices.sublist(0, count);
    if (!displayedChoices.contains(correctChoice)) {
      displayedChoices[displayedChoices.length - 1] = correctChoice;
    }
    displayedChoices.shuffle();

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
          appState.translate('routine_recall'),
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
                appState.speakPrompt(displayedQuestion);
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

            // Question Display Panel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFFE6DED4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.calendar_month, color: Color(0xFF8D7B68), size: 55),
                  const SizedBox(height: 16),
                  Text(
                    displayedQuestion,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7D5A50),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),

            // Answer Cards List
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: displayedChoices.map((choice) {
                  // Apply translation lookup or mapping if needed
                  String displayedChoiceText = choice;
                  if (appState.currentLanguage == 'hi-IN') {
                    if (choice == 'Morning Medicine') displayedChoiceText = 'सुबह की दवा';
                    if (choice == 'Evening Walk') displayedChoiceText = 'शाम की सैर';
                    if (choice == 'Doctor Checkup') displayedChoiceText = 'डॉक्टर से जांच';
                    if (choice == 'Drink Juice') displayedChoiceText = 'जूस पीना';
                    if (choice == 'Water') displayedChoiceText = 'पानी';
                    if (choice == 'Milk Tea') displayedChoiceText = 'दूध की चाय';
                    if (choice == 'Soda Cola') displayedChoiceText = 'सोडा कोला';
                    if (choice == 'Black Coffee') displayedChoiceText = 'ब्लैक कॉफी';
                    if (choice == 'Garden / Park') displayedChoiceText = 'बगीचा / पार्क';
                    if (choice == 'Railway Station') displayedChoiceText = 'रेलवे स्टेशन';
                    if (choice == 'Market Mall') displayedChoiceText = 'बाजार मॉल';
                    if (choice == 'Office') displayedChoiceText = 'कार्यालय';
                    if (choice == 'My Caregiver') displayedChoiceText = 'मेरे सहायक (केयरगिवर)';
                    if (choice == 'A Stranger') displayedChoiceText = 'कोई अजनबी';
                    if (choice == 'Nobody') displayedChoiceText = 'कोई नहीं';
                    if (choice == 'Shopkeeper') displayedChoiceText = 'दुकानदार';
                  } else if (appState.currentLanguage == 'as-IN') {
                    if (choice == 'Morning Medicine') displayedChoiceText = 'পুৱাৰ ঔষধ';
                    if (choice == 'Evening Walk') displayedChoiceText = 'সন্ধিয়া খোজ কঢ়া';
                    if (choice == 'Doctor Checkup') displayedChoiceText = 'ডাক্তৰ পৰীক্ষা';
                    if (choice == 'Drink Juice') displayedChoiceText = 'ৰস খোৱা';
                    if (choice == 'Water') displayedChoiceText = 'পানী';
                    if (choice == 'Milk Tea') displayedChoiceText = 'গাখীৰ চাহ';
                    if (choice == 'Soda Cola') displayedChoiceText = 'ছ’ডা কোলা';
                    if (choice == 'Black Coffee') displayedChoiceText = 'ব্লেক কফি';
                    if (choice == 'Garden / Park') displayedChoiceText = 'বাগান / উদ্যান';
                    if (choice == 'Railway Station') displayedChoiceText = 'ৰে’ল ষ্টেচন';
                    if (choice == 'Market Mall') displayedChoiceText = 'বজাৰ / মল';
                    if (choice == 'Office') displayedChoiceText = 'কাৰ্যালয়';
                    if (choice == 'My Caregiver') displayedChoiceText = 'মোৰ তত্ত্বাৱধায়ক';
                    if (choice == 'A Stranger') displayedChoiceText = 'কোনো অচিনাকি ব্যক্তি';
                    if (choice == 'Nobody') displayedChoiceText = 'কোনো নাই';
                    if (choice == 'Shopkeeper') displayedChoiceText = 'দোকানী';
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: SizedBox(
                      height: 65,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D7B68),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () => _onOptionSelected(choice),
                        child: Text(
                          displayedChoiceText,
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
