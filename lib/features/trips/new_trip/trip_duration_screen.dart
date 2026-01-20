import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../trip_result_screen.dart';

class TripDurationScreen extends StatefulWidget {
  final String destination;
  final String? state;
  final List<String> preferences;
  
  const TripDurationScreen({
    super.key,
    required this.destination,
    this.state,
    required this.preferences,
  });

  @override
  State<TripDurationScreen> createState() => _TripDurationScreenState();
}

class _TripDurationScreenState extends State<TripDurationScreen> {
  bool _isFlexible = true;
  int _selectedDays = 2;
  final FixedExtentScrollController _scrollController = FixedExtentScrollController(initialItem: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // Dates / Flexible Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => _isFlexible = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: !_isFlexible ? Colors.grey[200] : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Dates',
                                style: GoogleFonts.outfit(
                                  fontWeight: !_isFlexible ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _isFlexible = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: _isFlexible ? Colors.grey[200] : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Flexible',
                                style: GoogleFonts.outfit(
                                  fontWeight: _isFlexible ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Title
                Text(
                  'How many days?',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Trip to ${widget.destination}',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),

                // Day Picker
                SizedBox(
                  height: 200,
                  child: ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 70,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      setState(() => _selectedDays = index + 1);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        final day = index + 1;
                        final isSelected = day == _selectedDays;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          decoration: isSelected
                              ? BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                )
                              : null,
                          child: Center(
                            child: Text(
                              '$day ${day == 1 ? 'day' : 'days'}',
                              style: GoogleFonts.outfit(
                                fontSize: isSelected ? 36 : 24,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w300,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: 14,
                    ),
                  ),
                ),
                const Spacer(),

                // Generate Trip button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TripResultScreen(
                            destination: widget.destination,
                            days: _selectedDays,
                            preferences: widget.preferences,
                            isShared: false,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Generate Trip',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
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
  }
}
