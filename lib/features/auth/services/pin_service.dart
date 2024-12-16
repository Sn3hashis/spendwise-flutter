import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  static const String _pinKey = 'user_pin';
  final SharedPreferences _prefs;

  PinService(this._prefs);

  Future<void> savePin(String pin) async {
    // TODO: Also save to Firebase
    await _prefs.setString(_pinKey, pin);
  }

  Future<String?> getPin() async {
    return _prefs.getString(_pinKey);
  }

  Future<bool> verifyPin(String pin) async {
    final storedPin = await getPin();
    return storedPin == pin;
  }

  Future<void> clearPin() async {
    // TODO: Also clear from Firebase
    await _prefs.remove(_pinKey);
  }
}
