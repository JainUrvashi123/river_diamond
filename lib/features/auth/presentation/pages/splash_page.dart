import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/constants.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();


    Future.delayed(const Duration(milliseconds: 2800), () async {
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? '';
      final userName = prefs.getString('user_name') ?? '';
      final userEmail = prefs.getString('user_email') ?? '';

      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

      if (!mounted) return;

      final Widget nextPage;
      if (!hasSeenOnboarding) {
        nextPage = const OnboardingPage();
      } else {
        final targetUserId = userId.isNotEmpty ? userId : 'guest';
        final targetUserName = userId.isNotEmpty ? userName : 'Guest User';
        final targetUserEmail = userId.isNotEmpty ? userEmail : 'guest@river_diamond.com';

        if (userId.isEmpty) {
          await prefs.setString('user_id', 'guest');
          await prefs.setString('user_name', 'Guest User');
          await prefs.setString('user_email', 'guest@river_diamond.com');
        }

        nextPage = DashboardPage(
          userId: targetUserId,
          userName: targetUserName,
          userEmail: targetUserEmail,
        );
      }

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => nextPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Glow Background Blobs (matching design system blobs)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? accentColor.withOpacity(0.08) : accentColor.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark 
                    ? AppConstants.accentSecondary.withOpacity(0.05) 
                    : AppConstants.accentSecondary.withOpacity(0.03),
              ),
            ),
          ),

          // Central Logo and Branding Elements
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo Box (extra large and clear matching the login screen)
                    SizedBox(
                      height: 80, // Tight layout height to pull text closer, matching login page
                      width: 320,
                      child: OverflowBox(
                        minHeight: 180,
                        maxHeight: 180, // Draws the logo extra large
                        minWidth: 320,
                        maxWidth: 320,
                        child: Image.asset(
                          'assets/images/river_diamond-logo.png',
                          fit: BoxFit.contain,
                          color: isDark ? Colors.white : null,
                          colorBlendMode: isDark ? BlendMode.srcIn : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXL),
                    
                    // Brand Title
                    Text(
                      'River Diamond Jewels',
                      style: GoogleFonts.nunito(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceXS),
                    
                    // Brand Subtitle
                    Text(
                      'EXQUISITE NATURAL DIAMONDS',
                      style: GoogleFonts.nunito(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: AppConstants.spaceXL * 2),

                    // Elegant circular loading indicator matching brand primary color
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Copyright Label Footer
          Positioned(
            bottom: AppConstants.spaceXL,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '© 2026 River Diamond Jewels Inc. All Rights Reserved.',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
