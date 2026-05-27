import 'package:flutter/material.dart';
import '../config/theme.dart';

class DiskBar extends StatelessWidget {
  final String label;
  final double percent;

  const DiskBar({super.key, required this.label, required this.percent});

  Color _barColor() {
    if (percent >= 90) return AppTheme.red;
    if (percent >= 75) return AppTheme.gold;
    return AppTheme.green;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
              Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _barColor()),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: AppTheme.surface,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor()),
            ),
          ),
        ],
      ),
    );
  }
}
