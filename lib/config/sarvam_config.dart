/// Configuration for Sarvam AI API
class SarvamConfig {
  // API Key for authentication
  static const String apiKey = 'sk_d7lugoxa_ymP6eDIIsI2i8dSmPKCdii95';

  // Base URL for Sarvam AI API
  static const String baseUrl = 'https://api.sarvam.ai';

  // Chat endpoint
  static const String chatEndpoint = '/v1/chat/completions';

  // Model to use (sarvam-m, gemma-4b, or gemma-12b)
  static const String defaultModel = 'sarvam-m';

  // API timeout
  static const Duration timeout = Duration(seconds: 30);
}
