const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://100.103.32.107:8000',
);

class ApiConfig {
  static const String baseUrl = apiBaseUrl;
  static const String missioncontrolPath = '/api/missioncontrol';

  static String overviewUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/overview';
  static String systemUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/system';
  static String codeQualityUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/code-quality';
  static String liveUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/live';
  static String healthUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/health';

  static String graphiphyStatsUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/graphiphy/stats';
  static String graphiphyGodNodesUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/graphiphy/god-nodes';
  static String graphiphyCommunitiesUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/graphiphy/communities';
  static String graphiphyCommunityUrl(String location, int communityId) =>
      '$baseUrl$missioncontrolPath/$location/graphiphy/community/$communityId';
  static String graphiphySearchUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/graphiphy/search';
  static String graphiphyVizUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/graphiphy/viz';
  static String graphiphySvgUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/graphiphy/svg';
  static String graphiphyPngUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/graphiphy/png';

  static String reportsUrl(String location) =>
      '$baseUrl$missioncontrolPath/$location/reports';
  static String reportDetailUrl(String location, String filename) =>
      '$baseUrl$missioncontrolPath/$location/reports/$filename';
}
