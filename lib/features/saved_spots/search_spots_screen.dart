import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/trip_api_service.dart';
import '../../services/database_service.dart';
import 'saved_spots_screen.dart'; // For savedSpotsProvider
// import 'spot_detail_screen.dart';

class SearchSpotsScreen extends ConsumerStatefulWidget {
  const SearchSpotsScreen({super.key});

  @override
  ConsumerState<SearchSpotsScreen> createState() => _SearchSpotsScreenState();
}

class _SearchSpotsScreenState extends ConsumerState<SearchSpotsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  List<LocationResult> _searchResults = [];
  bool _isSearching = false;
  String _searchQuery = '';
  LocationResult? _selectedLocation;
  String? _aiDescription;
  bool _loadingAiInfo = false;
  bool _showMap = true;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _fetchAiDescription(LocationResult location) async {
    if (!mounted) return;

    setState(() {
      _loadingAiInfo = true;
      _aiDescription = null;
    });

    try {
      final apiService = ref.read(tripApiServiceProvider);
      final locationName = location.state != null
          ? '${location.name}, ${location.state}'
          : location.name;

      debugPrint('🤖 Fetching AI context for: $locationName');

      final description = await apiService.getAiContext(locationName);

      if (!mounted) return;

      setState(() {
        _aiDescription = description;
        _loadingAiInfo = false;
      });

      debugPrint('✅ AI context loaded for: $locationName');
    } catch (e) {
      debugPrint('❌ AI description error: $e');
      if (mounted) {
        setState(() {
          _aiDescription = 'A beautiful destination in India worth exploring.';
          _loadingAiInfo = false;
        });
      }
    }
  }

  void _selectLocation(LocationResult location) {
    if (!mounted) return;

    setState(() {
      _selectedLocation = location;
      _aiDescription = null; // Clear previous description
    });

    // Fetch AI description asynchronously
    _fetchAiDescription(location);

    // Animate map to selected location
    try {
      _mapController.move(LatLng(location.latitude, location.longitude), 12);
    } catch (e) {
      debugPrint('❌ Error moving map: $e');
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searchQuery = '';
          _selectedLocation = null;
          _aiDescription = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSearching = true;
        _searchQuery = query;
      });
    }

    try {
      final apiService = ref.read(tripApiServiceProvider);
      final results = await apiService.searchDestinations(query);

      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isSearching = false;
        _selectedLocation =
            null; // Clear selection when new search results arrive
        _aiDescription = null;
      });

      debugPrint('✅ Found ${results.length} results for "$query"');
    } catch (e) {
      debugPrint('❌ Search error: $e');
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _saveSpot(LocationResult location) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please sign in to save spots'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Cache services before async operations to avoid ref error
    final apiService = ref.read(tripApiServiceProvider);
    final dbService = ref.read(databaseServiceProvider);

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Fetching comprehensive info...'),
              ],
            ),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.blue[700],
          ),
        );
      }

      // Fetch comprehensive place info (Wikipedia + Pixabay + Sarvam AI)
      debugPrint('🖼️ Fetching comprehensive data for ${location.name}');

      final wikiInfo = await apiService.getPlaceInfo(
        location.name,
        city: location.state,
      );

      final imageUrl = wikiInfo['imageUrl'] as String?;
      final description = wikiInfo['description'] as String?;
      final source = wikiInfo['source'] as String?;

      debugPrint('✅ Image from $source: ${imageUrl ?? "Not found"}');
      debugPrint('✅ Description length: ${description?.length ?? 0} chars');

      // Save to database with comprehensive info
      final result = await dbService.saveSpotFromLocationWithImage(
        userId: user.id,
        name: location.name,
        city: location.name,
        state: location.state ?? '',
        latitude: location.latitude,
        longitude: location.longitude,
        imageUrl: imageUrl,
        description: description ?? 'Saved from search',
      );

      if (!mounted) return;

      // Clear loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (result['success'] == true) {
        if (result['alreadySaved'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${location.name} is already saved! ℹ️'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      imageUrl != null
                          ? '${location.name} saved with ${source ?? 'image'}! ✅'
                          : '${location.name} saved! ✅',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Invalidate the saved spots provider to force refresh
          ref.invalidate(savedSpotsProvider);

          // Clear selected location for better UX
          setState(() {
            _selectedLocation = null;
            _aiDescription = null;
          });

          debugPrint(
            '✅ Spot saved with Wikipedia data and provider invalidated',
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to save spot'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error saving spot: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Search Spots',
          style: GoogleFonts.outfit(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Map view with search results markers
          if (_searchResults.isNotEmpty && _showMap)
            Container(
              height: 250,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(
                      _searchResults.first.latitude,
                      _searchResults.first.longitude,
                    ),
                    initialZoom: _searchResults.length == 1 ? 12 : 6,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sanchari.app',
                    ),
                    MarkerLayer(
                      markers: _searchResults.map((location) {
                        final isSelected =
                            _selectedLocation?.name == location.name;
                        return Marker(
                          point: LatLng(location.latitude, location.longitude),
                          width: 40,
                          height: 40,
                          child: GestureDetector(
                            onTap: () => _selectLocation(location),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.red : Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
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
            ),

          // Selected location AI info card
          if (_selectedLocation != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_city,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedLocation!.name,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.blue[700]),
                        onPressed: () {
                          setState(() {
                            _selectedLocation = null;
                            _aiDescription = null;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_selectedLocation!.state != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedLocation!.state!,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_loadingAiInfo)
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Loading AI insights...',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.blue[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    )
                  else if (_aiDescription != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Colors.amber[700],
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'AI Insights',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _aiDescription!,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.blue[800],
                            height: 1.5,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lon: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.bookmark_add,
                          color: Colors.amber[700],
                        ),
                        onPressed: () => _saveSpot(_selectedLocation!),
                        tooltip: 'Save this spot',
                      ),
                    ],
                  ),
                ],
              ),
            ),

          if (_selectedLocation != null) const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _performSearch(value);
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Search for places...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: GoogleFonts.outfit(fontSize: 15),
            ),
          ),

          // Search results or empty state
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Search for places to save'
                              : 'No results found',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Try searching for cities or landmarks',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final location = _searchResults[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.place, color: Colors.blue[700]),
                          ),
                          title: Text(
                            location.name,
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            location.fullName,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.bookmark_border,
                              color: Colors.amber[700],
                            ),
                            onPressed: () => _saveSpot(location),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
