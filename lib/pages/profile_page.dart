import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'dashboard_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _pinController = TextEditingController();

  void _verifyCaregiverPin(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFFFFF9F5),
        title: const Center(
          child: Text(
            "Caregiver Verification",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Please enter the 4-digit caregiver security PIN to open dashboard.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, letterSpacing: 10, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                counterText: "",
                hintText: "••••",
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Cancel", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D7B68),
                  ),
                  onPressed: () {
                    if (_pinController.text == "1234") {
                      _pinController.clear();
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CaregiverDashboardPage()),
                      );
                    } else {
                      // Trigger error speech/dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Incorrect PIN. Please try again.")),
                      );
                    }
                  },
                  child: const Text("Enter", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final themeColor = const Color(0xFF8D7B68);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appState.translate('profile'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7D5A50),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Personal settings and language packs selection.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              // Patient Bio Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE6DED4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFF3EFE0),
                      child: Icon(Icons.person, size: 50, color: Color(0xFF8D7B68)),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Devi Prasad",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7D5A50),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text("Age: 72", style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text("Guwahati, Assam, India", style: TextStyle(fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Language Packs selector
              const Text(
                "Language Selection (TTS Voice Support)",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7D5A50),
                ),
              ),
              const SizedBox(height: 12),
              
              // Language packs buttons grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.2,
                children: [
                  _buildLanguageButton(context, appState, 'English', 'en-US', '🇺🇸'),
                  _buildLanguageButton(context, appState, 'हिन्दी (Hindi)', 'hi-IN', '🇮🇳'),
                  _buildLanguageButton(context, appState, 'অসমীয়া (Assamese)', 'as-IN', '🌾'),
                  _buildLanguageButton(context, appState, 'মনিপুরী (Manipuri)', 'mni-IN', '🏔️'),
                ],
              ),

              const SizedBox(height: 40),

              // Caregiver Entrance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EFE0).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFE6DED4)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.security, size: 50, color: Color(0xFF8D7B68)),
                    const SizedBox(height: 12),
                    const Text(
                      "Caregivers & Doctors Section",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7D5A50),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Monitor longitudinal stats and edit schedule settings.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _verifyCaregiverPin(context),
                        icon: const Icon(Icons.dashboard, color: Colors.white),
                        label: Text(
                          appState.translate('caregiver_title'),
                          style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(
    BuildContext context,
    AppState appState,
    String name,
    String code,
    String flag,
  ) {
    final isSelected = appState.currentLanguage == code;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFF8D7B68) : Colors.white,
        side: BorderSide(
          color: isSelected ? const Color(0xFF8D7B68) : const Color(0xFFE6DED4),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      onPressed: () => appState.changeLanguage(code),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(flag, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF7D5A50),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
