import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SettingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  Future<Map<String, dynamic>> loadSettings() async {
    try {
      // First try to get from local storage
      final localSettings = _getLocalSettings();
      
      // Try to sync with Firebase if user is logged in
      final user = _auth.currentUser;
      if (user != null) {
        try {
          final doc = await _firestore
              .collection('userSettings')
              .doc(user.uid)
              .get();

          if (doc.exists) {
            final serverSettings = doc.data()!;
            // Update local storage with server data
            await _saveLocalSettings(serverSettings);
            return serverSettings;
          }
          
          // If no server settings exist, save local settings to server
          await _saveServerSettings(localSettings);
        } catch (e) {
          debugPrint('Error syncing with server: $e');
          // Return local settings if server sync fails
        }
      }
      
      return localSettings;
    } catch (e) {
      debugPrint('Error loading settings: $e');
      return _getDefaultSettings();
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      // Update local storage first
      await _saveLocalSettings(settings);
      
      // Try to update server if user is logged in
      final user = _auth.currentUser;
      if (user != null) {
        try {
          await _saveServerSettings(settings);
        } catch (e) {
          debugPrint('Error saving to server, will retry later: $e');
          // Don't rethrow server errors - we've already saved locally
          // Could implement a background sync queue here
        }
      }
    } catch (e) {
      debugPrint('Error updating settings: $e');
      rethrow;
    }
  }

  Future<void> _saveServerSettings(Map<String, dynamic> settings) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('userSettings')
          .doc(user.uid)
          .set({
        ...settings,
        'userId': user.uid,
        'email': user.email,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving to server: $e');
      // Store failed updates for later retry
      await _storeFailedUpdate(settings);
      rethrow;
    }
  }

  Future<void> _storeFailedUpdate(Map<String, dynamic> settings) async {
    try {
      final failedUpdates = _prefs.getStringList('failed_settings_updates') ?? [];
      failedUpdates.add(DateTime.now().toIso8601String());
      await _prefs.setStringList('failed_settings_updates', failedUpdates);
      
      // Store the failed update
      await _prefs.setString(
        'failed_update_${DateTime.now().millisecondsSinceEpoch}',
        settings.toString(),
      );
    } catch (e) {
      debugPrint('Error storing failed update: $e');
    }
  }

  Map<String, dynamic> _getLocalSettings() {
    return {
      'theme': _prefs.getString('theme') ?? 'System',
      'currency': _prefs.getString('currency') ?? 'USD',
      'language': _prefs.getString('language') ?? 'English',
      'haptics': _prefs.getString('haptics') ?? 'On',
      'security': _prefs.getString('security') ?? 'Off',
      'notifications': _prefs.getString('notifications') ?? 'On',
      'lastSynced': _prefs.getString('lastSynced'),
    };
  }

  Map<String, dynamic> _getDefaultSettings() {
    return {
      'theme': 'System',
      'currency': 'USD',
      'language': 'English',
      'haptics': 'On',
      'security': 'Off',
      'notifications': 'On',
    };
  }

  Future<void> _saveLocalSettings(Map<String, dynamic> settings) async {
    await Future.wait([
      _prefs.setString('theme', settings['theme']),
      _prefs.setString('currency', settings['currency']),
      _prefs.setString('language', settings['language']),
      _prefs.setString('haptics', settings['haptics']),
      _prefs.setString('security', settings['security']),
      _prefs.setString('notifications', settings['notifications']),
      _prefs.setString('lastSynced', DateTime.now().toIso8601String()),
    ]);
  }

  Future<void> clearSettings() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore
            .collection('userSettings')
            .doc(user.uid)
            .delete();
      } catch (e) {
        debugPrint('Error clearing server settings: $e');
      }
    }
    
    await Future.wait([
      _prefs.remove('theme'),
      _prefs.remove('currency'),
      _prefs.remove('language'),
      _prefs.remove('haptics'),
      _prefs.remove('security'),
      _prefs.remove('notifications'),
      _prefs.remove('lastSynced'),
    ]);
  }
} 