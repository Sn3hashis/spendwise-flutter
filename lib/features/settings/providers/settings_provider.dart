import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../services/settings_service.dart';
import '../../auth/providers/security_preferences_provider.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final settingsServiceProvider = Provider<SettingsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsService(prefs);
});

class Settings {
  final String theme;
  final String currency;
  final String language;
  final String haptics;
  final String security;
  final String notifications;

  Settings({
    this.theme = 'System',
    this.currency = 'USD',
    this.language = 'English',
    this.haptics = 'On',
    this.security = 'Off',
    this.notifications = 'On',
  });

  Settings copyWith({
    String? theme,
    String? currency,
    String? language,
    String? haptics,
    String? security,
    String? notifications,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      haptics: haptics ?? this.haptics,
      security: security ?? this.security,
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'currency': currency,
      'language': language,
      'haptics': haptics,
      'security': security,
      'notifications': notifications,
    };
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  final SettingsService _settingsService;
  final Ref _ref;

  SettingsNotifier(this._settingsService, this._ref) : super(Settings()) {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      final settings = await _settingsService.loadSettings();
      state = Settings(
        theme: settings['theme'] ?? 'System',
        currency: settings['currency'] ?? 'USD',
        language: settings['language'] ?? 'English',
        haptics: settings['haptics'] ?? 'On',
        security: settings['security'] ?? 'Off',
        notifications: settings['notifications'] ?? 'On',
      );
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    }
  }

  Future<void> updateTheme(String theme) async {
    try {
      await _settingsService.updateSettings({
        ...state.toJson(),
        'theme': theme,
      });
      state = state.copyWith(theme: theme);
    } catch (e) {
      debugPrint('Error updating theme: $e');
      rethrow;
    }
  }

  Future<void> updateCurrency(String currency) async {
    try {
      await _settingsService.updateSettings({
        ...state.toJson(),
        'currency': currency,
      });
      state = state.copyWith(currency: currency);
    } catch (e) {
      debugPrint('Error updating currency: $e');
      rethrow;
    }
  }

  Future<void> updateLanguage(String language) async {
    try {
      await _settingsService.updateSettings({
        ...state.toJson(),
        'language': language,
      });
      state = state.copyWith(language: language);
    } catch (e) {
      debugPrint('Error updating language: $e');
      rethrow;
    }
  }

  Future<void> updateHaptics(String haptics) async {
    try {
      await _settingsService.updateSettings({
        ...state.toJson(),
        'haptics': haptics,
      });
      state = state.copyWith(haptics: haptics);
    } catch (e) {
      debugPrint('Error updating haptics: $e');
      rethrow;
    }
  }

  Future<void> updateSecurity(String method) async {
    try {
      await _settingsService.updateSettings({
        ...state.toJson(),
        'security': method,
      });
      state = state.copyWith(security: method);
    } catch (e) {
      debugPrint('Error updating security: $e');
      rethrow;
    }
  }

  String getCurrentSecurityMethod() {
    final securityMethod = _ref.read(securityPreferencesProvider);
    switch (securityMethod) {
      case SecurityMethod.biometric:
        return 'Biometric';
      case SecurityMethod.pin:
        return 'PIN';
    }
  }

  Future<void> updateNotifications(String notifications) async {
    try {
      await _settingsService.updateSettings({
        ...state.toJson(),
        'notifications': notifications,
      });
      state = state.copyWith(notifications: notifications);
    } catch (e) {
      debugPrint('Error updating notifications: $e');
      rethrow;
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  final settingsService = ref.watch(settingsServiceProvider);
  return SettingsNotifier(settingsService, ref);
}); 