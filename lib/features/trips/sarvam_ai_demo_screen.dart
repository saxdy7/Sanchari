import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/sarvam_ai_service.dart';
import '../../services/sarvam_ai_provider.dart';
import '../trips/widgets/ai_insights_card.dart';

/// Example screen demonstrating Sarvam AI integration
/// Shows various AI-powered features for trip planning
class SarvamAIDemoScreen extends ConsumerStatefulWidget {
  const SarvamAIDemoScreen({super.key});

  @override
  ConsumerState<SarvamAIDemoScreen> createState() => _SarvamAIDemoScreenState();
}

class _SarvamAIDemoScreenState extends ConsumerState<SarvamAIDemoScreen> {
  final TextEditingController _promptController = TextEditingController();
  String? _customResponse;
  bool _isLoading = false;

  // Track which examples are expanded
  bool _showTripRecs = false;
  bool _showPlaceInsights = false;
  bool _showLocalGems = false;
  bool _showSeasonalAdvice = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _sendCustomPrompt() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _customResponse = null;
    });

    try {
      final service = ref.read(sarvamAIServiceProvider);
      final response = await service.chat(
        prompt: _promptController.text,
        systemPrompt: 'You are a helpful travel assistant for Indian tourism.',
      );

      setState(() {
        _customResponse = response;
      });
    } catch (e) {
      setState(() {
        _customResponse = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Travel Assistant'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sarvam AI Integration',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'India\'s sovereign AI for travel planning',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Important Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Save Your Free Credits',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You have ₹1000 in free API credits. The examples below make multiple API calls at once, which can quickly use up your credits.',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💡 Tip: Use the "Ask Anything" section below to test with custom questions instead of loading all examples.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Example 4: Custom Prompt (Moved up!)
            _buildSectionTitle('Ask Anything (Recommended)'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test the AI with your own questions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: 'Ask about places, food, travel tips...',
                        hintStyle: TextStyle(fontSize: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isLoading ? Icons.hourglass_empty : Icons.send,
                            color: Colors.blue.shade700,
                          ),
                          onPressed: _isLoading ? null : _sendCustomPrompt,
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 12),
                              Text('Getting AI response...'),
                            ],
                          ),
                        ),
                      ),
                    if (_customResponse != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.psychology,
                                  size: 16,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'AI Response:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _customResponse!,
                              style: TextStyle(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Divider
            Divider(thickness: 2),
            const SizedBox(height: 16),

            // Section Header
            Text(
              'Example Features (Use Carefully)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              'Each example below makes an API call and uses your free credits',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Example 1: Trip Recommendations
            _buildSectionTitle('Trip Recommendations'),
            AIInsightsCard(
              destination: 'Jaipur',
              days: 3,
              interests: ['Heritage', 'Food', 'Shopping'],
            ),
            const SizedBox(height: 24),

            // Example 2: Place Description
            _buildSectionTitle('Place Insights (Disabled to Save Credits)'),
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feature: Get AI-powered place descriptions',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Example: "Tell me about Hawa Mahal in Jaipur"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '💡 Use the "Ask Anything" section above to test this feature',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example 3: Local Insights
            _buildSectionTitle('Local Hidden Gems (Disabled to Save Credits)'),
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feature: Discover hidden gems and local spots',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Example: "What are some hidden gems in Manali?"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '💡 Use the "Ask Anything" section above to test this feature',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Example 5: Seasonal Advice
            _buildSectionTitle(
              'Seasonal Travel Advice (Disabled to Save Credits)',
            ),
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feature: Get weather and seasonal travel advice',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Example: "What\'s the best time to visit Goa? I\'m planning for December"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '💡 Use the "Ask Anything" section above to test this feature',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Usage Guide
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'How to Use',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildUsageItem('1. Import the service in your feature'),
                  _buildUsageItem('2. Use providers for reactive data'),
                  _buildUsageItem('3. Add AI widgets to your screens'),
                  _buildUsageItem('4. Customize prompts for your needs'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildUsageItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}
