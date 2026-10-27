import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DialogUtils {
  static void showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
              ? AppConstants.surfaceColor
              : AppConstants.lightSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: BorderSide(
              color: isDark
                  ? AppConstants.borderLight
                  : AppConstants.lightBorderLight,
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.lock_outline_rounded,
                color: isDark ? AppConstants.accentColorDark : AppConstants.accentColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Login Required',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Text(
            'Please sign in or create an account to access this feature, view pricing, and request diamonds.',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDark
                    ? AppConstants.textSecondary
                    : AppConstants.lightTextSecondary,
              ),
              child: Text(
                'CANCEL',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_id');
                await prefs.remove('user_name');
                await prefs.remove('user_email');
                if (ctx.mounted) {
                  ctx.read<AuthBloc>().add(const AuthLogoutRequested());
                  Navigator.of(ctx).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppConstants.accentColorDark
                    : AppConstants.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'SIGN IN',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showLogoutConfirmDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark
              ? AppConstants.surfaceColor
              : AppConstants.lightSurfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
            side: BorderSide(
              color: isDark
                  ? AppConstants.borderLight
                  : AppConstants.lightBorderLight,
            ),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.power_settings_new_rounded,
                color: AppConstants.errorColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Confirm Logout',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to log out from River Diamond?',
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDark
                    ? AppConstants.textSecondary
                    : AppConstants.lightTextSecondary,
              ),
              child: Text(
                'CANCEL',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                'LOG OUT',
                style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  static void showEnlargedImage(BuildContext context, String imageUrl, String shape) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.transparent,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.surfaceColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : Colors.black87),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const SizedBox(
                            height: 300,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Image.asset(
                            AppConstants.getShapeAsset(shape),
                            height: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
