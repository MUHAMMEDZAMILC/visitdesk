class ApiConfig {
  ApiConfig._();

  /// Replace with your MockAPI.io project URL, e.g.
  /// https://xxxxxxxx.mockapi.io/api/v1
  /// Can also be overridden at build time:
  /// flutter run --dart-define=API_BASE_URL=https://...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://REPLACE_ME.mockapi.io/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
