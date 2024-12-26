import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../services/settings_service.dart';
import '../../auth/providers/security_preferences_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

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

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      theme: json['theme'],
      currency: json['currency'],
      language: json['language'],
      haptics: json['haptics'],
      security: json['security'],
      notifications: json['notifications'],
    );
  }
}

class SettingsNotifier extends StateNotifier<Settings> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SettingsNotifier() : super(Settings()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      debugPrint('[SettingsNotifier] Loading settings...');
      
      // First try to load from local storage
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('settings');
      
      if (settingsJson != null) {
        state = Settings.fromJson(jsonDecode(settingsJson));
        debugPrint('[SettingsNotifier] Loaded settings from local storage');
      }
      
      // Then sync with Firebase
      await syncWithFirebase();
    } catch (e) {
      debugPrint('[SettingsNotifier] Error loading settings: $e');
    }
  }

  Future<void> _saveToLocalStorage(Settings settings) async {
    try {
      debugPrint('[SettingsNotifier] Saving settings to local storage...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('settings', jsonEncode(settings.toJson()));
      debugPrint('[SettingsNotifier] Successfully saved settings to local storage');
    } catch (e) {
      debugPrint('[SettingsNotifier] Error saving to local storage: $e');
    }
  }

  Future<void> syncWithFirebase() async {
    try {
      debugPrint('[SettingsNotifier] Starting Firebase sync...');
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('[SettingsNotifier] No user logged in, skipping sync');
        return;
      }

      final settingsDoc = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('settings')
          .doc('preferences');
      
      try {
        final doc = await settingsDoc.get();
        if (doc.exists) {
          final settings = Settings.fromJson(doc.data()!);
          state = settings;
          await _saveToLocalStorage(settings);
          debugPrint('[SettingsNotifier] Successfully synced settings from Firebase');
        } else {
          // Initialize settings document
          await settingsDoc.set(state.toJson());
          debugPrint('[SettingsNotifier] Created new settings document in Firebase');
        }
      } catch (e) {
        debugPrint('[SettingsNotifier] Error accessing settings: $e');
      }
    } catch (e) {
      debugPrint('[SettingsNotifier] Error during Firebase sync: $e');
    }
  }

  Future<void> updateSettings(Settings settings) async {
    try {
      debugPrint('[SettingsNotifier] Updating settings');
      final user = _auth.currentUser;
      
      state = settings;
      await _saveToLocalStorage(settings);
      
      if (user != null) {
        try {
          await _firestore
              .collection('users')
              .doc(user.uid)
              .collection('settings')
              .doc('preferences')
              .set(settings.toJson(), SetOptions(merge: true));
          
          debugPrint('[SettingsNotifier] Successfully updated Firebase settings');
        } catch (e) {
          debugPrint('[SettingsNotifier] Error updating Firebase settings: $e');
        }
      }
    } catch (e) {
      debugPrint('[SettingsNotifier] Error updating settings: $e');
      rethrow;
    }
  }

  Future<void> updateTheme(String theme) async {
    final newSettings = state.copyWith(theme: theme);
    await updateSettings(newSettings);
  }

  Future<void> updateCurrency(String currency) async {
    final newSettings = state.copyWith(currency: currency);
    await updateSettings(newSettings);
  }

  Future<void> updateLanguage(String language) async {
    final newSettings = state.copyWith(language: language);
    await updateSettings(newSettings);
  }

  Future<void> updateHaptics(String haptics) async {
    final newSettings = state.copyWith(haptics: haptics);
    await updateSettings(newSettings);
  }

  Future<void> updateSecurity(String security) async {
    final newSettings = state.copyWith(security: security);
    await updateSettings(newSettings);
  }

  Future<void> updateNotifications(String notifications) async {
    final newSettings = state.copyWith(notifications: notifications);
    await updateSettings(newSettings);
  }

  String getCurrentSecurityMethod() {
    final securityMethod = _auth.currentUser;
    switch (securityMethod) {
      case null:
        return 'Off';
      default:
        return 'On';
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, Settings>((ref) {
  return SettingsNotifier();
});