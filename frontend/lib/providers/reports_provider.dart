import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../models/missioncontrol_reports.dart';
import 'missioncontrol_provider.dart';

final reportsListProvider =
    FutureProvider.family<List<ReportListItem>, String>((ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(
    ApiConfig.reportsUrl(location),
    queryParameters: {'limit': 5},
  );
  final list = response.data as List<dynamic>;
  return list
      .map((e) => ReportListItem.fromJson(e as Map<String, dynamic>))
      .toList();
});

final reportDetailProvider = FutureProvider.family<ReportDetail,
    ({String location, String filename})>((ref, params) async {
  final dio = ref.watch(dioProvider);
  final response =
      await dio.get(ApiConfig.reportDetailUrl(params.location, params.filename));
  return ReportDetail.fromJson(response.data as Map<String, dynamic>);
});
