import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/glass_theme.dart';

class CaregiverDashboardPage extends StatelessWidget {
  const CaregiverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    // Calculate metrics
    final completedReminders =
        appState.reminders.where((r) => r.isCompleted).length;
    final totalReminders = appState.reminders.length;
    final compliancePercent = totalReminders > 0
        ? ((completedReminders / totalReminders) * 100).toInt()
        : 0;

    final memoryScores = appState.gameMetrics
        .where((m) => m.gameId == 'memory_match')
        .map((m) => m.accuracy)
        .toList();

    return Scaffold(
      backgroundColor: VantaraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: VantaraColors.textDark, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Caregiver Dashboard",
          style: TextStyle(
            color: VantaraColors.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient overview
            Container(
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF3EEFA),
                    ),
                    child: const Icon(Icons.psychology_rounded,
                        color: Color(0xFF8E7CC3), size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Patient: Amma (Age 72)",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: VantaraColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text("Cognitive State: ",
                                style: TextStyle(
                                    color: VantaraColors.textSub, fontSize: 13)),
                            Text(
                              memoryScores.isNotEmpty &&
                                      memoryScores.last >= 0.80
                                  ? "Stable / Active"
                                  : "Requires Attention",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: memoryScores.isNotEmpty &&
                                        memoryScores.last >= 0.80
                                    ? VantaraColors.success
                                    : VantaraColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Metrics grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.3,
              children: [
                _buildMetricsCard(
                  "Reminders Completed",
                  "$completedReminders / $totalReminders",
                  "$compliancePercent% Compliance",
                  Icons.alarm_rounded,
                  VantaraColors.success,
                ),
                _buildMetricsCard(
                  "Sync Buffer",
                  "${appState.unsyncedMetrics.length} Items",
                  appState.syncStatusMessage,
                  Icons.sync_rounded,
                  appState.isOnline ? VantaraColors.info : VantaraColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Offline sync control
            const Text(
              "Offline-First Control Hub",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: VantaraColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: VantaraColors.border, width: 1.2),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Simulate Connectivity",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: VantaraColors.textDark,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Toggle internet connection state",
                              style: TextStyle(
                                  color: VantaraColors.textSub, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: appState.isOnline,
                        activeThumbColor: VantaraColors.primaryGreen,
                        activeTrackColor:
                            VantaraColors.primaryGreen.withValues(alpha: 0.3),
                        onChanged: (val) => appState.setOnlineStatus(val),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pending Offline Data",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: VantaraColors.textDark,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              "Data waiting to send to cloud",
                              style: TextStyle(
                                  color: VantaraColors.textSub, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: VantaraColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: appState.unsyncedMetrics.isNotEmpty &&
                                appState.isOnline
                            ? () => appState.triggerSync()
                            : null,
                        child: Text(
                          appState.isSyncing ? "Syncing..." : "Sync Now",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Performance graph
            const Text(
              "Cognitive Accuracy Trend (Memory Match)",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: VantaraColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 190,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: VantaraColors.border, width: 1.2),
              ),
              child: memoryScores.isEmpty
                  ? const Center(
                      child: Text("No game metrics recorded yet.",
                          style: TextStyle(color: VantaraColors.textSub)))
                  : CustomPaint(
                      painter: CleanLineChartPainter(scores: memoryScores),
                    ),
            ),
            const SizedBox(height: 25),

            // Activity log
            const Text(
              "Longitudinal Activities Log",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: VantaraColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appState.gameMetrics.length,
              itemBuilder: (context, idx) {
                final metric = appState
                    .gameMetrics[appState.gameMetrics.length - 1 - idx];
                String gName =
                    metric.gameId.replaceAll('_', ' ').toUpperCase();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: VantaraColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: VantaraColors.lightGreen,
                          ),
                          child: const Icon(
                            Icons.sports_esports_rounded,
                            color: VantaraColors.primaryGreen,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: VantaraColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${metric.timestamp.toString().split('.')[0]} • Speed: ${(metric.reactionTimeMs / 1000).toStringAsFixed(1)}s",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: VantaraColors.textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "${(metric.accuracy * 100).toInt()}%",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            color: metric.accuracy >= 0.8
                                ? VantaraColors.success
                                : VantaraColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsCard(
    String title,
    String value,
    String footnote,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: VantaraColors.border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: VantaraColors.textSub,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: VantaraColors.textDark,
            ),
          ),
          Text(
            footnote,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// Clean Line Chart Painter
class CleanLineChartPainter extends CustomPainter {
  final List<double> scores;
  CleanLineChartPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VantaraColors.primaryGreen
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          VantaraColors.primaryGreen.withValues(alpha: 0.2),
          VantaraColors.primaryGreen.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = VantaraColors.primaryGreen
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = VantaraColors.border
      ..strokeWidth = 1.0;

    // Grid lines
    for (int i = 0; i <= 4; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (scores.isEmpty) return;

    final path = Path();
    final fillPath = Path();
    double stepX = size.width / (scores.length > 1 ? (scores.length - 1) : 1);

    for (int i = 0; i < scores.length; i++) {
      double x = i * stepX;
      double y = size.height * (1.0 - scores[i]);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == scores.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw Dots
    for (int i = 0; i < scores.length; i++) {
      double x = i * stepX;
      double y = size.height * (1.0 - scores[i]);
      canvas.drawCircle(Offset(x, y), 4.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
