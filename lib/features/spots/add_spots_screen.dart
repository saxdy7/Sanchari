import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';

class AddSpotsScreen extends StatelessWidget {
  const AddSpotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock saved spots
    final savedSpots = <Map<String, dynamic>>[];

    return Scaffold(
      body: Stack(
        children: [
          // Full screen map (India centered)
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(22.5937, 78.9629),
              initialZoom: 4.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sanchari.app',
              ),
            ],
          ),

          // Profile Avatar (Top Right)
          Positioned(
            top: 60,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey[600]),
            ),
          ),

          // Bottom Sheet - My Spots
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Spots',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${savedSpots.length} Spots Saved',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Import guides
                        },
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Import Guides'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Empty State or List
                  if (savedSpots.isEmpty) ...[
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Save your favorite spots!',
                              style: GoogleFonts.outfit(fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('🌍', style: TextStyle(fontSize: 64)),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Add first spot
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1A1A2E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: Text(
                                'Add my first spot',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Show list of saved spots
                    ...savedSpots.map((spot) => ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.place, color: Colors.blue),
                      ),
                      title: Text(spot['name'] ?? ''),
                      subtitle: Text(spot['category'] ?? ''),
                    )).toList(),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
