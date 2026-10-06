import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Canvas & Background Surfaces
  static const Color background = Color(0xFFFAF7F2);        // Warm Alabaster canvas
  static const Color surface = Color(0xFFFFFFFF);           // Card & sheet white
  static const Color surfaceVariant = Color(0xFFF5F2EC);    // Subtle muted surface
  static const Color card = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE7E5E4);            // Stone 200 border
  static const Color divider = Color(0xFFE7E5E4);

  // Backward-compatibility aliases for existing dark-themed screens
  static const Color darkBackground = Color(0xFFFAF7F2);    // Routed to warm canvas
  static const Color splashBackground = Color(0xFFFAF7F2);
  static const Color darkSurface = Color(0xFFFFFFFF);       // Routed to white card
  static const Color darkCard = Color(0xFFFFFFFF);
  static const Color darkBorder = Color(0xFFE7E5E4);
  static const Color borderDark = Color(0xFFE7E5E4);
  static const Color borderFocused = Color(0xFFDC2626);

  // Primary Crimson Brand Palette
  static const Color primary = Color(0xFFDC2626);           // Red 600
  static const Color primaryDark = Color(0xFFB91C1C);       // Red 700
  static const Color primaryLight = Color(0xFFFEE2E2);      // Red 100 container
  static const Color primaryGradientStart = Color(0xFFDC2626);
  static const Color primaryGradientEnd = Color(0xFFB91C1C);

  // Backward-compatibility aliases for gold accents
  static const Color goldFont = Color(0xFFDC2626);
  static const Color goldGradientStart = Color(0xFFDC2626);
  static const Color goldGradientEnd = Color(0xFFB91C1C);
  static const Color cardGoldAccent = Color(0xFFDC2626);
  static const Color creamText = Color(0xFF1C1917);         // Routed to Stone 900
  static const Color accentYellow = Color(0xFFF59E0B);

  // Primary Linear Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography Palette (Stone Spectrum)
  static const Color textPrimary = Color(0xFF1C1917);       // Stone 900
  static const Color textSecondary = Color(0xFF44403C);     // Stone 700
  static const Color textMuted = Color(0xFF78716C);         // Stone 500
  static const Color textHint = Color(0xFFA8A29E);          // Stone 400
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGold = Color(0xFFDC2626);
  static const Color textPrimaryDark = Color(0xFF1C1917);
  static const Color textSecondaryDark = Color(0xFF78716C);
  static const Color textMutedDark = Color(0xFFA8A29E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Operational Status Indicators
  static const Color success = Color(0xFF15803D);           // Green 700
  static const Color successLight = Color(0xFFDCFCE7);      // Green 100
  static const Color warning = Color(0xFFD97706);           // Amber 600
  static const Color warningLight = Color(0xFFFEF3C7);      // Amber 100
  static const Color error = Color(0xFFDC2626);             // Red 600
  static const Color errorLight = Color(0xFFFFE4E8);        // Rose 100
  static const Color info = Color(0xFF2563EB);              // Blue 600
  static const Color infoLight = Color(0xFFDBEAFE);         // Blue 100

  // Dietary Indicators
  static const Color veg = Color(0xFF16A34A);
  static const Color vegLight = Color(0xFFDCFCE7);
  static const Color nonVeg = Color(0xFFDC2626);
  static const Color nonVegLight = Color(0xFFFFE4E8);

  // Order Status Colors
  static const Color orderNew = Color(0xFF2563EB);
  static const Color orderNewLight = Color(0xFFDBEAFE);
  static const Color orderActive = Color(0xFFD97706);
  static const Color orderActiveLight = Color(0xFFFEF3C7);
  static const Color orderReady = Color(0xFF15803D);
  static const Color orderReadyLight = Color(0xFFDCFCE7);
  static const Color orderDelivered = Color(0xFF15803D);
  static const Color orderDeliveredLight = Color(0xFFDCFCE7);
  static const Color orderCancelled = Color(0xFFDC2626);
  static const Color orderCancelledLight = Color(0xFFFFE4E8);

  // Utilities & Shadows
  static const Color shadow = Color(0x0A000000);
  static const Color overlay = Color(0x66000000);

  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.04),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get navBarShadow => [
        const BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.05),
          blurRadius: 20,
          offset: Offset(0, -4),
        ),
      ];

  // Modern background & badge aliases
  static const Color scaffoldBackground = background;
  static const Color surfaceAlt = surfaceVariant;
  static const Color headingPrimary = textPrimary;
  static const Color successBg = successLight;
  static const Color warningBg = warningLight;
  static const Color errorBg = errorLight;
  static const Color infoBg = infoLight;
}
