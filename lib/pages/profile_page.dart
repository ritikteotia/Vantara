import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/glass_theme.dart';
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
        backgroundColor: Colors.white,
        title: const Center(
          child: Text(
            "Caregiver Verification",
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: VantaraColors.textDark,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Please enter the 4-digit caregiver security PIN to open dashboard.",
              textAlign: TextAlign.center,
              style: TextStyle(color: VantaraColors.textSub, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 10,
                fontWeight: FontWeight.bold,
                color: VantaraColors.textDark,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: VantaraColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: VantaraColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: VantaraColors.primaryGreen, width: 2),
                ),
                counterText: "",
                hintText: "••••",
                filled: true,
                fillColor: VantaraColors.background,
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
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16, color: VantaraColors.textSub),
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VantaraColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (_pinController.text == "1234") {
                      _pinController.clear();
                      Navigator.of(ctx).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CaregiverDashboardPage(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text("Incorrect PIN. Default is 1234."),
                          backgroundColor: VantaraColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Enter",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AppState appState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Voice & Language",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: VantaraColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildLangTile(ctx, appState, 'English', 'en-US', '🇺🇸'),
              _buildLangTile(ctx, appState, 'हिन्दी (Hindi)', 'hi-IN', '🇮🇳'),
              _buildLangTile(ctx, appState, 'অসমীয়া (Assamese)', 'as-IN', '🌾'),
              _buildLangTile(ctx, appState, 'মনিপুরী (Manipuri)', 'mni-IN', '🏔️'),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangTile(
      BuildContext ctx, AppState appState, String title, String code, String flag) {
    final isSelected = appState.currentLanguage == code;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? VantaraColors.primaryGreen : VantaraColors.textDark,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: VantaraColors.primaryGreen)
          : null,
      onTap: () {
        appState.changeLanguage(code);
        Navigator.of(ctx).pop();
      },
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

    String langName = "English";
    if (appState.currentLanguage == 'hi-IN') langName = "Hindi";
    if (appState.currentLanguage == 'as-IN') langName = "Assamese";
    if (appState.currentLanguage == 'mni-IN') langName = "Manipuri";

    return Scaffold(
      backgroundColor: VantaraColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                appState.translate('profile'),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: VantaraColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Patient Bio Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    // Amma avatar
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF3EFE0),
                        border: Border.all(
                          color: VantaraColors.primaryGreen.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.face_3_rounded,
                          size: 44,
                          color: Color(0xFF8D7B68),
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Amma",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: VantaraColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            "Age: 72",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: VantaraColors.textSub,
                            ),
                          ),
                          Text(
                            "Language: $langName",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: VantaraColors.textSub,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: VantaraColors.textGrey,
                      size: 28,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Option list items
              Container(
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
                child: Column(
                  children: [
                    _buildSettingsItem(
                      icon: Icons.insights_rounded,
                      iconColor: const Color(0xFF4EA8DE),
                      title: "My Progress",
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CaregiverDashboardPage(),
                        ),
                      ),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      icon: Icons.notifications_none_rounded,
                      iconColor: const Color(0xFFF4A261),
                      title: "Reminders Settings",
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("All 4 daily reminders are active."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      icon: Icons.security_rounded,
                      iconColor: VantaraColors.primaryGreen,
                      title: "Caregiver Access",
                      onTap: () => _verifyCaregiverPin(context),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      icon: Icons.translate_rounded,
                      iconColor: const Color(0xFF8E7CC3),
                      title: "Language: $langName",
                      onTap: () => _showLanguagePicker(context, appState),
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      icon: Icons.help_outline_rounded,
                      iconColor: const Color(0xFFE56B6F),
                      title: "Help & Support",
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Text("Help & Support"),
                            content: const Text(
                              "Vantara is your AI cognitive companion designed to assist memory recall, daily orientation, and medication reminders.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text("OK"),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsItem(
                      icon: Icons.info_outline_rounded,
                      iconColor: Colors.grey,
                      title: "About Vantara",
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: "Vantara",
                          applicationVersion: "1.0.0",
                          applicationLegalese: "AI Cognitive Assistance for Dementia Care",
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Logout / Reset button
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Session active. Everything is up to date."),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E9).withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFE56B6F).withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout_rounded, color: Color(0xFFE56B6F), size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFE56B6F),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: VantaraColors.textDark,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: VantaraColors.textGrey,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 20,
      endIndent: 20,
      color: VantaraColors.borderLight,
    );
  }
}
