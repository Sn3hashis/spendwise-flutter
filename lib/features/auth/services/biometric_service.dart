import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const int maxAttempts = 3;

  static Future<bool> isAvailable() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  static Future<(bool, String?)> authenticate() async {
    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to access the app',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return (authenticated, null);
    } on PlatformException catch (e) {
      debugPrint('Error authenticating: $e');
      return (false, e.message);
    }
  }
} 