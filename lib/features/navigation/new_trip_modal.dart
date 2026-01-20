import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../trips/new_trip/destination_search_screen.dart';
import 'find_trip_screen.dart';

class NewTripModal extends StatelessWidget {
  final VoidCallback? onAddSpots;
  
  const NewTripModal({super.key, this.onAddSpots});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // New Trip Button (Dark)
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DestinationSearchScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'New trip',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Text('✈️🗺️🧳', style: TextStyle(fontSize: 28)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Find Trip Button (Light Blue) - Enter 4-digit code
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FindTripScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    'Find trip',
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Text('🔍🗺️', style: TextStyle(fontSize: 28)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Add Spots Button (White)
          GestureDetector(
            onTap: onAddSpots,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Text(
                    'Add spots',
                    style: GoogleFonts.outfit(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Text('📍', style: TextStyle(fontSize: 28)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Close Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(Icons.close, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
