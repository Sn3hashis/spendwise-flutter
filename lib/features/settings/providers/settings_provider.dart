import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final String currency;
  final String language;
  final String theme;
  final String haptics;
  final String security;
  final String notifications;

  const SettingsState({
    this.currency = 'USD',
    this.language = 'English',
    this.theme = 'System',
    this.haptics = 'On',
    this.security = 'Biometric',
    this.notifications = 'On',
  });

  SettingsState copyWith({
    String? currency,
    String? language,
    String? theme,
    String? haptics,
    String? security,
    String? notifications,
  }) {
    return SettingsState(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      haptics: haptics ?? this.haptics,
      security: security ?? this.security,
      notifications: notifications ?? this.notifications,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SharedPreferences _prefs;

  SettingsNotifier(this._prefs) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    state = SettingsState(
      currency: _prefs.getString('currency') ?? 'USD',
      language: _prefs.getString('language') ?? 'English',
      theme: _prefs.getString('theme') ?? 'System',
      haptics: _prefs.getString('haptics') ?? 'On',
      security: _prefs.getString('security') ?? 'Biometric',
      notifications: _prefs.getString('notifications') ?? 'On',
    );
  }

  Future<void> updateCurrency(String currency) async {
    await _prefs.setString('currency', currency);
    state = state.copyWith(currency: currency);
  }

  Future<void> updateLanguage(String language) async {
    await _prefs.setString('language', language);
    state = state.copyWith(language: language);
  }

  Future<void> updateTheme(String theme) async {
    await _prefs.setString('theme', theme);
    state = state.copyWith(theme: theme);
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

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SettingsNotifier(prefs);
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
}); 