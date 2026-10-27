import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/utils/constants.dart';
import '../../data/models/version_model.dart';

class UpdateBanner extends StatelessWidget {
  final VersionModel versionInfo;
  final EdgeInsetsGeometry? margin;

  const UpdateBanner({
    super.key,
    required this.versionInfo,
    this.margin,
  });

  static const String defaultPlayStoreUrl =
      'https://play.google.com/store/apps/details?id=com.riverdiamond.river_diamond&pcampaignid=web_share';
  static const String defaultAppStoreUrl = 'https://riverdiamond.com';

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
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching store link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceSM),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _launchStore,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark 
                  ? Colors.white.withOpacity(0.04) 
                  : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                width: 1.2,
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Left Sync/Refresh Circle Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark 
                        ? AppConstants.surfaceLightColor 
                        : AppConstants.lightSurfaceLightColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sync,
                    color: isDark ? Colors.white70 : AppConstants.lightTextPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMD),

                // Middle Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Update Available',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : AppConstants.lightTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // New Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B087), // Badge green
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'New',
                              style: GoogleFonts.nunito(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Enjoy a more seamless shopping experience',
                        style: GoogleFonts.nunito(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSM),

                // Right Chevron arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppConstants.accentSecondary : const Color(0xFFE54A6B),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
