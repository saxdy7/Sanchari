import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'saved_spots_screen.dart';
import '../../services/database_service.dart';

class SpotDetailScreen extends ConsumerWidget {
  final SavedSpot spot;

  const SpotDetailScreen({super.key, required this.spot});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      spot.name,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 4),
                          Text(
                            spot.category,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Main image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey[200],
                        child: CachedNetworkImage(
                          imageUrl: spot.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Center(child: Icon(Icons.place, size: 64)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // About section
                    Text(
                      'About this place',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      spot.description,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Community Notes
                    if (spot.communityNotes.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber[100]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  size: 20,
                                  color: Colors.amber[700],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Community Notes',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber[900],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...spot.communityNotes.map(
                              (note) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '• ',
                                      style: GoogleFonts.outfit(
                                        fontSize: 15,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        note,
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
                                          color: Colors.grey[800],
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Show sources
                    InkWell(
                      onTap: () {
                        // Show sources
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            Text(
                              'Show sources',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: Colors.grey[600]),
                          ],
                        ),
                      ),
                    ),

                    const Divider(),

                    // Location
                    InkWell(
                      onTap: () {
                        final address =
                            '${spot.city}, ${spot.state}, ${spot.country}';
                        Clipboard.setData(ClipboardData(text: address));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Address copied to clipboard'),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.navigation,
                              size: 20,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${spot.city}, ${spot.state}, ${spot.country}',
                                style: GoogleFonts.outfit(fontSize: 15),
                              ),
                            ),
                            const Icon(
                              Icons.copy,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Website
                    if (spot.website != null) ...[
                      const Divider(),
                      InkWell(
                        onTap: () {
                          // Open website
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.language,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  spot.website!,
                                  style: GoogleFonts.outfit(fontSize: 15),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirmed =
                        await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Delete Spot',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Are you sure you want to remove ${spot.name} from your saved spots?',
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

                    if (confirmed && context.mounted) {
                      // Delete from database
                      final dbService = ref.read(databaseServiceProvider);
                      final success = await dbService.deleteSavedSpot(
                        spot.savedSpotId,
                      );

                      if (success && context.mounted) {
                        // Refresh the spots list
                        ref.invalidate(savedSpotsProvider);

                        // Go back
                        Navigator.of(context).pop();

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Spot removed from saved',
                              style: GoogleFonts.outfit(),
                            ),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      } else if (context.mounted) {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to remove spot',
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
                    }
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: Text(
                    'Delete',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Get directions
                  },
                  icon: const Icon(Icons.navigation),
                  label: Text(
                    'Direction',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
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
      ),
    );
  }
}
