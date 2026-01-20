/// Configuration for Sarvam AI API - NO HARDCODED KEYS
class SarvamConfig {
  // API Key from environment variable ONLY
  static const String apiKey = String.fromEnvironment(
    'SARVAM_API_KEY',
    defaultValue: '', // ✅ No secrets in code
  );

  // Base URL for Sarvam AI API
  static const String baseUrl = 'https://api.sarvam.ai';

  // Chat endpoint
  static const String chatEndpoint = '/v1/chat/completions';

  // Model to use (sarvam-m, gemma-4b, or gemma-12b)
  static const String defaultModel = 'sarvam-m';

  // Check if API is properly configured
  static bool get isConfigured => apiKey.isNotEmpty;

  // API timeout
  static const Duration timeout = Duration(seconds: 30);
}
