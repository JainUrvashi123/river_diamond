import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/constants.dart';
import '../../data/models/version_model.dart';

class UpdateDialog extends StatelessWidget {
  final VersionModel versionInfo;

  const UpdateDialog({
    super.key,
    required this.versionInfo,
  });

  static const String defaultPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.riverdiamond.river_diamond&pcampaignid=web_share';
  static const String defaultAppStoreUrl =
      'https://riverdiamond.com'; // Fallback until App Store link is provided

  Future<void> _launchStore() async {
    final isAndroid = Platform.isAndroid;
    String? urlString;

    if (isAndroid) {
      urlString = versionInfo.playStoreUrl ?? defaultPlayStoreUrl;
    } else {
      urlString = versionInfo.appStoreUrl ?? defaultAppStoreUrl;
    }

    if (urlString.isEmpty) {
      urlString = isAndroid ? defaultPlayStoreUrl : defaultAppStoreUrl;
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback launch attempt
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching store link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final forceUpdate = versionInfo.forceUpdate;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;


    final dialogContent = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceLG,
        vertical: AppConstants.spaceXL,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(28.0),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Elegant download icon in circular container
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.system_update_alt_rounded,
              color: accentColor,
              size: 32,
            ),
          ),
          const SizedBox(height: AppConstants.spaceLG),

          // Title
          Text(
            'Update Available!',
            style: GoogleFonts.nunito(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppConstants.lightTextPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceSM),

          // Description
          Text(
            'A new version of ${AppConstants.appName} is available! Please update to get the latest features and improvements.',
            style: GoogleFonts.nunito(
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spaceLG * 1.2),

          // "Update Now" Action Button
          ElevatedButton(
            onPressed: _launchStore,
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Update Now',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // "Later" Secondary Action Button (hidden on force update)
          if (!forceUpdate) ...[
            const SizedBox(height: AppConstants.spaceSM),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppConstants.textMuted : Colors.grey[500],
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Later',
                style: GoogleFonts.nunito(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return PopScope(
      canPop: !forceUpdate,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: dialogContent,
      ),
    );
  }
}
