import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/sarvam_config.dart';

/// Service for interacting with Sarvam AI API
/// Provides AI-powered trip planning, place descriptions, and recommendations
class SarvamAIService {
  final http.Client _client;

  SarvamAIService({http.Client? client}) : _client = client ?? http.Client();

  /// Generate trip suggestions and place information using Sarvam AI
  ///
  /// Example use cases:
  /// - Get detailed descriptions of tourist spots
  /// - Generate itinerary suggestions
  /// - Get local insights and travel tips
  /// - Answer travel-related questions
  Future<String> chat({
    required String prompt,
    String? systemPrompt,
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async {
    try {
      final messages = <Map<String, String>>[];

      // Add system prompt if provided
      if (systemPrompt != null) {
        messages.add({'role': 'system', 'content': systemPrompt});
      }

      // Add user message
      messages.add({'role': 'user', 'content': prompt});

      final response = await _client
          .post(
            Uri.parse('${SarvamConfig.baseUrl}${SarvamConfig.chatEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
              'api-subscription-key': SarvamConfig.apiKey,
            },
            body: jsonEncode({
              'model': SarvamConfig.defaultModel,
              'messages': messages,
              'temperature': temperature,
              'max_tokens': maxTokens,
            }),
          )
          .timeout(SarvamConfig.timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] as String;
      } else {
        throw SarvamAIException(
          'API request failed with status ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      throw SarvamAIException('Failed to communicate with Sarvam AI: $e');
    }
  }

  /// Get AI-powered description for a place
  Future<String> getPlaceDescription({
    required String placeName,
    required String city,
    String? state,
  }) async {
    final location = state != null
        ? '$placeName, $city, $state'
        : '$placeName, $city';

    final prompt =
        '''
Generate a concise, engaging description for: $location

Include:
- What makes this place special
- Best time to visit
- Key attractions or activities
- Local tips (1-2 sentences)

Keep it under 150 words, informative and travel-focused.
''';

    return await chat(
      prompt: prompt,
      systemPrompt:
          'You are an expert Indian travel guide with deep knowledge of tourist destinations across India.',
      temperature: 0.7,
    );
  }

  /// Generate personalized trip recommendations
  Future<String> getTripRecommendations({
    required String destination,
    required int days,
    required List<String> interests,
  }) async {
    final prompt =
        '''
Create a $days-day trip plan for $destination focusing on: ${interests.join(', ')}.

Provide:
1. Daily itinerary suggestions (brief)
2. Must-visit spots based on interests
3. Local food recommendations
4. Travel tips specific to $destination

Keep it practical and India-focused.
''';

    return await chat(
      prompt: prompt,
      systemPrompt:
          'You are a travel expert specializing in Indian tourism. Provide realistic, budget-friendly recommendations.',
      temperature: 0.8,
    );
  }

  /// Get local insights and hidden gems
  Future<String> getLocalInsights({
    required String city,
    String? specificQuery,
  }) async {
    final prompt = specificQuery != null
        ? 'About $city: $specificQuery'
        : 'What are some hidden gems and local favorites in $city that tourists often miss?';

    return await chat(
      prompt: prompt,
      systemPrompt:
          'You are a local expert sharing authentic insights about Indian cities and tourist destinations.',
      temperature: 0.7,
    );
  }

  /// Enhance trip with AI suggestions based on existing spots
  Future<Map<String, dynamic>> enhanceTripWithAI({
    required List<String> selectedSpots,
    required String destination,
    required int duration,
  }) async {
    final spotsText = selectedSpots.join(', ');

    final prompt =
        '''
Trip Details:
- Destination: $destination
- Duration: $duration days
- Selected spots: $spotsText

Provide:
1. Optimal visit order for these spots
2. Suggested time allocation per spot
3. Additional 2-3 complementary places nearby
4. Best restaurants/cafes near these spots
5. One unique local experience to try

Format as JSON with keys: visitOrder, timeAllocation, additionalPlaces, dining, localExperience
''';

    final response = await chat(
      prompt: prompt,
      systemPrompt:
          'You are a trip planning AI. Provide practical, structured recommendations for Indian destinations.',
      temperature: 0.6,
    );

    // Try to parse as JSON, fallback to text response
    try {
      return jsonDecode(response) as Map<String, dynamic>;
    } catch (e) {
      return {'aiSuggestions': response};
    }
  }

  /// Get weather and seasonal advice
  Future<String> getSeasonalAdvice({
    required String destination,
    required DateTime travelDate,
  }) async {
    final month = _getMonthName(travelDate.month);

    final prompt =
        '''
Travel to $destination in $month:

Provide brief advice on:
- Weather expectations
- What to pack
- Seasonal highlights or festivals
- Any weather-related travel tips

Keep it concise (under 100 words).
''';

    return await chat(
      prompt: prompt,
      systemPrompt:
          'You are a travel advisor with expertise in Indian climate and seasonal tourism.',
      temperature: 0.6,
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  void dispose() {
    _client.close();
  }
}

/// Custom exception for Sarvam AI service errors
class SarvamAIException implements Exception {
  final String message;

  SarvamAIException(this.message);

  @override
  String toString() => 'SarvamAIException: $message';
}
