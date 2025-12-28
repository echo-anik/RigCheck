import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Web-inspired theme matching rigcheck-web design system
/// Based on oklch color space converted to RGB for Flutter compatibility
class WebInspiredTheme {
  // Primary Colors (converted from oklch(0.205 0 0) - very dark gray/black)
  static const Color primaryColor = Color(0xFF1E1E1E); // Nearly black
  static const Color primaryForeground = Color(0xFFFAFAFA); // Almost white
  
  // Secondary Colors (converted from oklch(0.97 0 0) - very light gray)
  static const Color secondaryColor = Color(0xFFF7F7F7);
  static const Color secondaryForeground = Color(0xFF1E1E1E);
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFFFFFFF); // Pure white
  static const Color foregroundColor = Color(0xFF1E1E1E); // Dark text
  
  // Card Colors
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF1E1E1E);
  
  // Muted Colors (converted from oklch(0.97 0 0) and oklch(0.556 0 0))
  static const Color mutedColor = Color(0xFFF7F7F7);
  static const Color mutedForeground = Color(0xFF737373); // Mid gray
  
  // Accent Colors (same as secondary)
  static const Color accentColor = Color(0xFFF7F7F7);
  static const Color accentForeground = Color(0xFF1E1E1E);
  
  // Border & Input Colors (converted from oklch(0.922 0 0))
  static const Color borderColor = Color(0xFFE5E5E5);
  static const Color inputColor = Color(0xFFE5E5E5);
  
  // Ring/Focus Color (converted from oklch(0.708 0 0))
  static const Color ringColor = Color(0xFFA3A3A3);
  
  // Destructive/Error Color (converted from oklch(0.577 0.245 27.325))
  static const Color destructiveColor = Color(0xFFEF4444);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  
  // Chart Colors (converted from oklch values)
  static const Color chart1 = Color(0xFFEAB308); // Yellow
  static const Color chart2 = Color(0xFF3B82F6); // Blue
  static const Color chart3 = Color(0xFF1E40AF); // Dark blue
  static const Color chart4 = Color(0xFF84CC16); // Lime
  static const Color chart5 = Color(0xFFF59E0B); // Amber
  
  // Success & Info Colors
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color infoColor = Color(0xFF3B82F6); // Blue
  
  // Border Radius (matching web's var(--radius))
  static const double radiusBase = 10.0; // 0.625rem * 16 = 10px
  static const double radiusSm = 6.0;    // radius - 4px
  static const double radiusMd = 8.0;    // radius - 2px
  static const double radiusLg = 10.0;   // radius
  static const double radiusXl = 14.0;   // radius + 4px
  static const double radius2xl = 18.0;  // radius + 8px
  static const double radius3xl = 22.0;  // radius + 12px
  static const double radius4xl = 26.0;  // radius + 16px
  
  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFF7F7F7), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      onPrimary: primaryForeground,
      secondary: secondaryColor,
      onSecondary: secondaryForeground,
      error: destructiveColor,
      onError: destructiveForeground,
      surface: backgroundColor,
      onSurface: foregroundColor,
    ),
    
    scaffoldBackgroundColor: backgroundColor,
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      foregroundColor: foregroundColor,
      iconTheme: IconThemeData(color: foregroundColor),
      titleTextStyle: TextStyle(
        color: foregroundColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: backgroundColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    
    // Card Theme - matching web cards
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: borderColor, width: 1),
      ),
      color: cardColor,
      margin: const EdgeInsets.all(0),
    ),
    
    // Elevated Button Theme - matching web buttons
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        backgroundColor: primaryColor,
        foregroundColor: primaryForeground,
        textStyle: const TextStyle(
          inherit: false,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          letterSpacing: 0,
        ),
      ),
    ),
    
    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        side: const BorderSide(color: borderColor, width: 1),
        foregroundColor: foregroundColor,
        textStyle: const TextStyle(
          inherit: false,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: foregroundColor,
        textStyle: const TextStyle(
          inherit: false,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Input Decoration Theme - matching web inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: backgroundColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: inputColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: inputColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: ringColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: destructiveColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: destructiveColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      hintStyle: const TextStyle(
        color: mutedForeground,
        fontWeight: FontWeight.w400,
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: mutedColor,
      selectedColor: primaryColor,
      labelStyle: const TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusSm),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    
    // Bottom Navigation Bar Theme - matching web nav
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: 0,
      backgroundColor: backgroundColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: mutedForeground,
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 11,
      ),
      type: BottomNavigationBarType.fixed,
    ),
    
    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: primaryForeground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusXl),
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: borderColor,
      thickness: 1,
      space: 1,
    ),
    
    // Dialog Theme
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
      ),
      elevation: 0,
      backgroundColor: backgroundColor,
    ),
    
    // Snack Bar Theme
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(
        color: primaryForeground,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    
    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    // Text Theme - matching web typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
        color: foregroundColor,
        height: 1.1,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: foregroundColor,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        letterSpacing: -1,
        color: foregroundColor,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: foregroundColor,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: foregroundColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: foregroundColor,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: foregroundColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: foregroundColor,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: foregroundColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: foregroundColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: foregroundColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: mutedForeground,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: foregroundColor,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: foregroundColor,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: mutedForeground,
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFFFFF),
      onPrimary: Color(0xFF1E1E1E),
      secondary: Color(0xFF2E2E2E),
      onSecondary: Color(0xFFFFFFFF),
      error: destructiveColor,
      onError: destructiveForeground,
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFFAFAFA),
    ),
    
    scaffoldBackgroundColor: const Color(0xFF0F0F0F),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF1E1E1E),
      surfaceTintColor: Colors.transparent,
      foregroundColor: Color(0xFFFAFAFA),
      iconTheme: IconThemeData(color: Color(0xFFFAFAFA)),
      titleTextStyle: TextStyle(
        color: Color(0xFFFAFAFA),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xFF1E1E1E),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    
    // Card Theme
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLg),
        side: const BorderSide(color: Color(0xFF2E2E2E), width: 1),
      ),
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.all(0),
    ),
    
    // Keep similar button and input themes for dark mode...
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        foregroundColor: const Color(0xFF1E1E1E),
        textStyle: const TextStyle(
          inherit: false,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Text Theme for Dark Mode
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
        color: Color(0xFFFAFAFA),
        height: 1.1,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: Color(0xFFFAFAFA),
        height: 1.5,
      ),
    ),
  );
}
