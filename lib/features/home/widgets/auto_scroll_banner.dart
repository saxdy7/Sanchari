import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class AutoScrollBanner extends StatefulWidget {
  const AutoScrollBanner({super.key});

  @override
  State<AutoScrollBanner> createState() => _AutoScrollBannerState();
}

class _AutoScrollBannerState extends State<AutoScrollBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<BannerData> _banners = [
    BannerData(
      title: 'Plan Your Dream Trip',
      subtitle: 'AI-powered itineraries tailored just for you',
      imageUrl: 'assets/Tourists by car.json',
      gradient: const [Color(0xFFE0E0E0), Color(0xFFFFFFFF)],
      isLottie: true,
    ),
    BannerData(
      title: 'Discover Hidden Gems',
      subtitle: 'Explore amazing places around the world',
      imageUrl: 'assets/loading.json',
      gradient: const [Color(0xFFE0E0E0), Color(0xFFFFFFFF)],
      isLottie: true,
    ),
    BannerData(
      title: 'Save Your Favorites',
      subtitle: 'Create your personal travel wishlist',
      imageUrl: 'assets/Man Holding A Map.json',
      gradient: const [Color(0xFFE0E0E0), Color(0xFFFFFFFF)],
      isLottie: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: _banners.length,
        itemBuilder: (context, index) {
          final banner = _banners[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _BannerCard(banner: banner),
          );
        },
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final BannerData banner;

  const _BannerCard({required this.banner});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: banner.gradient,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Content
            Row(
              children: [
                // Text Content
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          banner.title,
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          banner.subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                // Illustration
                SizedBox(
                  width: 180,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: banner.isLottie
                        ? Lottie.asset(
                            banner.imageUrl,
                            fit: BoxFit.contain,
                            animate: true,
                            repeat: true,
                          )
                        : Icon(
                            Icons.image,
                            color: Colors.grey.withOpacity(0.5),
                            size: 50,
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const spacing = 30.0;

    // Draw diagonal lines pattern
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BannerData {
  final String title;
  final String subtitle;
  final String imageUrl;
  final List<Color> gradient;
  final bool isLottie;

  BannerData({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.gradient,
    this.isLottie = false,
  });
}
