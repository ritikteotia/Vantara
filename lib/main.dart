import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/app_state.dart';
import 'pages/home_page.dart';
import 'pages/games_page.dart';
import 'pages/assistant_page.dart';
import 'pages/profile_page.dart';
import 'services/tts_service.dart';
import 'theme/glass_theme.dart';

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
        brightness: Brightness.light,
        scaffoldBackgroundColor: VantaraColors.background,
        colorScheme: ColorScheme.light(
          surface: VantaraColors.background,
          primary: VantaraColors.primaryGreen,
          secondary: VantaraColors.accentGreen,
          onSurface: VantaraColors.textDark,
        ),
        // Elder-friendly global text styling (clear, high readability)
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 20,
            color: VantaraColors.textDark,
            height: 1.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 18,
            color: VantaraColors.textDark,
            height: 1.4,
          ),
          titleLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: VantaraColors.textDark,
          ),
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
      backgroundColor: VantaraColors.background,
      extendBody: true, // Enables true floating effect over content
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          FloatingNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: appState.translate('home'),
          ),
          FloatingNavItem(
            icon: Icons.sports_esports_outlined,
            activeIcon: Icons.sports_esports_rounded,
            label: appState.translate('games'),
          ),
          FloatingNavItem(
            icon: Icons.mic_none_outlined,
            activeIcon: Icons.mic_rounded,
            label: appState.translate('assistant'),
          ),
          FloatingNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person_rounded,
            label: appState.translate('profile'),
          ),
        ],
      ),
    );
  }
}
