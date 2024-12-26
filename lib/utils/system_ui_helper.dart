import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUIHelper {
  static void setSystemUIOverlayStyle({required bool isDarkMode}) {
    final style = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
    );
    
    SystemChrome.setSystemUIOverlayStyle(style);
    // Force apply the style
    SystemChrome.restoreSystemUIOverlays();
  }
}
