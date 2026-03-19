import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryDark = Color(0xFF0F172A);
  static const Color primaryOrange = Color(0xFFE65100);
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color secondaryBlue = Color(0xFF3B82F6);

  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgInput = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  static const Color statusGreen = Color(0xFF10B981);
  static const Color statusYellow = Color(0xFFF59E0B);
  static const Color statusRed = Color(0xFFEF4444);
  static const Color statusOrange = Color(0xFFFF5722);

  static const Color glassWhite10 = Color(0x1AFFFFFF);
  static const Color glassWhite20 = Color(0x33FFFFFF);
  static const Color glassWhite50 = Color(0x80FFFFFF);
  static const Color glassWhite70 = Color(0xB3FFFFFF);
  static const Color glassDark10 = Color(0x1A000000);
  static const Color glassDark40 = Color(0x66000000);

  static const Color badgeCutiBg = Color(0xFFFEE2E2);
  static const Color badgeCutiText = Color(0xFFDC2626);

  static const Color badgeSakitBg = Color(0xFFFFEDD5);
  static const Color badgeSakitText = Color(0xFFEA580C);

  static const Color badgeIzinBg = Color(0xFFDBEAFE);
  static const Color badgeIzinText = Color(0xFF2563EB);

  static const Color badgeLemburBg = Color(0xFFF3E8FF);
  static const Color badgeLemburText = Color(0xFF9333EA);

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 14.0;
  static const double spacingLg = 20.0;
  static const double spacingXl = 28.0;
  static const double spacingXxl = 40.0;

  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 9999.0;

  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: primaryDark.withOpacity(0.04),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: primaryDark.withOpacity(0.06),
      blurRadius: 24,
      spreadRadius: -2,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: primaryDark.withOpacity(0.03),
      blurRadius: 8,
      spreadRadius: -1,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: primaryDark.withOpacity(0.08),
      blurRadius: 40,
      spreadRadius: -4,
      offset: const Offset(0, 20),
    ),
  ];

  static List<BoxShadow> glowPrimary = [
    BoxShadow(
      color: primaryDark.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowBlue = [
    BoxShadow(
      color: primaryBlue.withOpacity(0.4),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowGreen = [
    BoxShadow(
      color: statusGreen.withOpacity(0.4),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowRed = [
    BoxShadow(
      color: statusRed.withOpacity(0.4),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowOrange = [
    BoxShadow(
      color: statusOrange.withOpacity(0.4),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
  ];

  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
    color: textPrimary,
  );

  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: textPrimary,
  );

  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: textPrimary,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static TextStyle get labelLarge => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryDark,
      scaffoldBackgroundColor: bgWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryDark,
        secondary: primaryOrange,
        surface: bgWhite,
        error: statusRed,
      ),
      textTheme: TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
      ),
      useMaterial3: true,
    );
  }
}
