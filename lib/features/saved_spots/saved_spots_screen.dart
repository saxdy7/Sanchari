import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'spot_detail_screen.dart';
import 'search_spots_screen.dart';
import '../../services/database_service.dart';

// Sample saved spot model
class SavedSpot {
  final String savedSpotId; // ID from saved_spots table for deletion
  final String name;
  final String city;
  final String state;
  final String country;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;
  final String category;
  final List<String> communityNotes;
  final String? website;
  bool isSaved;

  SavedSpot({
    required this.savedSpotId,
    required this.name,
    required this.city,
    required this.state,
    required this.country,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.communityNotes = const [],
    this.website,
    this.isSaved = true,
  });
}

// Provider to fetch saved spots from database with real-time updates
final savedSpotsProvider = StreamProvider.autoDispose<List<SavedSpot>>((
  ref,
) async* {
  final dbService = ref.read(databaseServiceProvider);
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    yield [];
    return;
  }

  // Initial load
  final initialData = await dbService.getSavedSpots();
  debugPrint('🔍 Initial load: ${initialData.length} spots');
  yield _processSpotsData(initialData);

  // Subscribe to real-time changes
  final channel = Supabase.instance.client
      .channel('saved_spots_changes')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'saved_spots',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'user_id',
          value: user.id,
        ),
        callback: (payload) async {
          debugPrint('🔄 Real-time update detected: ${payload.eventType}');
          final updatedData = await dbService.getSavedSpots();
          debugPrint('✅ Refreshed: ${updatedData.length} spots');
        },
      )
      .subscribe();

  // Listen to database changes and refresh
  await for (final _ in Stream.periodic(const Duration(seconds: 2))) {
    final spotsData = await dbService.getSavedSpots();
    yield _processSpotsData(spotsData);
  }

  // Cleanup on dispose
  ref.onDispose(() {
    debugPrint('🧹 Cleaning up real-time subscription');
    channel.unsubscribe();
  });
});

List<SavedSpot> _processSpotsData(List<Map<String, dynamic>> spotsData) {
  debugPrint('🔍 Processing ${spotsData.length} spots from database');

  final spots = <SavedSpot>[];

  for (var data in spotsData) {
    try {
      debugPrint('📦 Raw data: $data');

      // Get spot data from the 'spots' key
      if (!data.containsKey('spots') || data['spots'] == null) {
        debugPrint('⚠️ No spot data found in item, skipping');
        debugPrint('Available keys: ${data.keys.toList()}');
        continue;
      }

      final spot = data['spots'] as Map<String, dynamic>;
      final savedSpotId = data['id'] as String; // Get the saved_spots table ID
      debugPrint('🎯 Spot data: $spot');

      spots.add(
        SavedSpot(
          savedSpotId: savedSpotId,
          name: spot['name'] ?? 'Unknown',
          city: spot['city'] ?? '',
          state: spot['state'] ?? '',
          country: 'India', // Default as not stored in DB
          description: spot['description'] ?? 'Saved from search',
          imageUrl:
              spot['image_url'] ??
              'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?w=800',
          latitude: (spot['latitude'] as num).toDouble(),
          longitude: (spot['longitude'] as num).toDouble(),
          category: spot['category'] ?? 'Other',
          communityNotes: [],
          website: null,
        ),
      );
    } catch (e, stack) {
      debugPrint('❌ Error parsing spot: $e');
      debugPrint('Stack: $stack');
    }
  }

  debugPrint('✅ Successfully converted ${spots.length} spots');
  return spots;
}

class SavedSpotsScreen extends ConsumerStatefulWidget {
  const SavedSpotsScreen({super.key});

  @override
  ConsumerState<SavedSpotsScreen> createState() => _SavedSpotsScreenState();
}

class _SavedSpotsScreenState extends ConsumerState<SavedSpotsScreen> {
  final MapController _mapController = MapController();
  bool _showMap = true;

  @override
  Widget build(BuildContext context) {
    final savedSpotsAsync = ref.watch(savedSpotsProvider);

    return savedSpotsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading spots: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(savedSpotsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (savedSpots) {
        final spotsCount = savedSpots.length;

        // Group spots by country
        final groupedSpots = <String, List<SavedSpot>>{};
        for (var spot in savedSpots) {
          groupedSpots.putIfAbsent(spot.country, () => []).add(spot);
        }

        return _buildSpotsUI(context, savedSpots, spotsCount, groupedSpots);
      },
    );
  }

  Widget _buildSpotsUI(
    BuildContext context,
    List<SavedSpot> savedSpots,
    int spotsCount,
    Map<String, List<SavedSpot>> groupedSpots,
  ) {
    return Scaffold(
      body: Stack(
        children: [
          // Map background
          if (_showMap)
            Positioned.fill(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: savedSpots.isNotEmpty
                      ? LatLng(
                          savedSpots.first.latitude,
                          savedSpots.first.longitude,
                        )
                      : const LatLng(20.5937, 78.9629),
                  initialZoom: 5,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sanchari.app',
                  ),
                  MarkerLayer(
                    markers: savedSpots.map((spot) {
                      return Marker(
                        point: LatLng(spot.latitude, spot.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SpotDetailScreen(spot: spot),
                              ),
                            );
                          },
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Top search button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FloatingActionButton(
              heroTag: 'search',
              backgroundColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchSpotsScreen()),
                );
              },
              child: const Icon(Icons.search, color: Colors.black),
            ),
          ),

          // Bottom sheet
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            'My Spots',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Import guides functionality
                            },
                            icon: const Icon(Icons.download, size: 18),
                            label: Text(
                              'Import Guides',
                              style: GoogleFonts.outfit(fontSize: 14),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              side: const BorderSide(color: Colors.black),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '$spotsCount Spots Saved',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Spots list
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: groupedSpots.entries.map((entry) {
                          final country = entry.key;
                          final spots = entry.value;
                          final cities = spots.map((s) => s.city).toSet();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    country,
                                    style: GoogleFonts.outfit(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${cities.length} Cities • ${spots.length} Spots',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // City cards
                              SizedBox(
                                height: 220,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: cities.length,
                                  itemBuilder: (context, index) {
                                    final city = cities.elementAt(index);
                                    final citySpots = spots
                                        .where((s) => s.city == city)
                                        .toList();
                                    final firstSpot = citySpots.first;

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => SpotDetailScreen(
                                                spot: firstSpot,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Container(
                                                width: 240,
                                                height: 160,
                                                color: Colors.grey[200],
                                                child: CachedNetworkImage(
                                                  imageUrl: firstSpot.imageUrl,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(
                                                            Icons.place,
                                                            size: 48,
                                                          ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              city,
                                              style: GoogleFonts.outfit(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '${citySpots.length} Spots',
                                              style: GoogleFonts.outfit(
                                                fontSize: 14,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
