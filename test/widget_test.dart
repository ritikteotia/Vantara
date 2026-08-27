import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vantara/main.dart';
import 'package:vantara/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the flutter_tts platform channel
  const MethodChannel channel = MethodChannel('flutter_tts');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return 1;
    });
  });

  testWidgets('VantaraApp renders successfully and loads tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const VantaraApp(),
      ),
    );

    // Let the async state loading and initial frames settle
    await tester.pumpAndSettle();

    // Verify Vantara title text is displayed in the homepage header
    expect(find.text('Vantara'), findsWidgets);
    
    // Verify bottom navigation bar has standard tabs
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.sports_esports_outlined), findsOneWidget);
    expect(find.byIcon(Icons.mic_none_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
}
