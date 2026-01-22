class SupabaseConfig {
  // Supabase Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ajlomqwmsknzbkkuovxw.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFqbG9tcXdtc2tuemJra3Vvdnh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg3MzAwNjIsImV4cCI6MjA4NDMwNjA2Mn0.CF8Ge8in1jgF2HxlBuija0yexVdCgvYh5qp6NtrPfE0',
  );

  // Check if Supabase is properly configured
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
