import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../services/trip_api_service.dart';
import 'trip_date_screen.dart';

class DestinationSearchScreen extends ConsumerStatefulWidget {
  const DestinationSearchScreen({super.key});

  @override
  ConsumerState<DestinationSearchScreen> createState() =>
      _DestinationSearchScreenState();
}

class _DestinationSearchScreenState
    extends ConsumerState<DestinationSearchScreen> {
  final _searchController = TextEditingController();
  List<LocationResult> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounceTimer;

  // Popular destinations as fallback
  final List<Map<String, String>> _popularDestinations = [
    {'name': 'Jaipur', 'state': 'Rajasthan'},
    {'name': 'Goa', 'state': 'Goa'},
    {'name': 'Manali', 'state': 'Himachal Pradesh'},
    {'name': 'Udaipur', 'state': 'Rajasthan'},
    {'name': 'Kerala', 'state': 'Kerala'},
    {'name': 'Varanasi', 'state': 'Uttar Pradesh'},
    {'name': 'Rishikesh', 'state': 'Uttarakhand'},
    {'name': 'Darjeeling', 'state': 'West Bengal'},
  ];

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    try {
      debugPrint('🔍 Searching for: $query');
      final apiService = ref.read(tripApiServiceProvider);
      final results = await apiService.searchDestinations(query);
      debugPrint('✅ Search results: ${results.length} found');
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Search failed: $e');
      setState(() => _isLoading = false);

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed. Using popular destinations.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _selectDestination(String name, String? state) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripDateScreen(destination: name, state: state),
      ),
    );
  }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Where to?',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Search Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search cities in India...',
                      hintStyle: GoogleFonts.outfit(color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Results or Popular Destinations
              Expanded(
                child: _searchResults.isNotEmpty
                    ? _buildSearchResults()
                    : _buildPopularDestinations(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return ListTile(
          onTap: () => _selectDestination(result.name, result.state),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: Color(0xFF1A1A2E)),
          ),
          title: Text(
            result.name,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            result.state ?? 'India',
            style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 12),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }

  Widget _buildPopularDestinations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Popular Destinations',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _popularDestinations.length,
            itemBuilder: (context, index) {
              final dest = _popularDestinations[index];
              return ListTile(
                onTap: () => _selectDestination(dest['name']!, dest['state']),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('📍', style: TextStyle(fontSize: 20)),
                ),
                title: Text(
                  dest['name']!,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  dest['state']!,
                  style: GoogleFonts.outfit(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              );
            },
          ),
        ),
      ],
    );
  }
}
