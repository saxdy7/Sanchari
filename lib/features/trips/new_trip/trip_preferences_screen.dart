import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'discover_spots_screen.dart';

class TripPreferencesScreen extends StatefulWidget {
  final String destination;
  final String? state;
  final int days;
  final DateTime? startDate;

  const TripPreferencesScreen({
    super.key,
    required this.destination,
    this.state,
    required this.days,
    this.startDate,
  });

  @override
  State<TripPreferencesScreen> createState() => _TripPreferencesScreenState();
}

class _TripPreferencesScreenState extends State<TripPreferencesScreen> {
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Popular', 'icon': '📌'},
    {'name': 'Museum', 'icon': '🏛️'},
    {'name': 'Nature', 'icon': '🌲'},
    {'name': 'Foodie', 'icon': '🍕'},
    {'name': 'History', 'icon': '📜'},
    {'name': 'Shopping', 'icon': '🛍️'},
    {'name': 'Adventure', 'icon': '🏔️'},
    {'name': 'Religious', 'icon': '🕉️'},
    {'name': 'Rivers', 'icon': '🌊'},
  ];

  late final Set<String> _selectedPreferences = {
    for (var category in _categories) category['name'] as String,
  };

  void _togglePreference(String name) {
    setState(() {
      if (_selectedPreferences.contains(name)) {
        _selectedPreferences.remove(name);
      } else {
        _selectedPreferences.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip Preferences',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'What should your trip be about?',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Category chips
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 16,
                  children: _categories.map((category) {
                    final isSelected = _selectedPreferences.contains(
                      category['name'],
                    );
                    return GestureDetector(
                      onTap: () => _togglePreference(category['name']),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[200]!,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? Colors.black.withOpacity(0.05)
                                  : Colors.transparent,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category['icon'],
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category['name'],
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Trip Duration Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Trip Duration',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${widget.days} Days',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Continue button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DiscoverSpotsScreen(
                          destination: widget.destination,
                          days: widget.days,
                          preferences: _selectedPreferences.toList(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A2E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
