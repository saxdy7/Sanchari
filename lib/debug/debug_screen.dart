import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _status = 'Click Test Backend to check connection';
  bool _isTesting = false;

  Future<void> _testBackend() async {
    setState(() {
      _isTesting = true;
      _status = '⏳ Testing backend connection...';
    });

    try {
      // Test 1: Basic connection
      final dio = Dio();
      final response = await dio.get('http://localhost:3000');
      
      setState(() {
        _status = '✅ SUCCESS!\n\nBackend is reachable\nResponse: ${response.data}';
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ ERROR\n\n$e\n\nBackend needs to be running at http://localhost:3000';
        _isTesting = false;
      });
    }
  }

  Future<void> _testTripAPI() async {
    setState(() {
      _isTesting = true;
      _status = '⏳ Testing trip generation for Jaipur...';
    });

    try {
      final dio = Dio();
      final response = await dio.get(
        'http://localhost:3000/trip/plan',
        queryParameters: {
          'destination': 'Jaipur',
          'days': '2',
          'preferences': '',
        },
      );
      
      final data = response.data;
      setState(() {
        _status = '✅ TRIP GENERATED!\n\n'
            'Destination: ${data['destination']}\n'
            'Days: ${data['days']}\n'
            'Places Day 1: ${data['itinerary'][0]['places'].length}\n'
            'Places Day 2: ${data['itinerary'][1]['places'].length}\n\n'
            'First place: ${data['itinerary'][0]['places'][0]['placeName']}';
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _status = '❌ ERROR\n\n$e';
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backend Connection Test', style: GoogleFonts.outfit()),
        backgroundColor: const Color(0xFF80DEEA),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Diagnostic Tool',
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testBackend,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                'Test Backend Connection',
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testTripAPI,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                'Test Trip Generation (Jaipur)',
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _status,
                  style: GoogleFonts.outfit(fontSize: 14),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Text(
              'Expected Backend URL:\nhttp://localhost:3000',
              style: GoogleFonts.outfit(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
