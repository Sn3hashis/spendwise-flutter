import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class OTPService {
  static const String _otpKey = 'otp_';
  static const String _otpExpiryKey = 'otp_expiry_';
  
  // Generate a 6-digit OTP
  static String generateOTP() {
    final random = Random();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Save OTP with expiry (5 minutes)
  static Future<void> saveOTP(String email, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(const Duration(minutes: 5));
    
    await prefs.setString('$_otpKey$email', otp);
    await prefs.setString('$_otpExpiryKey$email', expiryTime.toIso8601String());
  }

  // Verify OTP
  static Future<bool> verifyOTP(String email, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    final savedOTP = prefs.getString('$_otpKey$email');
    final expiryTimeStr = prefs.getString('$_otpExpiryKey$email');

    if (savedOTP == null || expiryTimeStr == null) {
      return false;
    }

    final expiryTime = DateTime.parse(expiryTimeStr);
    if (DateTime.now().isAfter(expiryTime)) {
      // OTP expired, clean up
      await _cleanupOTP(email);
      return false;
    }

    if (savedOTP == otp) {
      // Clean up after successful verification
      await _cleanupOTP(email);
      return true;
    }

    return false;
  }

  // Clean up OTP data
  static Future<void> _cleanupOTP(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_otpKey$email');
    await prefs.remove('$_otpExpiryKey$email');
  }
} 