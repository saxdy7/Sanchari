import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const ProviderScope(child: SanchariApp()));
}

// Global Supabase client accessor
final supabase = Supabase.instance.client;

// Cached theme for better performance
final _appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF2C3E50),
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.outfitTextTheme(),
  scaffoldBackgroundColor: const Color(0xFFF8F9FA),
);

class SanchariApp extends StatelessWidget {
  const SanchariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sanchari',
      debugShowCheckedModeBanner: false,
      theme: _appTheme,
      home: const SplashScreen(),
    );
  }
}
