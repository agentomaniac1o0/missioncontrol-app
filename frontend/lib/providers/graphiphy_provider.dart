import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../models/missioncontrol_graphiphy.dart';
import 'missioncontrol_provider.dart';

final graphiphyStatsProvider =
    FutureProvider.family<GraphiphyStats, String>((ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(ApiConfig.graphiphyStatsUrl(location));
  return GraphiphyStats.fromJson(response.data as Map<String, dynamic>);
});

final graphiphyGodNodesProvider =
    FutureProvider.family<List<GraphiphyGodNode>, String>(
        (ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(
    ApiConfig.graphiphyGodNodesUrl(location),
    queryParameters: {'top_n': 20},
  );
  final list = response.data as List<dynamic>;
  return list
      .map((e) => GraphiphyGodNode.fromJson(e as Map<String, dynamic>))
      .toList();
});

final graphiphyCommunitiesProvider =
    FutureProvider.family<List<GraphiphyCommunity>, String>(
        (ref, location) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get(
    ApiConfig.graphiphyCommunitiesUrl(location),
    queryParameters: {'limit': 50, 'offset': 0},
  );
  final list = response.data as List<dynamic>;
  return list
      .map((e) => GraphiphyCommunity.fromJson(e as Map<String, dynamic>))
      .toList();
});

final graphiphyCommunityNodesProvider = FutureProvider.family<
    List<GraphiphyNode>, ({String location, int communityId})>(
        (ref, params) async {
  final dio = ref.watch(dioProvider);
  final response = await dio
      .get(ApiConfig.graphiphyCommunityUrl(params.location, params.communityId));
  final list = response.data as List<dynamic>;
  return list
      .map((e) => GraphiphyNode.fromJson(e as Map<String, dynamic>))
      .toList();
});

final graphiphySearchProvider =
    FutureProvider.family<List<GraphiphyNode>, ({String location, String query})>(
        (ref, params) async {
  if (params.query.isEmpty) return [];
  final dio = ref.watch(dioProvider);
  final response = await dio.get(
    ApiConfig.graphiphySearchUrl(params.location),
    queryParameters: {'q': params.query, 'limit': 20},
  );
  final list = response.data as List<dynamic>;
  return list
      .map((e) => GraphiphyNode.fromJson(e as Map<String, dynamic>))
      .toList();
});

final graphiphyVizUrlProvider = Provider.family<String, String>((ref, location) {
  return ApiConfig.graphiphyVizUrl(location);
});
