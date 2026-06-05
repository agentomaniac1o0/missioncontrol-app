import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/missioncontrol_reports.dart';
import '../providers/missioncontrol_provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/refresh_badge.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final reportsAsync = ref.watch(reportsListProvider(location));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(reportsListProvider(location));
      },
      child: reportsAsync.when(
        data: (reports) {
          if (reports.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 48,
                      color: AppTheme.gold.withValues(alpha: 0.3)),
                  const SizedBox(height: 12),
                  const Text('Keine Berichte gefunden',
                      style: TextStyle(color: Colors.white38)),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SectionHeader(
                title: 'Letzte ${reports.length} Berichte',
                frequency: RefreshFrequency.daily,
                subtitle: 'Monitoring Crew Reports',
              ),
              const SizedBox(height: 8),
              ...reports.map((r) => _ReportTile(
                    report: r,
                    location: location,
                  )),
              const SizedBox(height: 8),
              Text(
                'Zum Vergleichen antippen — so siehst du, ob das Dashboard alle Infos uebernommen hat.',
                style: TextStyle(fontSize: 10, color: Colors.white24, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.white24),
              const SizedBox(height: 8),
              Text('Berichte nicht ladbar',
                  style: TextStyle(color: AppTheme.red.withValues(alpha: 0.7))),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportTile extends ConsumerWidget {
  final ReportListItem report;
  final String location;

  const _ReportTile({required this.report, required this.location});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.article_outlined,
            size: 28, color: AppTheme.gold.withValues(alpha: 0.6)),
        title: Text(report.title.isNotEmpty ? report.title : report.filename,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: Row(
          children: [
            Icon(Icons.calendar_today, size: 10, color: Colors.white38),
            const SizedBox(width: 4),
            Text(report.displayDate,
                style: const TextStyle(fontSize: 10, color: Colors.white38)),
            const SizedBox(width: 12),
            Text('${(report.sizeBytes / 1024).toStringAsFixed(1)} KB',
                style: const TextStyle(fontSize: 10, color: Colors.white24)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white24),
        onTap: () => _showReport(context, ref),
      ),
    );
  }

  void _showReport(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _ReportDetailPage(
          location: location,
          filename: report.filename,
          displayDate: report.displayDate,
        ),
      ),
    );
  }
}

class _ReportDetailPage extends ConsumerWidget {
  final String location;
  final String filename;
  final String displayDate;

  const _ReportDetailPage({
    required this.location,
    required this.filename,
    required this.displayDate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(
        reportDetailProvider((location: location, filename: filename)));

    return Scaffold(
      appBar: AppBar(
        title: Text(filename, style: const TextStyle(fontSize: 14)),
        backgroundColor: AppTheme.surface,
      ),
      body: detailAsync.when(
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 12, color: Colors.white38),
                  const SizedBox(width: 6),
                  Text(displayDate,
                      style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  const Spacer(),
                  Text(detail.format.toUpperCase(),
                      style: const TextStyle(fontSize: 10, color: Colors.white24)),
                ],
              ),
              const Divider(height: 20),
              if (detail.format == 'markdown')
                _MarkdownRenderer(content: detail.content)
              else
                _JsonRenderer(content: detail.content),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Bericht nicht ladbar')),
      ),
    );
  }
}

class _MarkdownRenderer extends StatelessWidget {
  final String content;
  const _MarkdownRenderer({required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.split('\n').map((line) {
        if (line.startsWith('### ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Text(line.substring(4),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.gold)),
          );
        }
        if (line.startsWith('## ')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Text(line.substring(3),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.green)),
          );
        }
        if (line.startsWith('# ')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(line.substring(2),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.green)),
          );
        }
        if (line.startsWith('|') && line.endsWith('|')) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(line,
                style: const TextStyle(fontSize: 12, color: Colors.white54, fontFamily: 'monospace')),
          );
        }
        if (line.startsWith('**') && line.contains(':**')) {
          final parts = line.split(':**');
          final label = parts[0].replaceAll('**', '');
          final value = parts.length > 1 ? parts[1] : '';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$label: ',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54)),
                Expanded(
                    child: Text(value.trim(),
                        style: const TextStyle(fontSize: 12))),
              ],
            ),
          );
        }
        if (line.trim().isEmpty) {
          return const SizedBox(height: 6);
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Text(line,
              style: const TextStyle(fontSize: 12, color: Colors.white70)),
        );
      }).toList(),
    );
  }
}

class _JsonRenderer extends StatelessWidget {
  final String content;
  const _JsonRenderer({required this.content});

  @override
  Widget build(BuildContext context) {
    String formatted;
    try {
      final decoded = json.decode(content);
      formatted = json.encode(decoded);
    } catch (e) {
      debugPrint('JSON format failed: $e');
      formatted = content;
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.dark,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        formatted,
        style: const TextStyle(
            fontSize: 12, color: Colors.white70, fontFamily: 'monospace'),
      ),
    );
  }
}
