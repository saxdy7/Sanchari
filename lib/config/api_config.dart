import 'package:flutter/foundation.dart' show kIsWeb;

/// API Configuration for backend endpoints
class ApiConfig {
  // 🌐 PRODUCTION: Set your Render.com URL here after deployment
  // Example: 'https://sanchari-backend.onrender.com'
  static const String productionUrl = 'https://your-app-name.onrender.com';

  // 💻 DEVELOPMENT: Local backend URL
  static const String developmentUrl = kIsWeb
      ? 'http://localhost:3000' // Web development
      : 'http://192.168.31.156:3000'; // Mobile on same WiFi

  // Choose URL based on environment (change useProduction to true after deploying)
  static const bool useProduction = false;

  static String get baseUrl => useProduction ? productionUrl : developmentUrl;

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 90);
  static const Duration receiveTimeout = Duration(seconds: 120);

  // API endpoints
  static const String tripPlanEndpoint = '/trip/plan';
  static const String searchEndpoint = '/trip/search';
  static const String placeInfoEndpoint = '/trip/place-info';
  static const String popularDestinationsEndpoint =
      '/trip/popular-destinations';
  static const String shareEndpoint = '/trip/share';
}
