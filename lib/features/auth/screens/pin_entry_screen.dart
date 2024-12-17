import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import '../screens/login_screen.dart';
import '../../main/screens/main_layout_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';
import '../../../core/services/haptic_service.dart';

enum PinEntryMode { setup, verify }

class PinEntryScreen extends ConsumerStatefulWidget {
  final PinEntryMode mode;
  final String? setupConfirmPin;

  const PinEntryScreen({
    super.key,
    required this.mode,
    this.setupConfirmPin,
  });

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  final int pinLength = 4;
  String currentPin = '';
  String? errorMessage;

  void _onNumberPressed(String number) async {
    await HapticService.lightImpact(ref);
    if (currentPin.length < pinLength) {
      setState(() {
        currentPin += number;
        errorMessage = null;
      });

      if (currentPin.length == pinLength) {
        _handlePinComplete();
      }
    }
  }

  void _onBackspacePressed() async {
    await HapticService.lightImpact(ref);
    if (currentPin.isNotEmpty) {
      setState(() {
        currentPin = currentPin.substring(0, currentPin.length - 1);
        errorMessage = null;
      });
    }
  }

  void _handlePinComplete() {
    if (widget.mode == PinEntryMode.setup) {
      if (widget.setupConfirmPin == null) {
        // First time entering PIN
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => PinEntryScreen(
              mode: PinEntryMode.setup,
              setupConfirmPin: currentPin,
            ),
          ),
        );
      } else {
        // Confirming PIN
        if (currentPin == widget.setupConfirmPin) {
          // Navigate to main layout
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const MainLayoutScreen(),
            ),
          );
        } else {
          setState(() {
            errorMessage = 'PINs do not match. Please try again.';
            currentPin = '';
          });
        }
      }
    } else {
      // Verify PIN
      // TODO: Add PIN verification logic
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => const MainLayoutScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                          onPressed: () async {
                            await HapticService.lightImpact(ref);
                            Navigator.of(context).pushReplacement(
                              CupertinoPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Icon(
                            CupertinoIcons.back,
                            color: isDarkMode
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'PIN VERIFICATION',
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
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Lottie Animation
                  Lottie.asset(
                    'assets/animations/pin_verification_animation.json',
                    height: size.height * 0.2,
                    repeat: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.mode == PinEntryMode.setup
                        ? widget.setupConfirmPin == null
                            ? 'Enter new PIN'
                            : 'Confirm your PIN'
                        : 'Enter your PIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pinLength,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: isDarkMode
                              ? CupertinoColors.systemGrey6.darkColor
                              : CupertinoColors.systemGrey6,
                        ),
                        child: Center(
                          child: index < currentPin.length
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDarkMode
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      errorMessage!,
                      style: const TextStyle(
                        color: CupertinoColors.destructiveRed,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Reset PIN Button
                  CupertinoButton(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onPressed: () async {
                      await HapticService.lightImpact(ref);
                      setState(() {
                        currentPin = '';
                        errorMessage = null;
                      });
                    },
                    child: Text(
                      'Reset PIN',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Keypad
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: bottomPadding + 16,
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < 4; i++)
                          Container(
                            height: 55,
                            margin: EdgeInsets.only(
                              bottom:
                                  i == 3 ? 24 : 8, // More space after last row
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
                                      Expanded(child: _buildBiometricButton()),
                                      Expanded(child: _buildNumberButton('0')),
                                      Expanded(child: _buildBackspaceButton()),
                                    ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (widget.mode == PinEntryMode.verify)
                    Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding + 16),
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        onPressed: () async {
                          await HapticService.lightImpact(ref);
                          // TODO: Implement forgot PIN logic
                        },
                        child: const Text(
                          'Forgot PIN?',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return HapticFeedbackWrapper(
      onPressed: () {
        _onNumberPressed(number);
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return HapticFeedbackWrapper(
      onPressed: () {
        _onBackspacePressed();
      },
      child: Container(
        height: 55,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _onBackspacePressed,
          child: const Icon(
            CupertinoIcons.delete_left,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton() {
    return HapticFeedbackWrapper(
      onPressed: () {
        // TODO: Implement biometric authentication
      },
      child: Container(
        height: 55,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // TODO: Implement biometric authentication
          },
          child: const Icon(
            CupertinoIcons.flag_circle,
            size: 28,
          ),
        ),
      ),
    );
  }
}
