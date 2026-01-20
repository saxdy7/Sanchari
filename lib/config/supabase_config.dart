class SupabaseConfig {
  // Supabase Configuration - NO HARDCODED KEYS
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // ✅ No secrets in code
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // ✅ No secrets in code
  );

  // Check if Supabase is properly configured
  static bool get isConfigured => 
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
