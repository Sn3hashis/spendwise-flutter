import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/providers/settings_provider.dart';

// Add a provider for platform brightness
final platformBrightnessProvider = StateProvider<Brightness>((ref) {
  return WidgetsBinding.instance.platformDispatcher.platformBrightness;
});

final themeProvider = StateProvider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  final platformBrightness = ref.watch(platformBrightnessProvider);
  
  return switch (settings.theme) {
    'Dark' => true,
    'Light' => false,
    _ => platformBrightness == Brightness.dark,
  };
});

// Add a synchronous theme provider for immediate access
final currentThemeProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider);
}); 