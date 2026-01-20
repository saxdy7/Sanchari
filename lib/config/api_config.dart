import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration for backend endpoints
/// Use environment variables for different environments
class ApiConfig {
  // Backend base URL - configurable via environment variable
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kIsWeb 
        ? 'http://localhost:3000'  // Web development
        : 'http://10.0.2.2:3000',  // Android emulator default
  );

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 90);
  static const Duration receiveTimeout = Duration(seconds: 120);

  // API endpoints
  static const String tripPlanEndpoint = '/trip/plan';
  static const String searchEndpoint = '/trip/search';
  static const String placeInfoEndpoint = '/trip/place-info';
  static const String popularDestinationsEndpoint = '/trip/popular-destinations';
  static const String shareEndpoint = '/trip/share';
}
