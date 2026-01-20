import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/trip_api_service.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TripResultScreen extends ConsumerStatefulWidget {
  final String destination;
  final int days;
  final List<String> preferences;
  final bool isShared;
  final String? shareCode;
  final TripPlan? savedTripData; // Pre-loaded trip data from database

  const TripResultScreen({
    super.key,
    required this.destination,
    required this.days,
    this.preferences = const [],
    required this.isShared,
    this.shareCode,
    this.savedTripData,
  });

  @override
  ConsumerState<TripResultScreen> createState() => _TripResultScreenState();
}

class _TripResultScreenState extends ConsumerState<TripResultScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  TripPlan? _tripPlan;
  bool _isLoading = true;
  String? _error;
  String? _generatedCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.days + 1, vsync: this);
    _loadTripPlan();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTripPlan() async {
    // If we have saved trip data, use it directly
    if (widget.savedTripData != null) {
      debugPrint('📂 Loading saved trip data for: ${widget.destination}');
      setState(() {
        _tripPlan = widget.savedTripData;
        _isLoading = false;
        _tabController = TabController(
          length: widget.savedTripData!.itinerary.length + 1,
          vsync: this,
        );
      });
      return;
    }

    // Otherwise, generate a new trip
    setState(() {
      _isLoading = true;
      _error = null;
    });

    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        debugPrint(
          '🔵 Generating new trip for: ${widget.destination}, ${widget.days} days (Attempt ${retryCount + 1})',
        );

        final apiService = ref.read(tripApiServiceProvider);
        final plan = await apiService.generateTrip(
          destination: widget.destination,
          days: widget.days,
          preferences: widget.preferences,
        );

        debugPrint('🔵 Plan received: ${plan != null ? "SUCCESS" : "NULL"}');

        if (plan != null && plan.itinerary.isNotEmpty) {
          debugPrint('🔵 Itinerary has ${plan.itinerary.length} days');
          setState(() {
            _tripPlan = plan;
            _isLoading = false;
            _tabController = TabController(
              length: plan.itinerary.length + 1,
              vsync: this,
            );
          });

          // Auto-save the trip for the current user
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            debugPrint('💾 Auto-saving trip for user: ${user.id}');
            try {
              await apiService.saveTrip(plan, user.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Trip saved successfully! ✅'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (saveError) {
              debugPrint('❌ Save error: $saveError');
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to save trip: $saveError'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            }
          } else {
            debugPrint('⚠️ No user logged in, trip not saved');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please sign in to save trips'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }

          return; // Success, exit retry loop
        } else {
          debugPrint('❌ Plan is null or empty itinerary');
          setState(() {
            _error =
                'No trip data received. This destination might not have enough tourist spots in our database yet.';
            _isLoading = false;
          });
          return;
        }
      } on DioException catch (e) {
        debugPrint(
          '❌ Dio Error (Attempt ${retryCount + 1}): ${e.type} - ${e.message}',
        );
        retryCount++;

        if (retryCount >= maxRetries) {
          setState(() {
            _error =
                'Connection error after $maxRetries attempts.\n\n'
                'Please check:\n'
                '• Backend is running at http://localhost:3000\n'
                '• Internet connection is stable\n\n'
                'Error: ${e.message}';
            _isLoading = false;
          });
          return;
        }

        // Exponential backoff: wait 2^retry seconds
        final waitTime = Duration(seconds: (1 << retryCount));
        debugPrint('⏳ Retrying in ${waitTime.inSeconds} seconds...');
        await Future.delayed(waitTime);
      } catch (e) {
        debugPrint('❌ General Error: $e');
        setState(() {
          _error = 'Unexpected error: $e';
          _isLoading = false;
        });
        return;
      }
    }
  }

  Future<void> _generateShareCode() async {
    if (_tripPlan == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final apiService = ref.read(tripApiServiceProvider);
      final code = await apiService.createShareCode(_tripPlan!);

      if (!mounted) return;
      Navigator.pop(context); // Close loading

      if (code == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate share code')),
        );
        return;
      }

      setState(() {
        _generatedCode = code;
      });

      _showShareDialog(code);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _showShareDialog(String code) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.share, size: 48, color: Color(0xFF1A1A2E)),
            const SizedBox(height: 16),
            Text(
              'Share this trip',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share this code with your friends',
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                code,
                style: GoogleFonts.outfit(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Valid for 24 hours',
              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: code));
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Code copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // State for selected day (0 = Overview, 1 = Day 1, etc.)
  int _selectedDayIndex = 1;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    final plan = _tripPlan!;

    // Get spots for the selected day
    List<TripPlace> currentSpots = [];
    if (_selectedDayIndex > 0 && _selectedDayIndex <= plan.itinerary.length) {
      final dayObj = plan.itinerary.firstWhere(
        (d) => d.dayNumber == _selectedDayIndex,
        orElse: () => plan.itinerary.first,
      );
      currentSpots = dayObj.places;
    } else {
      // Overview: Show all spots
      currentSpots = plan.itinerary.expand((d) => d.places).toList();
    }

    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Background (Full Screen)
          Positioned.fill(child: _buildMap(plan, currentSpots)),

          // Back Button & Share (Floating over Map)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: const Icon(Icons.share, color: Colors.black),
                    onPressed: _generateShareCode,
                  ),
                ),
              ],
            ),
          ),

          // 2. Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Destination & Date Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.destination,
                                  style: GoogleFonts.outfit(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${plan.days} Days Trip',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50], // Light blue accent
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Day Tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          _buildDayTab(0, "Overview"),
                          ...List.generate(plan.days, (index) {
                            return _buildDayTab(index + 1, "Day ${index + 1}");
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),

                    // List of Places
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        itemCount: currentSpots.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final place = currentSpots[index];
                          // Calculate global index for marker number
                          // If day view, it's index + 1
                          // If overview, we might need global index logic, but let's keep it simple
                          final markerNum = index + 1;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Number
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                child: Text(
                                  '$markerNum.',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey[200]!,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.02),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey[100],
                                          child: place.imageUrl != null
                                              ? CachedNetworkImage(
                                                  imageUrl: place.imageUrl!,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          const Icon(
                                                            Icons.image,
                                                            color: Colors.grey,
                                                          ),
                                                )
                                              : const Icon(
                                                  Icons.image,
                                                  color: Colors.grey,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              place.placeName,
                                              style: GoogleFonts.outfit(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                place.category,
                                                style: GoogleFonts.outfit(
                                                  fontSize: 10,
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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

  Widget _buildDayTab(int index, String label) {
    final isSelected = _selectedDayIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDayIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMap(TripPlan plan, List<TripPlace> places) {
    // Collect markers
    final markers = places
        .asMap()
        .entries
        .map((entry) {
          final place = entry.value;
          final idx = entry.key + 1;
          if (place.latitude == null || place.longitude == null) return null;
          return Marker(
            width: 40,
            height: 40,
            point: LatLng(place.latitude!, place.longitude!),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blue, // Blue markers like screenshot
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: Center(
                child: Text(
                  '$idx',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        })
        .whereType<Marker>()
        .toList();

    // Parse OSRM route geometry (GeoJSON)
    List<LatLng> routePoints = [];
    if (plan.routeGeometry != null &&
        plan.routeGeometry!['coordinates'] != null) {
      final coordinates = plan.routeGeometry!['coordinates'] as List;
      routePoints = coordinates.map((c) => LatLng(c[1], c[0])).toList();
      // Optimization: We could filter route points to only show leg for this day,
      // but OSRM gives one big polyline. For now, showing full route is fine,
      // or we can just show no route if simple.
      // The screenshot shows a path. Let's keep the path.
    }

    // Determine center
    final center = places.isNotEmpty && places[0].latitude != null
        ? LatLng(places[0].latitude!, places[0].longitude!)
        : const LatLng(20.5937, 78.9629);

    return FlutterMap(
      key: ValueKey(
        _selectedDayIndex,
      ), // Force rebuild to recenter map when day changes
      options: MapOptions(initialCenter: center, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.sanchari.app',
        ),
        if (routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(points: routePoints, color: Colors.blue, strokeWidth: 5),
            ],
          ),
        MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.black),
            const SizedBox(height: 24),
            Text(
              'Planning your perfect trip...',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Finding the best spots in ${widget.destination}',
              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      body: Center(child: Text(_error ?? 'Error', style: GoogleFonts.outfit())),
    );
  }
}
