import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'sarvam_ai_service.dart';
import '../config/api_config.dart';

// Provider
final tripApiServiceProvider = Provider<TripApiService>((ref) {
  return TripApiService(ref);
});

final userTripsProvider = FutureProvider.autoDispose<List<dynamic>>((
  ref,
) async {
  // Keep alive for 5 minutes to avoid unnecessary refetches
  final link = ref.keepAlive();
  Future.delayed(const Duration(minutes: 5), link.close);

  final apiService = ref.read(tripApiServiceProvider);
  return apiService.getUserTrips();
});

final popularDestinationsProvider =
    FutureProvider.autoDispose<List<TravelGuide>>((ref) async {
      // Keep alive for 30 minutes since destinations don't change often
      final link = ref.keepAlive();
      Future.delayed(const Duration(minutes: 30), link.close);

      final apiService = ref.read(tripApiServiceProvider);
      return apiService.getPopularDestinations();
    });

class TripApiService {
  final Ref ref;
  late final SarvamAIService _aiService;

  TripApiService(this.ref) {
    _aiService = SarvamAIService();
  }

  late final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl, // Use config instead of hardcoded IP
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            requestBody: false,
            responseBody: false,
            logPrint: (obj) => debugPrint(obj.toString()),
          ),
        );

  // Search destinations from Nominatim via backend
  Future<List<LocationResult>> searchDestinations(String query) async {
    try {
      final response = await _dio.get(
        '/trip/search',
        queryParameters: {'q': query},
      );
      final List data = response.data;
      return data.map((json) => LocationResult.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Search error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Unexpected search error: $e');
      return [];
    }
  }

  // Get AI-generated context/description for a location
  Future<String> getAiContext(String locationName) async {
    try {
      debugPrint('🤖 Getting AI context for $locationName');
      final context = await _aiService.chat(
        prompt:
            '''Provide a brief, engaging description of $locationName as a tourist destination in India.

Include:
- What makes it special or famous
- Key attractions or features
- Best known for (culture, history, nature, etc.)
- Any unique characteristics

Keep it concise (2-3 sentences), informative, and appealing to travelers.''',
        systemPrompt:
            'You are a knowledgeable travel guide providing concise, accurate information about Indian destinations.',
        temperature: 0.7,
        maxTokens: 200,
      );
      debugPrint('✅ AI Context received for $locationName');
      return context;
    } catch (e) {
      debugPrint('⚠️ AI context failed for $locationName: $e');
      return 'A beautiful destination in India worth exploring.';
    }
  }

  // Get Wikipedia image and info for a place
  Future<Map<String, dynamic>> getPlaceInfo(
    String placeName, {
    String? city,
  }) async {
    try {
      debugPrint('🖼️ Fetching Wikipedia info for: $placeName');
      final response = await _dio.get(
        '/trip/place-info',
        queryParameters: {'name': placeName, if (city != null) 'city': city},
      );

      final data = response.data as Map<String, dynamic>;
      debugPrint('✅ Wikipedia info received for $placeName');

      return {
        'title': data['title'] ?? placeName,
        'description': data['description'] ?? '',
        'imageUrl': data['imageUrl'],
        'pageUrl': data['pageUrl'],
      };
    } on DioException catch (e) {
      debugPrint('❌ Wikipedia fetch error: ${e.message}');
      return {
        'title': placeName,
        'description': '',
        'imageUrl': null,
        'pageUrl': null,
      };
    } catch (e) {
      debugPrint('❌ Unexpected Wikipedia error: $e');
      return {
        'title': placeName,
        'description': '',
        'imageUrl': null,
        'pageUrl': null,
      };
    }
  }

  // Generate trip itinerary with AI enhancements
  Future<TripPlan?> generateTrip({
    required String destination,
    required int days,
    List<String> preferences = const [],
  }) async {
    try {
      // Generate trip using backend API (main functionality)
      debugPrint(
        '🔵 Generating trip: $destination, $days days, preferences: $preferences',
      );
      final response = await _dio.get(
        '/trip/plan',
        queryParameters: {
          'destination': destination,
          'days': days.toString(),
          'preferences': preferences.join(','),
        },
      );

      final tripPlan = TripPlan.fromJson(response.data);
      debugPrint('✅ Trip plan generated successfully');

      // Optional: Get AI insights in background (don't block trip generation)
      _getAIInsightsInBackground(destination, days, preferences);

      return tripPlan;
    } on DioException catch (e) {
      debugPrint('❌ Trip generation error: ${e.message}');
      rethrow; // Re-throw to handle in UI with retry logic
    } catch (e) {
      debugPrint('❌ Unexpected trip error: $e');
      return null;
    }
  }

  // Background AI analysis (doesn't block trip generation)
  void _getAIInsightsInBackground(
    String destination,
    int days,
    List<String> preferences,
  ) {
    // Run AI analysis in background without awaiting
    Future(() async {
      try {
        debugPrint('🤖 Getting AI context for $destination (background)');
        final aiContext = await _aiService.chat(
          prompt:
              '''Analyze this trip request for $destination:
- Preferences: ${preferences.join(', ')}
- Duration: $days days

Understand these preferences:
- Popular: Famous landmarks and tourist attractions
- Museum: Museums, art galleries, cultural centers
- Nature: Parks, gardens, natural scenic spots
- Foodie: Cafes, restaurants, local food spots
- History: Historical monuments, heritage sites
- Shopping: Markets, bazaars, shopping areas
- Adventure: Trekking, outdoor activities, adventure sports
- Religious: Temples, churches, mosques, religious sites
- Rivers: Rivers, lakes, water bodies, riverside spots

Provide:
1. Which preferences are well-suited for this destination
2. Which preferences may not be available (e.g., rivers in desert areas)
3. Alternative suggestions within 25km if some preferences don't match
4. Brief context about the destination
5. PRIORITIZE places nearest to the destination center first, then gradually suggest farther locations

Keep response concise and factual.''',
          systemPrompt:
              'You are a travel planning assistant for Indian destinations. Always prioritize nearby places first (within 5km), then expand to farther locations. Focus on proximity and convenience.',
          temperature: 0.7,
          maxTokens: 500,
        );
        debugPrint(
          '✅ AI Context received (background): ${aiContext.substring(0, min(100, aiContext.length))}...',
        );
        // TODO: Store AI insights for future use if needed
      } catch (aiError) {
        debugPrint('⚠️ Background AI context failed (non-critical): $aiError');
      }
    });
  }

  // Get popular destinations with images
  Future<List<TravelGuide>> getPopularDestinations() async {
    try {
      final response = await _dio.get('/trip/popular-destinations');
      final List data = response.data;
      return data.map((json) => TravelGuide.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Popular destinations error: ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Unexpected destinations error: $e');
      return [];
    }
  }

  // Save trip to Supabase
  Future<void> saveTrip(TripPlan plan, String userId) async {
    try {
      final supabase = Supabase.instance.client;

      debugPrint('🔍 Checking for existing trip: ${plan.destination}');

      // Check for existing trip with same destination to avoid duplicate saves
      final existing = await supabase
          .from('trips')
          .select()
          .eq('user_id', userId)
          .eq('destination', plan.destination)
          .limit(1);

      if (existing.isNotEmpty) {
        debugPrint(
          '⚠️ Trip to ${plan.destination} already exists for user. Skipping save.',
        );
        return;
      }

      debugPrint('💾 Saving new trip: ${plan.destination}');

      await supabase.from('trips').insert({
        'user_id': userId,
        'destination': plan.destination,
        'days': plan.days,
        'trip_data': plan.toJson(),
      });

      debugPrint('✅ Trip saved to Supabase successfully!');

      // Refresh the trips list
      ref.invalidate(userTripsProvider);
      debugPrint('🔄 Refreshed trips provider');
    } catch (e) {
      debugPrint('❌ Error saving trip: $e');
      rethrow; // Rethrow so UI can catch it
    }
  }

  // Delete a trip from Supabase
  Future<bool> deleteTrip(String tripId) async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ No user logged in');
        return false;
      }

      debugPrint('🗑️ Deleting trip: $tripId');

      await supabase
          .from('trips')
          .delete()
          .eq('id', tripId)
          .eq('user_id', userId); // Ensure user can only delete their own trips

      debugPrint('✅ Trip deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting trip: $e');
      return false;
    }
  }

  // Get user trips from Supabase
  Future<List<dynamic>> getUserTrips() async {
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final data = await supabase
          .from('trips')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return data;
    } catch (e) {
      debugPrint('❌ Error fetching trips: $e');
      return [];
    }
  }

  // Create share code for a trip
  Future<String?> createShareCode(TripPlan trip) async {
    try {
      debugPrint('🔗 Creating share code for: ${trip.destination}');

      final response = await _dio.post(
        '/trip/share',
        data: {'trip': trip.toJson()},
      );

      final code = response.data['code'] as String?;
      debugPrint('✅ Share code generated: $code');
      return code;
    } on DioException catch (e) {
      debugPrint('❌ Error creating share code: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected share error: $e');
      return null;
    }
  }

  // Get trip by share code
  Future<TripPlan?> getTripByShareCode(String code) async {
    try {
      debugPrint('📥 Fetching shared trip with code: $code');

      final response = await _dio.get('/trip/share/${code.toUpperCase()}');

      if (response.data['error'] != null) {
        debugPrint('❌ ${response.data['error']}');
        return null;
      }

      final trip = TripPlan.fromJson(response.data);
      debugPrint('✅ Shared trip loaded: ${trip.destination}');
      return trip;
    } on DioException catch (e) {
      debugPrint('❌ Error fetching shared trip: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      return null;
    }
  }
}

// Data models
class TravelGuide {
  final String name;
  final String state;
  final int days;
  final int spots;
  final String description;
  final String imageUrl;

  TravelGuide({
    required this.name,
    required this.state,
    required this.days,
    required this.spots,
    required this.description,
    required this.imageUrl,
  });

  factory TravelGuide.fromJson(Map<String, dynamic> json) {
    return TravelGuide(
      name: json['name'] ?? '',
      state: json['state'] ?? '',
      days: json['days'] ?? 2,
      spots: json['spots'] ?? 10,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}

class LocationResult {
  final String name;
  final String fullName;
  final double latitude;
  final double longitude;
  final String? state;

  LocationResult({
    required this.name,
    required this.fullName,
    required this.latitude,
    required this.longitude,
    this.state,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      name: json['name'] ?? '',
      fullName: json['fullName'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      state: json['state'],
    );
  }
}

class TripPlan {
  final String destination;
  final int days;
  final CityInfo? cityInfo;
  final List<TripDay> itinerary;
  final Map<String, dynamic>? routeGeometry;

  TripPlan({
    required this.destination,
    required this.days,
    this.cityInfo,
    required this.itinerary,
    this.routeGeometry,
  });

  factory TripPlan.fromJson(Map<String, dynamic> json) {
    return TripPlan(
      destination: json['destination'] ?? '',
      days: json['days'] ?? 1,
      cityInfo: json['cityInfo'] != null
          ? CityInfo.fromJson(json['cityInfo'])
          : null,
      itinerary: (json['itinerary'] as List? ?? [])
          .map((day) => TripDay.fromJson(day))
          .toList(),
      routeGeometry: json['routeGeometry'],
    );
  }
}

class CityInfo {
  final String description;
  final String? imageUrl;

  CityInfo({required this.description, this.imageUrl});

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
    );
  }
}

class TripDay {
  final int dayNumber;
  final List<TripPlace> places;

  TripDay({required this.dayNumber, required this.places});

  factory TripDay.fromJson(Map<String, dynamic> json) {
    return TripDay(
      dayNumber: json['dayNumber'] ?? 1,
      places: (json['places'] as List? ?? [])
          .map((place) => TripPlace.fromJson(place))
          .toList(),
    );
  }
}

class TripPlace {
  final String placeName;
  final String category;
  final String description;
  final String duration;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final String? history;

  TripPlace({
    required this.placeName,
    required this.category,
    required this.description,
    required this.duration,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.history,
  });

  factory TripPlace.fromJson(Map<String, dynamic> json) {
    return TripPlace(
      placeName: json['placeName'] ?? '',
      category: json['category'] ?? 'ATTRACTION',
      description: json['description'] ?? '',
      duration: json['duration'] ?? '1 hour',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrl: json['imageUrl'],
      history: json['history'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'placeName': placeName,
      'category': category,
      'description': description,
      'duration': duration,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'history': history,
    };
  }
}

extension TripPlanJson on TripPlan {
  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'days': days,
      'cityInfo': cityInfo?.toJson(),
      'itinerary': itinerary.map((day) => day.toJson()).toList(),
    };
  }
}

extension CityInfoJson on CityInfo {
  Map<String, dynamic> toJson() {
    return {'description': description, 'imageUrl': imageUrl};
  }
}

extension TripDayJson on TripDay {
  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'places': places.map((place) => place.toJson()).toList(),
    };
  }
}
