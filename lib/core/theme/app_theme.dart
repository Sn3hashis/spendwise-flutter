import 'package:flutter/cupertino.dart';

class AppTheme {
  // Light Theme Colors
  static const Color backgroundLight = CupertinoColors.white;
  static const Color cardLight = CupertinoColors.white;
  static const Color textPrimaryLight = CupertinoColors.black;
  static const Color textSecondaryLight = CupertinoColors.systemGrey;
  static const Color bottomNavBarLight = CupertinoColors.white;
  static const Color bottomNavBarBorderLight = Color(0xFFE5E5EA);

  // Dark Theme Colors
  static const Color backgroundDark = CupertinoColors.black;
  static const Color cardDark = Color(0xFF1C1C1E);
  static const Color textPrimaryDark = CupertinoColors.white;
  static const Color textSecondaryDark = CupertinoColors.systemGrey;
  static const Color bottomNavBarDark = Color(0xFF1C1C1E);
  static const Color bottomNavBarBorderDark = Color(0xFF38383A);

  // Icon Colors Map
  static const Map<String, Color> iconColors = {
    'account': CupertinoColors.systemBlue,
    'settings': CupertinoColors.systemGreen,
    'export': CupertinoColors.systemOrange,
    'category': CupertinoColors.systemPurple,
    'payees': CupertinoColors.systemPink,
    'lend': CupertinoColors.systemYellow,
    'analytics': CupertinoColors.systemTeal,
    'logout': CupertinoColors.systemRed,
  };

  static CupertinoThemeData getLightTheme() {
    return const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: CupertinoColors.systemBlue,
      scaffoldBackgroundColor: backgroundLight,
      barBackgroundColor: backgroundLight,
      textTheme: CupertinoTextThemeData(
        primaryColor: textPrimaryLight,
        textStyle: TextStyle(
          color: textPrimaryLight,
          fontSize: 16,
        ),
      ),
    );
  }

  static CupertinoThemeData getDarkTheme() {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: CupertinoColors.systemBlue,
      scaffoldBackgroundColor: backgroundDark,
      barBackgroundColor: backgroundDark,
      textTheme: CupertinoTextThemeData(
        primaryColor: textPrimaryDark,
        textStyle: TextStyle(
          color: textPrimaryDark,
          fontSize: 16,
        ),
      ),
    );
  }
} 