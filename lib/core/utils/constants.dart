import 'package:flutter/material.dart';

class AppConstants {
  // App Name
  static const String appName = 'River Diamond';

  // API Base URLs
  static const String apiBaseUrl = 'https://riverdiamond.com/m_api';
  static const String websiteUrl = 'https://riverdiamond.com';

  // Design Theme Colors
  static const Color backgroundColor = Color(0xFF0C0C0F);
  static const Color primaryColor = Color(0xFF0C0C0F); 
  
  // Surface and Secondary Colors
  static const Color surfaceColor = Color(0xFF141419);
  static const Color surfaceLightColor = Color(0xFF1C1C24);
  
  // Primary brand accent color
  static const Color accentColor = Color(0xFF398860);
  static const Color accentColorDark = Color(0xFF4ADE80); // Vibrant, readable blue in dark theme
  static const Color accentGlowColor = Color(0x33398860);
  static const Color accentSecondary = Color(0xFFFF5C8A);
  
  // Neutral Text Colors
  static const Color textPrimary = Color(0xFFF3F3F7);
  static const Color textSecondary = Color(0xFF8F8FA3);
  static const Color textMuted = Color(0xFF5F5F73);
  
  // Feedback Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);

  // Light Theme Colors
  static const Color lightBackgroundColor = Color(0xFFE2ECE7);
  static const Color lightSurfaceColor = Colors.white;
  static const Color lightSurfaceLightColor = Color(0xFFF1F1F5);
  static const Color lightTextPrimary = Color(0xFF1A1A1E);
  static const Color lightTextSecondary = Color(0xFF4A4A5A);
  static const Color lightTextMuted = Color(0xFF7A7A8A);
  static const Color lightBorderLight = Color(0xFFD3DFDA);

  // Border Colors
  static const Color borderLight = Color(0xFF353545);
  static const Color borderAccent = Color(0xFF398860);
  static const Color borderAccentDark = Color(0xFF4ADE80);

  // Layout Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // Custom Glassmorphism Box Shadow
  static List<BoxShadow> glassShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: const Color(0xFF398860).withOpacity(0.04),
      blurRadius: 40,
      offset: const Offset(0, 4),
    ),
  ];

  // Glowing Text Shadow
  static List<Shadow> textGlow = [
    Shadow(
      color: const Color(0xFF398860).withOpacity(0.6),
      blurRadius: 10,
    ),
  ];

  // Helper to map diamond shapes to image assets
  static String getShapeAsset(String shape) {
    final lower = shape.toLowerCase();
    switch (lower) {
      case 'cushion modifie':
      case 'cushion modified':
        return 'assets/images/cushion-modifie-grey.png';
      case 'cushion brillia':
      case 'cushion brilliant':
        return 'assets/images/cushion-brillia-grey.png';
      case 'lcu':
        return 'assets/images/lcu-grey.png';
      case 'square emerald':
        return 'assets/images/square-emerald-grey.png';
      case 'old miner':
        return 'assets/images/cushion-grey.png';
      case 'asscher':
      case 'cushion':
      case 'emerald':
      case 'heart':
      case 'marquise':
      case 'other':
      case 'oval':
      case 'pear':
      case 'princess':
      case 'radiant':
      case 'round':
        return 'assets/images/$lower-grey.png';
      default:
        return 'assets/images/$lower.png';
    }
  }
}
