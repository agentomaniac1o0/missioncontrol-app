import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_health.dart';

class HealthScoreCard extends StatelessWidget {
  final MissioncontrolHealth? health;

  const HealthScoreCard({super.key, required this.health});

  Color _scoreColor(int score) {
    if (score >= 80) return AppTheme.green;
    if (score >= 50) return AppTheme.gold;
    return AppTheme.red;
  }

  @override
  Widget build(BuildContext context) {
    final score = health?.score ?? 0;
    final color = _scoreColor(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: score / 100,
                      strokeWidth: 8,
                      backgroundColor: AppTheme.surface,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  Text(
                    '$score',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              health?.level.toUpperCase() ?? '--',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 2,
              ),
            ),
            if (health != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: () {
                  final h = health!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _subScore('VMs', h.vmHealth, _scoreColor(h.vmHealth.round())),
                      _subScore('Services', h.serviceHealth, _scoreColor(h.serviceHealth.round())),
                      _subScore('Audit', h.auditHealth, _scoreColor(h.auditHealth.round())),
                    ],
                  );
                }(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _subScore(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          '${value.round()}%',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    );
  }
}
