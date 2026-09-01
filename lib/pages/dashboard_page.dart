import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class CaregiverDashboardPage extends StatelessWidget {
  const CaregiverDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final themeColor = const Color(0xFF8D7B68);

    // Calculate metrics
    final completedReminders = appState.reminders.where((r) => r.isCompleted).length;
    final totalReminders = appState.reminders.length;
    final compliancePercent = totalReminders > 0 
        ? ((completedReminders / totalReminders) * 100).toInt() 
        : 0;

    // Filter memory match scores for graph
    final memoryScores = appState.gameMetrics
        .where((m) => m.gameId == 'memory_match')
        .map((m) => m.accuracy)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF7D5A50)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Caregiver Dashboard",
          style: TextStyle(color: Color(0xFF7D5A50), fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient overview card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE6DED4), width: 1.5),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFFF3EFE0),
                    child: Icon(Icons.psychology, color: Color(0xFF8D7B68), size: 35),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Patient status: Moderate Stage",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text("Cognitive State: ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(
                              memoryScores.isNotEmpty && memoryScores.last >= 0.80 ? "Stable / Active" : "Requires Attention",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: memoryScores.isNotEmpty && memoryScores.last >= 0.80 ? Colors.green : Colors.orange,
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

            // Metrics Summary Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _buildMetricsCard(
                  "Reminders Completed",
                  "$completedReminders / $totalReminders",
                  "$compliancePercent% Compliance",
                  Icons.alarm,
                  Colors.green,
                ),
                _buildMetricsCard(
                  "Sync Buffer Queue",
                  "${appState.unsyncedMetrics.length} Items",
                  appState.syncStatusMessage,
                  Icons.sync,
                  appState.isOnline ? Colors.blue : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Offline sync control panel
            const Text(
              "Offline-First Control Hub",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE6DED4), width: 1.5),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Simulate Connectivity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50))),
                          SizedBox(height: 4),
                          Text("Toggle internet connection state", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      Switch(
                        value: appState.isOnline,
                        activeColor: themeColor,
                        onChanged: (val) {
                          appState.setOnlineStatus(val);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pending Offline Data", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50))),
                          SizedBox(height: 4),
                          Text("Data waiting to send to cloud", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                        ),
                        onPressed: appState.unsyncedMetrics.isNotEmpty && appState.isOnline
                            ? () => appState.triggerSync()
                            : null,
                        child: Text(
                          appState.isSyncing ? "Syncing..." : "Sync Now",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Longitudinal Performance Graph
            const Text(
              "Cognitive Accuracy Trend (Memory Match)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE6DED4), width: 1.5),
              ),
              child: memoryScores.isEmpty
                  ? const Center(child: Text("No game metrics recorded yet.", style: TextStyle(color: Colors.grey)))
                  : CustomPaint(
                      painter: LineChartPainter(scores: memoryScores),
                    ),
            ),
            const SizedBox(height: 25),

            // Longitudinal Log
            const Text(
              "Longitudinal Activities Log",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50)),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: appState.gameMetrics.length,
              itemBuilder: (context, idx) {
                final metric = appState.gameMetrics[appState.gameMetrics.length - 1 - idx];
                String gName = metric.gameId.replaceAll('_', ' ').toUpperCase();
                
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF3EFE0),
                      child: Icon(Icons.sports_esports, color: Color(0xFF8D7B68)),
                    ),
                    title: Text(gName, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7D5A50))),
                    subtitle: Text(
                      "${metric.timestamp.toString().split('.')[0]} • Speed: ${(metric.reactionTimeMs / 1000).toStringAsFixed(1)}s",
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: Text(
                      "${(metric.accuracy * 100).toInt()}% Score",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green),
                    ),
                  ),
                );
              },
            ),
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6DED4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
              Icon(icon, color: color, size: 22),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF7D5A50))),
          Text(footnote, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// Custom Painter to draw a clean line graph
class LineChartPainter extends CustomPainter {
  final List<double> scores;
  LineChartPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8D7B68)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = const Color(0xFF8D7B68).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = const Color(0xFF7D5A50)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1.0;

    // Draw horizontal grids
    for (int i = 0; i <= 4; i++) {
      double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (scores.isEmpty) return;

    // Plot line
    final path = Path();
    final fillPath = Path();
    double stepX = size.width / (scores.length > 1 ? (scores.length - 1) : 1);

    for (int i = 0; i < scores.length; i++) {
      // Y scale starts from top (0) to bottom (height). So 100% (1.0) is at y=0, 0% is at y=height.
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

    // Draw dots and score values
    for (int i = 0; i < scores.length; i++) {
      double x = i * stepX;
      double y = size.height * (1.0 - scores[i]);
      canvas.drawCircle(Offset(x, y), 5.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
