import 'package:flutter/material.dart';
import '../config/theme.dart';

enum RefreshFrequency { live, hourly, daily, weekly }

class RefreshBadge extends StatelessWidget {
  final RefreshFrequency frequency;
  final String? customLabel;

  const RefreshBadge({super.key, required this.frequency, this.customLabel});

  String get label {
    if (customLabel != null) return customLabel!;
    return switch (frequency) {
      RefreshFrequency.live => 'Live',
      RefreshFrequency.hourly => 'Stündlich',
      RefreshFrequency.daily => 'Täglich',
      RefreshFrequency.weekly => 'Wöchentlich',
    };
  }

  Color get color {
    return switch (frequency) {
      RefreshFrequency.live => AppTheme.green,
      RefreshFrequency.hourly => AppTheme.blue,
      RefreshFrequency.daily => AppTheme.gold,
      RefreshFrequency.weekly => Colors.white38,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final RefreshFrequency frequency;
  final String? subtitle;

  const SectionHeader({
    super.key,
    required this.title,
    this.frequency = RefreshFrequency.daily,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
          if (subtitle != null) ...[
            Text(subtitle!, style: TextStyle(fontSize: 10, color: Colors.white24)),
            const SizedBox(width: 6),
          ],
          RefreshBadge(frequency: frequency),
        ],
      ),
    );
  }
}
