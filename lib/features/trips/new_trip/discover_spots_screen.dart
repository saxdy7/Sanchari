import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../services/trip_api_service.dart';
import '../trip_result_screen.dart';

class DiscoverSpotsScreen extends ConsumerStatefulWidget {
  final String destination;
  final int days;
  final List<String> preferences;

  const DiscoverSpotsScreen({
    super.key,
    required this.destination,
    required this.days,
    required this.preferences,
  });

  @override
  ConsumerState<DiscoverSpotsScreen> createState() =>
      _DiscoverSpotsScreenState();
}

class _DiscoverSpotsScreenState extends ConsumerState<DiscoverSpotsScreen> {
  String _selectedCategory = 'All';
  Map<String, bool> _selectedSpots = {};
  List<TripPlace> _allSpots = [];
  bool _isLoading = true;

  // Map preferences to spot categories
  final Map<String, List<String>> _preferenceToCategories = {
    'Popular': ['Popular'],
    'Museum': ['Museum'],
    'Nature': ['Nature'],
    'Foodie': ['Foodie'],
    'History': ['History'],
    'Shopping': ['Shopping'],
    'Adventure': ['Adventure'],
    'Religious': ['Religious'],
    'Rivers': ['Rivers', 'Water'],
  };

  List<String> get _categories {
    // Always start with 'All'
    List<String> categories = ['All'];

    // Add categories based on selected preferences
    for (var preference in widget.preferences) {
      if (_preferenceToCategories.containsKey(preference)) {
        categories.addAll(_preferenceToCategories[preference]!);
      }
    }

    // Remove duplicates and return
    return categories.toSet().toList();
  }

  @override
  void initState() {
    super.initState();
    _fetchSpots();
  }

  Future<void> _fetchSpots() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ref.read(tripApiServiceProvider);
      final plan = await apiService.generateTrip(
        destination: widget.destination,
        days: widget.days,
        preferences: widget.preferences,
      );

      if (plan != null) {
        final spots = plan.itinerary.expand((day) => day.places).toList();
        setState(() {
          _allSpots = spots;
          // Initially select all spots
          for (var spot in spots) {
            _selectedSpots[spot.placeName] = true;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching spots: $e');
      setState(() => _isLoading = false);
    }
  }

  List<TripPlace> get _filteredSpots {
    if (_selectedCategory == 'All') return _allSpots;

    // Filter spots by category, checking if the spot's category contains the selected category
    return _allSpots
        .where(
          (spot) =>
              spot.category.toLowerCase().contains(
                _selectedCategory.toLowerCase(),
              ) ||
              _selectedCategory.toLowerCase().contains(
                spot.category.toLowerCase(),
              ),
        )
        .toList();
  }

  int _getCountForCategory(String category) {
    if (category == 'All') return _allSpots.length;

    return _allSpots
        .where(
          (spot) =>
              spot.category.toLowerCase().contains(category.toLowerCase()) ||
              category.toLowerCase().contains(spot.category.toLowerCase()),
        )
        .length;
  }

  int get _selectedCount => _selectedSpots.values.where((v) => v).length;

  void _showPlanConfirmation() {
    final selectedSpotsList = _allSpots
        .where((spot) => _selectedSpots[spot.placeName] == true)
        .toList();

    if (selectedSpotsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one spot')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PlanConfirmationDialog(
        destination: widget.destination,
        days: widget.days,
        selectedSpots: selectedSpotsList,
        preferences: widget.preferences,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover spots',
                          style: GoogleFonts.outfit(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.destination} • ${widget.days} days',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  final count = _getCountForCategory(category);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('$category ($count)'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                      labelStyle: GoogleFonts.outfit(
                        color: isSelected ? Colors.black : Colors.grey[600],
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      backgroundColor: Colors.grey[100],
                      selectedColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? Colors.black : Colors.grey[300]!,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Destination header with expand icon
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    widget.destination,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Spots list
            Expanded(
              child: _isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 8, // Show 8 skeleton items
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Number skeleton
                                Container(
                                  width: 30,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Image skeleton
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Content skeleton
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 16,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 14,
                                        width: 150,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 12,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Checkbox skeleton
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredSpots.length,
                      itemBuilder: (context, index) {
                        final spot = _filteredSpots[index];
                        final isSelected =
                            _selectedSpots[spot.placeName] ?? false;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Number
                              SizedBox(
                                width: 30,
                                child: Text(
                                  '${index + 1}.',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),

                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: spot.imageUrl != null
                                      ? CachedNetworkImage(
                                          imageUrl: spot.imageUrl!,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons.image,
                                                color: Colors.grey,
                                              ),
                                        )
                                      : const Icon(
                                          Icons.place,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.place,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            spot.placeName,
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      spot.description,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.category_outlined,
                                          size: 14,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          spot.category,
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Checkbox
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSpots[spot.placeName] =
                                        value ?? false;
                                  });
                                },
                                activeColor: Colors.black,
                                shape: const CircleBorder(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Bottom button
            Container(
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
                child: ElevatedButton(
                  onPressed: _showPlanConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Add $_selectedCount spots',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
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

class _PlanConfirmationDialog extends ConsumerWidget {
  final String destination;
  final int days;
  final List<TripPlace> selectedSpots;
  final List<String> preferences;

  const _PlanConfirmationDialog({
    required this.destination,
    required this.days,
    required this.selectedSpots,
    required this.preferences,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day1Spots = selectedSpots.take(3).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Want us to help plan your trip?',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Small map preview (placeholder)
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.map_outlined, size: 48, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Planning your perfect trip...',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day 1',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ...day1Spots.asMap().entries.map((entry) {
                    final index = entry.key;
                    final spot = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}.',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[200],
                              child: spot.imageUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: spot.imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.place),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  spot.placeName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.category,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      spot.category,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Clear the entire trip creation stack and navigate to result
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => TripResultScreen(
                          destination: destination,
                          days: days,
                          preferences: preferences,
                          isShared: false,
                        ),
                      ),
                      (route) => route.isFirst, // Keep only MainNavigation
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Yes, plan for me!',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "No, I'll plan myself",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
