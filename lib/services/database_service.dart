import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';

class DatabaseService {
  // ===== TRIPS =====

  Future<Map<String, dynamic>> createTrip({
    required String destination,
    required String? state,
    required int days,
    required List<String> preferences,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Generate 4-digit share code
    final shareCode = (1000 + DateTime.now().millisecondsSinceEpoch % 9000)
        .toString();

    final response = await supabase
        .from('trips')
        .insert({
          'user_id': user.id,
          'destination': destination,
          'state': state,
          'days': days,
          'preferences': preferences,
          'share_code': shareCode,
          'status': 'PLANNED',
        })
        .select()
        .single();

    return response;
  }

  Future<List<Map<String, dynamic>>> getUserTrips() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('trips')
        .select('*, itinerary_days(*, itinerary_items(*))')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>?> getTripByShareCode(String code) async {
    final response = await supabase
        .from('trips')
        .select('*, itinerary_days(*, itinerary_items(*))')
        .eq('share_code', code)
        .maybeSingle();

    return response;
  }

  // ===== SAVED SPOTS =====

  Future<void> saveSpot(String spotId) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await supabase.from('saved_spots').insert({
      'user_id': user.id,
      'spot_id': spotId,
    });
  }

  Future<Map<String, dynamic>> saveSpotFromLocation({
    required String userId,
    required String name,
    required String city,
    required String state,
    required String country, // Kept for API compatibility but won't be saved
    required double latitude,
    required double longitude,
  }) async {
    try {
      debugPrint('🔍 Saving spot: $name at ($latitude, $longitude)');

      // Step 1: Check if spot already exists (use limit to avoid multiple row error)
      final existingSpots = await supabase
          .from('spots')
          .select('id')
          .eq('latitude', latitude)
          .eq('longitude', longitude)
          .limit(1);

      String spotId;

      if (existingSpots.isNotEmpty) {
        spotId = existingSpots.first['id'];
        debugPrint('✅ Found existing spot: $spotId');
      } else {
        // Create new spot (without country field - doesn't exist in DB)
        final spotData = {
          'name': name,
          'city': city,
          'state': state,
          'latitude': latitude,
          'longitude': longitude,
          'category': 'OTHER',
          'description': 'Saved from search',
        };

        final spotResponse = await supabase
            .from('spots')
            .insert(spotData)
            .select()
            .single();

        spotId = spotResponse['id'];
        debugPrint('✅ Created new spot: $spotId');
      }

      // Step 2: Check if already saved by this user
      final alreadySaved = await supabase
          .from('saved_spots')
          .select('id')
          .eq('user_id', userId)
          .eq('spot_id', spotId)
          .maybeSingle();

      if (alreadySaved != null) {
        debugPrint('⚠️ Spot already saved by user');
        return {
          'success': true,
          'alreadySaved': true,
          'message': 'This spot is already in your saved list',
        };
      }

      // Step 3: Save the reference in saved_spots table
      await supabase.from('saved_spots').insert({
        'user_id': userId,
        'spot_id': spotId,
      });

      debugPrint('✅ Successfully saved spot!');
      return {
        'success': true,
        'alreadySaved': false,
        'message': 'Spot saved successfully!',
      };
    } catch (e, stack) {
      debugPrint('❌ Error saving spot: $e');
      debugPrint('Stack: $stack');
      return {
        'success': false,
        'alreadySaved': false,
        'message': 'Failed to save spot: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> saveSpotFromLocationWithImage({
    required String userId,
    required String name,
    required String city,
    required String state,
    required double latitude,
    required double longitude,
    String? imageUrl,
    String? description,
  }) async {
    try {
      debugPrint('🔍 Saving spot with image: $name at ($latitude, $longitude)');
      debugPrint('🖼️ Image URL: ${imageUrl ?? "None"}');

      // Step 1: Check if spot already exists
      final existingSpots = await supabase
          .from('spots')
          .select('id')
          .eq('latitude', latitude)
          .eq('longitude', longitude)
          .limit(1);

      String spotId;

      if (existingSpots.isNotEmpty) {
        spotId = existingSpots.first['id'];
        debugPrint('✅ Found existing spot: $spotId');

        // Update existing spot with image if provided
        if (imageUrl != null) {
          await supabase
              .from('spots')
              .update({
                'image_url': imageUrl,
                if (description != null) 'description': description,
              })
              .eq('id', spotId);
          debugPrint('✅ Updated existing spot with Wikipedia image');
        }
      } else {
        // Create new spot with image
        final spotData = {
          'name': name,
          'city': city,
          'state': state,
          'latitude': latitude,
          'longitude': longitude,
          'category': 'OTHER',
          'description': description ?? 'Saved from search',
          if (imageUrl != null) 'image_url': imageUrl,
        };

        final spotResponse = await supabase
            .from('spots')
            .insert(spotData)
            .select()
            .single();

        spotId = spotResponse['id'];
        debugPrint('✅ Created new spot with Wikipedia image: $spotId');
      }

      // Step 2: Check if already saved by this user
      final alreadySaved = await supabase
          .from('saved_spots')
          .select('id')
          .eq('user_id', userId)
          .eq('spot_id', spotId)
          .maybeSingle();

      if (alreadySaved != null) {
        debugPrint('⚠️ Spot already saved by user');
        return {
          'success': true,
          'alreadySaved': true,
          'message': 'This spot is already in your saved list',
        };
      }

      // Step 3: Save the reference in saved_spots table
      await supabase.from('saved_spots').insert({
        'user_id': userId,
        'spot_id': spotId,
      });

      debugPrint('✅ Successfully saved spot with Wikipedia data!');
      return {
        'success': true,
        'alreadySaved': false,
        'message': 'Spot saved successfully with image!',
      };
    } catch (e, stack) {
      debugPrint('❌ Error saving spot: $e');
      debugPrint('Stack: $stack');
      return {
        'success': false,
        'alreadySaved': false,
        'message': 'Failed to save spot: ${e.toString()}',
      };
    }
  }

  Future<List<Map<String, dynamic>>> getSavedSpots() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No user logged in');
      return [];
    }

    debugPrint('✅ Fetching saved spots for user: ${user.id}');

    try {
      // Query with proper join - spots is the foreign key reference
      final response = await supabase
          .from('saved_spots')
          .select('id, created_at, spot_id, spots(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      debugPrint('📊 Saved spots raw response: $response');
      debugPrint('📊 Response type: ${response.runtimeType}');
      debugPrint('📊 Number of spots: ${response.length}');

      // Log first item to see structure
      if (response.isNotEmpty) {
        debugPrint('📦 First item structure: ${response.first}');
        debugPrint('📦 Keys: ${(response.first as Map).keys.toList()}');
      }

      debugPrint('🔍 Processing ${response.length} spots from database');

      if (response.isEmpty) {
        debugPrint('! No saved spots found for this user');
      } else {
        for (var item in response) {
          debugPrint(
            '  - Saved spot ID: ${item['id']}, Spot data: ${item['spots']}',
          );
        }
      }

      debugPrint('✅ Successfully parsed ${response.length} spots');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stack) {
      debugPrint('❌ Error fetching saved spots: $e');
      debugPrint('Stack trace: $stack');
      return [];
    }
  }

  Future<bool> deleteSavedSpot(String savedSpotId) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('❌ No user logged in');
      return false;
    }

    try {
      debugPrint('🗑️ Deleting saved spot: $savedSpotId');

      await supabase
          .from('saved_spots')
          .delete()
          .eq('id', savedSpotId)
          .eq(
            'user_id',
            user.id,
          ); // Ensure user can only delete their own saved spots

      debugPrint('✅ Saved spot deleted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting saved spot: $e');
      return false;
    }
  }

  // ===== ANALYTICS =====

  Future<void> logSearch({required String query, String? destination}) async {
    final user = supabase.auth.currentUser;

    await supabase.from('search_logs').insert({
      'user_id': user?.id,
      'query': query,
      'destination': destination,
    });
  }

  Future<void> logGuideView({
    required String guideName,
    required String destination,
  }) async {
    final user = supabase.auth.currentUser;

    await supabase.from('guide_views').insert({
      'user_id': user?.id,
      'guide_name': guideName,
      'destination': destination,
    });
  }

  // ===== TRAVEL GUIDES =====

  Future<List<Map<String, dynamic>>> getTravelGuides() async {
    final response = await supabase
        .from('travel_guides')
        .select()
        .eq('is_popular', true)
        .order('destination');

    return List<Map<String, dynamic>>.from(response);
  }
}

// Database service provider
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
