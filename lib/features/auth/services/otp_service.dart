import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class OTPService {
  static const String _otpKey = 'otp_';
  static const String _otpExpiryKey = 'otp_expiry_';
  
  // Generate a 6-digit OTP
  static String generateOTP() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // Save OTP with expiry (5 minutes)
  static Future<void> saveOTP(String email, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTime = DateTime.now().add(const Duration(minutes: 5));
    
    // Save values separately since we can't use Future.wait with nullable returns
    await prefs.setString('$_otpKey$email', otp);
    await prefs.setString('$_otpExpiryKey$email', expiryTime.toIso8601String());
  }

  // Verify OTP with optimized checks
  static Future<bool> verifyOTP(String email, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get values separately since getString returns String?
    final savedOTP = prefs.getString('$_otpKey$email');
    final expiryTimeStr = prefs.getString('$_otpExpiryKey$email');

    if (savedOTP == null || expiryTimeStr == null) {
      return false;
    }

    final expiryTime = DateTime.parse(expiryTimeStr);
    if (DateTime.now().isAfter(expiryTime)) {
      // Clean up expired OTP in the background
      _cleanupOTP(email);
      return false;
    }

    final isValid = savedOTP == otp;
    if (isValid) {
      // Clean up used OTP in the background
      _cleanupOTP(email);
    }
    return isValid;
  }

  // Clean up OTP data in the background
  static Future<void> _cleanupOTP(String email) async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('$_otpKey$email');
      prefs.remove('$_otpExpiryKey$email');
    });
  }
} 