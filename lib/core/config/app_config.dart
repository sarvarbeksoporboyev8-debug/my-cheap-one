import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  final bool useApiDataSource;
  final String apiBaseUrl;
  final bool enableAdminMode;
  const AppConfig({required this.useApiDataSource, required this.apiBaseUrl, required this.enableAdminMode});
}

final appConfigProvider = Provider<AppConfig>((ref) {
  // Toggle this flag to switch between Mock and API data sources
  // In production, these can be read from flavors or env vars.
  const useApi = false; // default to MockDataSource per acceptance criteria
  const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://example.com');
  return const AppConfig(useApiDataSource: useApi, apiBaseUrl: baseUrl, enableAdminMode: false);
});
