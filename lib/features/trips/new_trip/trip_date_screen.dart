import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'trip_preferences_screen.dart';

class TripDateScreen extends StatefulWidget {
  final String destination;
  final String? state;

  const TripDateScreen({super.key, required this.destination, this.state});

  @override
  State<TripDateScreen> createState() => _TripDateScreenState();
}

class _TripDateScreenState extends State<TripDateScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFlexible = false;
  int _flexibleDays = 2; // Default to 2 days

  int get _duration {
    if (_isFlexible) return _flexibleDays;
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  // Generate list of next 12 months for calendar
  final List<DateTime> _months = List.generate(
    13,
    (index) => DateTime(DateTime.now().year, DateTime.now().month + index, 1),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [
              Color(0xFFE0F7FA), // Light Cyan
              Colors.white,
            ],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Toggle
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        height: 44,
                        constraints: const BoxConstraints(minWidth: 180),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Animated sliding indicator
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              left: _isFlexible ? 90 : 4,
                              top: 4,
                              bottom: 4,
                              child: Container(
                                width: 86,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Toggle buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildToggleBtn('Dates', !_isFlexible),
                                _buildToggleBtn('Flexible', _isFlexible),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Text(
                  _isFlexible ? 'How many days?' : 'Select Dates',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Content Area
              Expanded(
                child: _isFlexible
                    ? _buildFlexibleView()
                    : _buildCalendarView(),
              ),

              // Bottom Button
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFF5F5F5))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        (_isFlexible ||
                            (_startDate != null && _endDate != null))
                        ? _onConfirm
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Confirm',
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
      ),
    );
  }

  void _onConfirm() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripPreferencesScreen(
          destination: widget.destination,
          state: widget.state,
          days: _duration,
          startDate: _startDate ?? DateTime.now(), // Fallback for flexible
        ),
      ),
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFlexible = text == 'Flexible';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 90,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            style: GoogleFonts.outfit(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  // --- Flexible View (Wheel) ---
  Widget _buildFlexibleView() {
    return Center(
      child: SizedBox(
        height: 300,
        child: ListWheelScrollView.useDelegate(
          itemExtent: 60,
          perspective: 0.005,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            setState(() {
              _flexibleDays = index + 1;
            });
          },
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: 7, // Limit to 7 days as requested
            builder: (context, index) {
              final number = index + 1;
              final isSelected = number == _flexibleDays;
              return Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: GoogleFonts.outfit(
                    fontSize: isSelected ? 48 : 32,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey[300],
                  ),
                  child: Container(
                    padding: isSelected
                        ? const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 4,
                          )
                        : null,
                    decoration: isSelected
                        ? BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          )
                        : null,
                    child: Text('$number'),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Calendar View (Continuous Vertical) ---
  Widget _buildCalendarView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _months.length,
      itemBuilder: (context, index) {
        return _buildMonthSection(_months[index]);
      },
    );
  }

  Widget _buildMonthSection(DateTime month) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(
      month.year,
      month.month,
      1,
    ).weekday; // 1=Mon, 7=Sun
    const weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            DateFormat('MMMM yyyy').format(month),
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Weekday Headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekDays
              .map(
                (d) => SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      d,
                      style: GoogleFonts.outfit(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 16),

        // Days Grid
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount:
                  daysInMonth +
                  (firstWeekday % 7), // Adjust for Sun start if needed
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 12,
                crossAxisSpacing: 4,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                // Adjust offset for weekday alignment (Sunday start logic)
                // 1=Mon...7=Sun. If we want Sun as first column (index 0)
                // Standard DateTime weekday: Mon=1...Sun=7
                // Logic: Pad empty slots before 1st day.
                // If Mon(1), empty=1. If Sun(7), empty=0.
                // Let's assume standard Sun-Sat grid.
                var pad = firstWeekday == 7 ? 0 : firstWeekday;

                if (index < pad) return const SizedBox();

                final day = index - pad + 1;
                final date = DateTime(month.year, month.month, day);
                final isPast = date.isBefore(
                  DateTime.now().subtract(const Duration(days: 1)),
                );

                bool isSelected = false;
                bool inRange = false;

                if (_startDate != null) {
                  if (isSameDay(date, _startDate!)) isSelected = true;
                  if (_endDate != null) {
                    if (isSameDay(date, _endDate!)) isSelected = true;
                    if (date.isAfter(_startDate!) && date.isBefore(_endDate!))
                      inRange = true;
                  }
                }

                return GestureDetector(
                  onTap: isPast ? null : () => _onDateTap(date),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.black
                          : (inRange ? Colors.grey[200] : Colors.transparent),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: GoogleFonts.outfit(
                          color: isSelected
                              ? Colors.white
                              : (isPast ? Colors.grey[300] : Colors.black),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
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
    );
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else {
        if (date.isBefore(_startDate!)) {
          _startDate = date;
          _endDate = null;
        } else {
          _endDate = date;
        }
      }
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
