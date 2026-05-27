import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../models/missioncontrol_live.dart';
import '../models/missioncontrol_health.dart';
import 'missioncontrol_provider.dart';

final missioncontrollerLiveProvider =
    FutureProvider.family<MissioncontrolLive, String>((ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(ApiConfig.liveUrl(location));
  return MissioncontrolLive.fromJson(response.data as Map<String, dynamic>);
});

final missioncontrollerHealthProvider =
    FutureProvider.family<MissioncontrolHealth, String>((ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(ApiConfig.healthUrl(location));
  return MissioncontrolHealth.fromJson(response.data as Map<String, dynamic>);
});

final criticalCountProvider =
    FutureProvider.family<LiveCriticalCount, String>((ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('${ApiConfig.liveUrl(location)}/critical-count');
  return LiveCriticalCount.fromJson(response.data as Map<String, dynamic>);
});

final healthTrendProvider =
    FutureProvider.family<List<HealthTrendPoint>, String>((ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('${ApiConfig.healthUrl(location).replaceAll("/health", "/health-trend")}');
  final list = response.data as List<dynamic>;
  return list.map((e) => HealthTrendPoint.fromJson(e as Map<String, dynamic>)).toList();
});
