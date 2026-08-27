import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'pages/home_page.dart';
import 'pages/games_page.dart';
import 'pages/assistant_page.dart';
import 'pages/profile_page.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize TTS early
  final tts = TtsService();
  await tts.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const VantaraApp(),
    ),
  );
}

class VantaraApp extends StatelessWidget {
  const VantaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vantara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8D7B68), // Warm brown/beige
          background: const Color(0xFFFAF7F2), // Light warm cream background
          primary: const Color(0xFF8D7B68),
          secondary: const Color(0xFF7D5A50),
        ),
        // Elder-friendly global text styling (larger body sizes)
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 20, color: Color(0xFF5D4037), height: 1.4),
          bodyMedium: TextStyle(fontSize: 18, color: Color(0xFF5D4037), height: 1.4),
          titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF5D4037)),
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const GamesPage(),
    const AssistantPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFF8D7B68).withOpacity(0.15),
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7D5A50),
                );
              }
              return const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              );
            }),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return const IconThemeData(
                  size: 32,
                  color: Color(0xFF7D5A50),
                );
              }
              return const IconThemeData(
                size: 28,
                color: Colors.grey,
              );
            }),
          ),
          child: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home),
                label: appState.translate('home'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.sports_esports_outlined),
                selectedIcon: const Icon(Icons.sports_esports),
                label: appState.translate('games'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.mic_none_outlined),
                selectedIcon: const Icon(Icons.mic),
                label: appState.translate('assistant'),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person),
                label: appState.translate('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
