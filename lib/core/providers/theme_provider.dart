import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/providers/settings_provider.dart';

final themeProvider = Provider<bool>((ref) {
  final settings = ref.watch(settingsProvider);
  return switch (settings.theme) {
    'Dark' => true,
    'Light' => false,
    _ => WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark,
  };
}); 