import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../trips/trip_result_screen.dart';
import '../profile/profile_screen.dart';
import '../../services/trip_api_service.dart';
import 'widgets/auto_scroll_banner.dart';
import 'widgets/import_trip_dialog.dart';

class RoamyHomeScreen extends ConsumerWidget {
  const RoamyHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the providers
    final myTripsAsync = ref.watch(userTripsProvider);
    final guidesAsync = ref.watch(popularDestinationsProvider);

    // Get user info for profile picture
    final user = Supabase.instance.client.auth.currentUser;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Pull to refresh support
            ref.invalidate(userTripsProvider);
            ref.invalidate(popularDestinationsProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/Sanchari.png', height: 32),
                      Row(
                        children: [
                          // Import Trip Button
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF80DEEA).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.download,
                                color: Color(0xFF1A1A2E),
                                size: 20,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const ImportTripDialog(),
                                );
                              },
                              tooltip: 'Import Trip',
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Profile Button
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: avatarUrl != null && avatarUrl.isNotEmpty
                                ? CircleAvatar(
                                    radius: 20,
                                    backgroundImage: CachedNetworkImageProvider(
                                      avatarUrl,
                                    ),
                                    backgroundColor: const Color(0xFF80DEEA),
                                  )
                                : CircleAvatar(
                                    radius: 20,
                                    backgroundColor: const Color(0xFF80DEEA),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Auto-scrolling Banners
                const SizedBox(height: 24),
                const AutoScrollBanner(),
                const SizedBox(height: 32),

                // Travel Guides Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Explore Destinations',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Travel Guides List
                guidesAsync.when(
                  loading: () => const SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        'Failed to load destinations',
                        style: GoogleFonts.outfit(color: Colors.grey),
                      ),
                    ),
                  ),
                  data: (guides) => SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: guides.length,
                      itemBuilder: (context, index) {
                        final guide = guides[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TripResultScreen(
                                  destination: guide.name,
                                  days: guide.days,
                                  isShared: false,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 180,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Background Image
                                  CachedNetworkImage(
                                    imageUrl: guide.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.image,
                                            size: 50,
                                          ),
                                        ),
                                  ),
                                  // Gradient Overlay
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Content
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // State Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 12,
                                                color: Colors.red,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  guide.state,
                                                  style: GoogleFonts.outfit(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        // Destination Name
                                        Text(
                                          guide.name,
                                          style: GoogleFonts.outfit(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Description
                                        Text(
                                          guide.description,
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: Colors.white70,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        // Stats Row
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${guide.days} days',
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Icon(
                                              Icons.place,
                                              size: 14,
                                              color: Colors.white70,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${guide.spots} spots',
                                              style: GoogleFonts.outfit(
                                                fontSize: 12,
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // My Trips Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Trips',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Real User Trips
                myTripsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Failed to load trips',
                        style: GoogleFonts.outfit(color: Colors.grey),
                      ),
                    ),
                  ),
                  data: (trips) {
                    if (trips.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.luggage_outlined,
                                size: 64,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No trips yet',
                                style: GoogleFonts.outfit(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start planning your first adventure!',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Color palette for trip cards
                    final colors = [
                      const Color(0xFFE3F2FD), // Light Blue
                      const Color(0xFFF1F8E9), // Light Green
                      const Color(0xFFFCE4EC), // Light Pink
                      const Color(0xFFFFF3E0), // Light Orange
                      const Color(0xFFE8EAF6), // Light Indigo
                    ];

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];
                        final tripId = trip['id'] as String;
                        final tripData =
                            trip['trip_data'] as Map<String, dynamic>;
                        final destination = tripData['destination'] as String;
                        final days = tripData['days'] as int;
                        final cityInfo =
                            tripData['cityInfo'] as Map<String, dynamic>?;
                        final imageUrl = cityInfo?['imageUrl'] as String?;

                        // Count total spots
                        final itinerary =
                            tripData['itinerary'] as List<dynamic>?;
                        int totalSpots = 0;
                        if (itinerary != null) {
                          for (var day in itinerary) {
                            final places = day['places'] as List<dynamic>?;
                            if (places != null) totalSpots += places.length;
                          }
                        }

                        final cardColor = colors[index % colors.length];

                        return Dismissible(
                          key: Key(tripId),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (direction) async {
                            // Show confirmation dialog
                            final confirmed =
                                await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(
                                        'Delete Trip',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      content: Text(
                                        'Are you sure you want to delete this trip to $destination?',
                                        style: GoogleFonts.outfit(),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: Text(
                                            'Cancel',
                                            style: GoogleFonts.outfit(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: Text(
                                            'Delete',
                                            style: GoogleFonts.outfit(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ) ??
                                false;

                            if (!confirmed) return false;

                            // Delete from database
                            final apiService = ref.read(tripApiServiceProvider);
                            final success = await apiService.deleteTrip(tripId);

                            if (success && context.mounted) {
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Trip deleted successfully',
                                    style: GoogleFonts.outfit(),
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              // Refresh the trips list
                              ref.invalidate(userTripsProvider);
                              return true;
                            } else {
                              // Show error message
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to delete trip',
                                      style: GoogleFonts.outfit(),
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                              return false;
                            }
                          },
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              // Navigate with the saved trip data
                              final preferences =
                                  (tripData['preferences'] as List?)
                                      ?.cast<String>() ??
                                  [];

                              // Parse the saved trip data into TripPlan object
                              final savedPlan = TripPlan.fromJson(tripData);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TripResultScreen(
                                    destination: destination,
                                    days: days,
                                    preferences: preferences,
                                    isShared: false,
                                    savedTripData: savedPlan, // Pass saved data
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              constraints: const BoxConstraints(
                                minHeight: 120,
                                maxHeight: 140,
                              ),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Row(
                                  children: [
                                    // Image Section
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        bottomLeft: Radius.circular(20),
                                      ),
                                      child:
                                          imageUrl != null &&
                                              imageUrl.isNotEmpty
                                          ? CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              width: 120,
                                              height: 120,
                                              fit: BoxFit.cover,
                                              placeholder: (context, url) =>
                                                  Container(
                                                    width: 120,
                                                    height: 120,
                                                    color: Colors.grey[300],
                                                    child: const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                        width: 120,
                                                        height: 120,
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons.image,
                                                          size: 40,
                                                        ),
                                                      ),
                                            )
                                          : Container(
                                              width: 120,
                                              height: 120,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.location_city,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                    ),
                                    // Content Section
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '$days-Day $destination Trip',
                                              style: GoogleFonts.outfit(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1A1A2E),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              '$days ${days == 1 ? 'Day' : 'Days'} • ${days - 1} ${days == 1 ? 'Night' : 'Nights'}',
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$totalSpots Spots',
                                              style: GoogleFonts.outfit(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
