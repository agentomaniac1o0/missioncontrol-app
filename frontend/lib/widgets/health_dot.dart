import 'package:flutter/material.dart';
import '../config/theme.dart';

class HealthDot extends StatelessWidget {
  final String status;
  final double size;

  const HealthDot({super.key, required this.status, this.size = 12});

  Color _color() {
    switch (status.toLowerCase()) {
      case 'ok':
      case 'online':
      case 'running':
        return AppTheme.green;
      case 'warning':
        return AppTheme.gold;
      case 'critical':
      case 'offline':
      case 'stopped':
        return AppTheme.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _color().withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}
