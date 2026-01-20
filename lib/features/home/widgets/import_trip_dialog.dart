import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../trips/trip_result_screen.dart';
import '../../../services/trip_api_service.dart';

class ImportTripDialog extends ConsumerStatefulWidget {
  const ImportTripDialog({super.key});

  @override
  ConsumerState<ImportTripDialog> createState() => _ImportTripDialogState();
}

class _ImportTripDialogState extends ConsumerState<ImportTripDialog> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _importTrip() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      setState(() => _error = 'Please enter a code');
      return;
    }

    if (code.length != 6) {
      setState(() => _error = 'Code must be 6 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(tripApiServiceProvider);
      final trip = await apiService.getTripByShareCode(code);

      if (!mounted) return;

      if (trip == null) {
        setState(() {
          _isLoading = false;
          _error = 'Trip not found. Please check the code and try again.';
        });
        return;
      }

      // Success! Navigate to trip
      Navigator.of(context).pop(); // Close dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TripResultScreen(
            destination: trip.destination,
            days: trip.days,
            preferences: const [],
            isShared: true,
            savedTripData: trip,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Error loading trip. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flight_takeoff,
              size: 48,
              color: Color(0xFF1A1A2E),
            ),
            const SizedBox(height: 16),
            Text(
              'Import Trip',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter the 6-character code shared by your friend',
              style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 8,
              ),
              decoration: InputDecoration(
                hintText: 'ABC123',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF1A1A2E),
                    width: 2,
                  ),
                ),
                errorText: _error,
                errorStyle: GoogleFonts.outfit(fontSize: 12),
              ),
              onChanged: (_) {
                if (_error != null) {
                  setState(() => _error = null);
                }
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _importTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Text(
                        'Import Trip',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
