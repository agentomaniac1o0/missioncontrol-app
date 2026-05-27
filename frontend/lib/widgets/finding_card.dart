import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/missioncontrol_code_quality.dart';

class FindingCard extends StatelessWidget {
  final Finding finding;

  const FindingCard({super.key, required this.finding});

  Color _severityColor() {
    switch (finding.severity.toLowerCase()) {
      case 'critical':
      case 'kritisch':
        return AppTheme.red;
      case 'high':
      case 'hoch':
        return AppTheme.gold;
      case 'medium':
      case 'mittel':
        return AppTheme.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                finding.severity.toUpperCase(),
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(finding.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  if (finding.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(finding.description, style: TextStyle(fontSize: 11, color: Colors.white54)),
                  ],
                ],
              ),
            ),
            if (finding.autoFixed)
              const Icon(Icons.auto_fix_high, size: 16, color: AppTheme.green),
          ],
        ),
      ),
    );
  }
}
