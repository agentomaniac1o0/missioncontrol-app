class ReportListItem {
  final String filename;
  final String date;
  final int sizeBytes;

  const ReportListItem({
    required this.filename,
    required this.date,
    required this.sizeBytes,
  });

  factory ReportListItem.fromJson(Map<String, dynamic> json) {
    return ReportListItem(
      filename: json['filename'] as String? ?? '',
      date: json['date'] as String? ?? '',
      sizeBytes: json['size_bytes'] as int? ?? 0,
    );
  }

  String get displayDate {
    try {
      final dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    } catch (_) {
      return date;
    }
  }
}

class ReportDetail {
  final String filename;
  final String date;
  final String content;
  final String format;

  const ReportDetail({
    required this.filename,
    required this.date,
    required this.content,
    required this.format,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    return ReportDetail(
      filename: json['filename'] as String? ?? '',
      date: json['date'] as String? ?? '',
      content: json['content'] as String? ?? '',
      format: json['format'] as String? ?? 'markdown',
    );
  }

  String get displayDate {
    try {
      final dt = DateTime.parse(date);
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return date;
    }
  }
}
