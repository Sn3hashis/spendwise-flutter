import 'package:flutter/cupertino.dart';

class AppTheme {
  static const Color primaryLight = CupertinoColors.systemBlue;
  static const Color secondaryLight = CupertinoColors.systemIndigo;
  static const Color backgroundLight = CupertinoColors.systemBackground;
  static const Color textLight = CupertinoColors.black;

  static const Color primaryDark = CupertinoColors.systemBlue;
  static const Color secondaryDark = CupertinoColors.systemIndigo;
  static const Color backgroundDark = CupertinoColors.black;
  static const Color textDark = CupertinoColors.white;

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