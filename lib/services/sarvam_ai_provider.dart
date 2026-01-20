import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sarvam_ai_service.dart';

/// Provider for Sarvam AI service
final sarvamAIServiceProvider = Provider<SarvamAIService>((ref) {
  final service = SarvamAIService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for place description
final placeDescriptionProvider =
    FutureProvider.family<String, Map<String, String>>((ref, params) async {
      final service = ref.read(sarvamAIServiceProvider);
      return await service.getPlaceDescription(
        placeName: params['placeName']!,
        city: params['city']!,
        state: params['state'],
      );
    });

/// Provider for trip recommendations
final tripRecommendationsProvider =
    FutureProvider.family<String, Map<String, dynamic>>((ref, params) async {
      final service = ref.read(sarvamAIServiceProvider);
      return await service.getTripRecommendations(
        destination: params['destination'] as String,
        days: params['days'] as int,
        interests: params['interests'] as List<String>,
      );
    });

/// Provider for local insights
final localInsightsProvider =
    FutureProvider.family<String, Map<String, String?>>((ref, params) async {
      final service = ref.read(sarvamAIServiceProvider);
      return await service.getLocalInsights(
        city: params['city']!,
        specificQuery: params['query'],
      );
    });

/// Provider for enhanced trip suggestions
final enhancedTripProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      params,
    ) async {
      final service = ref.read(sarvamAIServiceProvider);
      return await service.enhanceTripWithAI(
        selectedSpots: params['spots'] as List<String>,
        destination: params['destination'] as String,
        duration: params['duration'] as int,
      );
    });

/// Provider for seasonal advice
final seasonalAdviceProvider =
    FutureProvider.family<String, Map<String, dynamic>>((ref, params) async {
      final service = ref.read(sarvamAIServiceProvider);
      return await service.getSeasonalAdvice(
        destination: params['destination'] as String,
        travelDate: params['date'] as DateTime,
      );
    });
