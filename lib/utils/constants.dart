/// Application-wide constants
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // ===== IMAGE URLs =====
  
  /// Fallback image URL for spots without images
  static const String fallbackSpotImage =
      'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800';

  /// Placeholder image for loading states
  static const String placeholderImage =
      'https://via.placeholder.com/400x300?text=Loading';

  // ===== MAP CONFIGURATION =====
  
  /// OpenStreetMap tile URL template
  static const String osmTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// User agent for map tiles
  static const String mapUserAgent = 'com.sanchari.app';

  /// Default map center (India)
  static const double defaultMapLatitude = 20.5937;
  static const double defaultMapLongitude = 78.9629;
  static const double defaultMapZoom = 5.0;

  // ===== APP METADATA =====
  
  /// App name
  static const String appName = 'Sanchari';

  /// App tagline
  static const String appTagline = 'Personal AI Trip Planner';

  // ===== CACHE DURATIONS =====
  
  /// Duration to keep trips in cache (5 minutes)
  static const Duration tripsCacheDuration = Duration(minutes: 5);

  /// Duration to keep destinations in cache (30 minutes)
  static const Duration destinationsCacheDuration = Duration(minutes: 30);

  // ===== UI CONSTANTS =====
  
  /// Default animation duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  /// Shimmer loading duration
  static const Duration shimmerDuration = Duration(milliseconds: 1500);

  // ===== SPOT CATEGORIES =====
  
  static const List<String> spotCategories = [
    'ATTRACTION',
    'CAFE',
    'RESTAURANT',
    'ENTERTAINMENT',
    'SHOPPING',
    'NATURE',
    'HISTORY',
    'MUSEUM',
    'OTHER',
  ];

  // ===== TRIP PREFERENCES =====
  
  static const List<String> tripPreferences = [
    'Popular',
    'Museum',
    'Nature',
    'Foodie',
    'History',
    'Shopping',
    'Adventure',
    'Religious',
    'Rivers',
  ];

  // ===== VALIDATION =====
  
  /// Minimum trip duration in days
  static const int minTripDays = 1;

  /// Maximum trip duration in days
  static const int maxTripDays = 7;

  /// Maximum number of spots per trip
  static const int maxSpotsPerTrip = 50;
}
