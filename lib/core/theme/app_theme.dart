import 'package:flutter/cupertino.dart';

class AppTheme {
  // Background Colors
  static const Color backgroundDark = Color(0xFF000000);
  static const Color backgroundLight = CupertinoColors.white;
  
  // Card Colors
  static const Color cardDark = Color(0xFF1C1C1E);
  static const Color cardLight = CupertinoColors.white;
  
  // Text Colors
  static const Color textPrimaryDark = CupertinoColors.white;
  static const Color textPrimaryLight = CupertinoColors.black;
  static const Color textSecondaryDark = Color(0xFF8E8E93);
  static const Color textSecondaryLight = Color(0xFF8E8E93);
  
  // Icon Colors
  static const Map<String, Color> iconColors = {
    'account': Color(0xFF007AFF),
    'settings': Color(0xFF8E8E93),
    'export': Color(0xFFFF2D55),
    'category': Color(0xFF34C759),
    'payees': Color(0xFFFF9500),
    'lend': Color(0xFF007AFF),
    'logout': Color(0xFFFF3B30),
  };

  static const Color primaryLight = CupertinoColors.systemBlue;
  static const Color secondaryLight = CupertinoColors.systemIndigo;
  static const Color textLight = CupertinoColors.black;

  static const Color primaryDark = CupertinoColors.systemBlue;
  static const Color secondaryDark = CupertinoColors.systemIndigo;
  static const Color textDark = CupertinoColors.white;

  static const Color bottomNavBarLight = CupertinoColors.white;
  static const Color bottomNavBarDark = Color(0xFF1C1C1E);
  static const Color bottomNavBarBorderLight = Color(0xFFE5E5EA);
  static const Color bottomNavBarBorderDark = Color(0xFF38383A);

  static CupertinoThemeData getLightTheme() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryLight,
        textStyle: TextStyle(
          color: textLight,
          fontSize: 16,
        ),
      ),
    );
  }

  static CupertinoThemeData getDarkTheme() {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryDark,
        textStyle: TextStyle(
          color: textDark,
          fontSize: 16,
        ),
      ),
    );
  }
} 