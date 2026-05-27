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
}
