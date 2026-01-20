import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'Guest User';
    final name = user?.userMetadata?['name'] ?? email.split('@').first;
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    // Get the first letter of the name for the avatar
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF1A1A2E),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1A1A2E),
                      Color(0xFF16213E),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 40,
                              backgroundImage: CachedNetworkImageProvider(avatarUrl),
                              backgroundColor: Colors.white,
                            )
                          : CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: Text(
                                initial,
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1A1A2E),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      email,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Account Settings'),
                  _buildSettingsCard([
                    _buildTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader('App Preferences'),
                  _buildSettingsCard([
                    _buildTile(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      subtitle: 'English',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: Switch.adaptive(
                        value: false,
                        onChanged: (v) {},
                        activeColor: const Color(0xFF1A1A2E),
                      ),
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Support'),
                  _buildSettingsCard([
                    _buildTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help Center',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About Sanchari',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => _logout(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFFEBEE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, color: Colors.red),
                      label: Text(
                        'Log Out',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Version 1.0.0',
                      style: GoogleFonts.outfit(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF1A1A2E), size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1A1A2E),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
            size: 20,
          ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 70, endIndent: 20);
  }

  void _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
