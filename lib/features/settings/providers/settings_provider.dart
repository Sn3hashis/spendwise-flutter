import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
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
}

class SettingsNotifier extends StateNotifier<Settings> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs)
      : super(Settings(
          theme: _prefs.getString('theme') ?? 'System',
          currency: _prefs.getString('currency') ?? 'USD',
          language: _prefs.getString('language') ?? 'English',
          haptics: _prefs.getString('haptics') ?? 'On',
          security: _prefs.getString('security') ?? 'Off',
          notifications: _prefs.getString('notifications') ?? 'On',
        ));

  Future<void> updateTheme(String theme) async {
    await _prefs.setString('theme', theme);
    state = state.copyWith(theme: theme);
  }

  Future<void> updateCurrency(String currency) async {
    await _prefs.setString('currency', currency);
    state = state.copyWith(currency: currency);
  }

  Future<void> updateLanguage(String language) async {
    await _prefs.setString('language', language);
    state = state.copyWith(language: language);
  }

  Future<void> updateHaptics(String haptics) async {
    await _prefs.setString('haptics', haptics);
    state = state.copyWith(haptics: haptics);
  }

  Future<void> updateSecurity(String security) async {
    await _prefs.setString('security', security);
    state = state.copyWith(security: security);
  }

  Future<void> updateNotifications(String notifications) async {
    await _prefs.setString('notifications', notifications);
    state = state.copyWith(notifications: notifications);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
}); 