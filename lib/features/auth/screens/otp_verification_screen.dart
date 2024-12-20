import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import 'pin_entry_screen.dart';
import '../services/auth_service.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;
  final String password;
  final String name;  // Add name parameter

  const OtpVerificationScreen({
    required this.email,
    required this.password,
    required this.name,  // Add to constructor
    super.key,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  String currentOtp = '';
  int timeLeft = 299; // 5 minutes in seconds
  Timer? timer;
  bool _isLoading = false;
  String? _error;
  
  static const int otpLength = 6;
  final double boxSize = 50;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        setState(() {
          timeLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onNumberPressed(String number) {
    if (currentOtp.length < otpLength) {
      setState(() {
        currentOtp += number;
      });

      if (currentOtp.length == otpLength) {
        _verifyOtp();
      }
    }
  }

  void _onBackspacePressed() {
    if (currentOtp.isNotEmpty) {
      setState(() {
        currentOtp = currentOtp.substring(0, currentOtp.length - 1);
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.verifyOTP(
        email: widget.email,
        otp: currentOtp,
        password: widget.password,
        name: widget.name,  // Pass the name
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => const PinEntryScreen(mode: PinEntryMode.setup),
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        currentOtp = '';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final boxSize = (size.width - 48 - (otpLength - 1) * 12) / otpLength;

    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor:
            isDarkMode ? CupertinoColors.black : CupertinoColors.white,
        child: Column(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 12),
                    child: Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Icon(
                            CupertinoIcons.back,
                            color: isDarkMode
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Verification',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: (isDarkMode
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.systemGrey4)
                        .withOpacity(0.3),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Lottie Animation
                      Lottie.asset(
                        'assets/animations/otp_verification_animation.json',
                        height: size.height * 0.2,
                        repeat: true,
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'Enter your\nVerification Code',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      // OTP boxes
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            otpLength,
                            (index) => Container(
                              width: boxSize,
                              height: boxSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: isDarkMode
                                    ? CupertinoColors.systemGrey6.darkColor
                                    : CupertinoColors.systemGrey6,
                              ),
                              child: Center(
                                child: Text(
                                  index < currentOtp.length
                                      ? currentOtp[index]
                                      : '',
                                  style: TextStyle(
                                    fontSize: boxSize * 0.5,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        formatTime(timeLeft),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: CupertinoColors.systemIndigo,
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                          children: [
                            const TextSpan(
                                text:
                                    'We send verification code to your email '),
                            TextSpan(
                              text: widget.email,
                              style: const TextStyle(
                                color: CupertinoColors.activeBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: '. You can check your inbox.'),
                          ],
                        ),
                      ),
                      CupertinoButton(
                        onPressed: timeLeft == 0
                            ? () {
                                setState(() {
                                  timeLeft = 299;
                                  startTimer();
                                });
                              }
                            : null,
                        child: Text(
                          'I didn\'t received the code? Send again',
                          style: TextStyle(
                            fontSize: 14,
                            color: timeLeft == 0
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            // Keypad at bottom
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? CupertinoColors.black
                      : CupertinoColors.white,
                  border: Border(
                    top: BorderSide(
                      color: CupertinoColors.systemGrey.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0; i < 4; i++)
                      Container(
                        height: 55,
                        margin: EdgeInsets.only(
                          bottom: i == 3 ? 16 : 8,
                        ),
                        child: Row(
                          children: i < 3
                              ? List.generate(
                                  3,
                                  (j) => Expanded(
                                    child: _buildNumberButton(
                                      (i * 3 + j + 1).toString(),
                                    ),
                                  ),
                                )
                              : [
                                  const Expanded(child: SizedBox()),
                                  Expanded(child: _buildNumberButton('0')),
                                  Expanded(child: _buildBackspaceButton()),
                                ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return SizedBox(
      height: 55,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => _onNumberPressed(number),
        child: Text(
          number,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return SizedBox(
      height: 55,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _onBackspacePressed,
        child: const Icon(
          CupertinoIcons.delete_left,
          size: 28,
        ),
      ),
    );
  }
}
