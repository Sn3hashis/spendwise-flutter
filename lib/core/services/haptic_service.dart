import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/providers/settings_provider.dart';

class HapticService {
  static Future<void> lightImpact(WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    if (settings.haptics == 'On') {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          await Vibration.vibrate(duration: 50, amplitude: 128);
        }
      } catch (e) {
        // Ignore errors if haptics are not available
      }
    }
  }

  static Future<void> mediumImpact(WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    if (settings.haptics == 'On') {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          await Vibration.vibrate(duration: 100, amplitude: 192);
        }
      } catch (e) {
        // Ignore errors if haptics are not available
      }
    }
  }

  static Future<void> heavyImpact(WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    if (settings.haptics == 'On') {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          await Vibration.vibrate(duration: 150, amplitude: 255);
        }
      } catch (e) {
        // Ignore errors if haptics are not available
      }
    }
  }

  static Future<void> selectionClick(WidgetRef ref) async {
    final settings = ref.read(settingsProvider);
    if (settings.haptics == 'On') {
      await HapticFeedback.selectionClick();
    }
  }

  static Future<void> errorVibrate(WidgetRef ref) async {
    final haptics = ref.read(settingsProvider).haptics;
    if (haptics == 'On') {
      await HapticFeedback.vibrate();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.vibrate();
    }
  }
} 