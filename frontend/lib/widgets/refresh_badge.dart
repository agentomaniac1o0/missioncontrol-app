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

String _formatReportTime(String iso) {
  if (iso.isEmpty) return '';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day.$month. $hour:$minute';
  } catch (_) {
    return '';
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final RefreshFrequency frequency;
  final String? subtitle;
  final String? lastReport;

  const SectionHeader({
    super.key,
    required this.title,
    this.frequency = RefreshFrequency.daily,
    this.subtitle,
    this.lastReport,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (subtitle != null) ...[
            Text(subtitle!, style: TextStyle(fontSize: 10, color: Colors.white24)),
            const SizedBox(width: 6),
          ],
          RefreshBadge(frequency: frequency),
          if (lastReport != null && lastReport!.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              _formatReportTime(lastReport!),
              style: TextStyle(fontSize: 9, color: Colors.white38),
            ),
          ],
        ],
      ),
    );
  }
}
