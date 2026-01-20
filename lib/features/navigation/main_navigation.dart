import 'package:flutter/material.dart';
import '../home/roamy_home_screen.dart';
import '../saved_spots/saved_spots_screen.dart';
import 'new_trip_modal.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [RoamyHomeScreen(), SavedSpotsScreen()];

  void _showNewTripModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => NewTripModal(
        onAddSpots: () {
          Navigator.pop(context);
          setState(() => _currentIndex = 1);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        heroTag: 'mainNavFAB', // Fix: Add unique hero tag
        onPressed: _showNewTripModal,
        backgroundColor: const Color(0xFF1A1A2E),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Home / Trips
              IconButton(
                icon: Icon(
                  Icons.luggage_outlined,
                  color: _currentIndex == 0
                      ? const Color(0xFF1A1A2E)
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _currentIndex = 0),
              ),
              const SizedBox(width: 48), // Space for FAB
              // Map
              IconButton(
                icon: Icon(
                  Icons.map_outlined,
                  color: _currentIndex == 1
                      ? const Color(0xFF1A1A2E)
                      : Colors.grey,
                ),
                onPressed: () => setState(() => _currentIndex = 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
