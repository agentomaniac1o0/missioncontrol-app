import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../models/missioncontrol_overview.dart';
import '../models/missioncontrol_system.dart';
import '../models/missioncontrol_code_quality.dart';

final dioProvider = Provider<Dio>((ref) => Dio());

final locationProvider = StateProvider<String>((ref) => 'home-lab');

final textScaleProvider = StateProvider<double>((ref) => 1.0);

final missioncontrollerOverviewProvider =
    FutureProvider.family<MissioncontrolOverview, String>((ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(ApiConfig.overviewUrl(location));
  return MissioncontrolOverview.fromJson(response.data as Map<String, dynamic>);
});

final missioncontrollerSystemProvider =
    FutureProvider.family<MissioncontrolSystem, String>((ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(ApiConfig.systemUrl(location));
  return MissioncontrolSystem.fromJson(response.data as Map<String, dynamic>);
});

final missioncontrollerCodeQualityProvider = FutureProvider.family<
    MissioncontrolCodeQuality, String>((ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(ApiConfig.codeQualityUrl(location));
  return MissioncontrolCodeQuality.fromJson(
      response.data as Map<String, dynamic>);
});
