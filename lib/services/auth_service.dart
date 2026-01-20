import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

// Auth state provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return supabase.auth.onAuthStateChange;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return supabase.auth.currentUser;
});

// Auth service
class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  // Sign up with email
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );

    // Create user profile in database
    if (response.user != null) {
      await _client.from('users').insert({
        'id': response.user!.id,
        'supabase_id': response.user!.id,
        'email': email,
        'name': name,
      });
    }

    return response;
  }

  // Sign in with email
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.sanchari://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      return response;
    } catch (e) {
      print('❌ Google Sign In Error: $e');
      return false;
    }
  }

  // Create user profile after OAuth sign in (call this after auth state changes)
  Future<void> createUserProfileIfNeeded() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      final existingUser = await _client
          .from('users')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (existingUser == null) {
        // Create user profile in database
        await _client.from('users').insert({
          'id': user.id,
          'supabase_id': user.id,
          'email': user.email,
          'name':
              user.userMetadata?['full_name'] ??
              user.userMetadata?['name'] ??
              user.email?.split('@')[0] ??
              'User',
        });
        print('✅ Created user profile for ${user.email}');
      }
    } catch (e) {
      print('❌ Error creating user profile: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Get current session
  Session? get currentSession => _client.auth.currentSession;

  // Get current user
  User? get currentUser => _client.auth.currentUser;
}

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(supabase);
});
