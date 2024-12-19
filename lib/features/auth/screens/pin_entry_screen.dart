import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import '../screens/login_screen.dart';
import '../../main/screens/main_layout_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';
import '../../../core/services/haptic_service.dart';
import '../providers/pin_provider.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/theme/app_theme.dart';
import '../services/biometric_service.dart';

enum PinEntryMode { setup, verify }

class PinEntryScreen extends ConsumerStatefulWidget {
  final PinEntryMode mode;
  final String? setupConfirmPin;
  final String? message;

  const PinEntryScreen({
    super.key,
    required this.mode,
    this.setupConfirmPin,
    this.message,
  });

  @override
  ConsumerState<PinEntryScreen> createState() => _PinEntryScreenState();
}

class _PinEntryScreenState extends ConsumerState<PinEntryScreen> {
  final int pinLength = 4;
  String currentPin = '';
  bool _isLoading = false;
  String _errorMessage = '';
  String _enteredPin = '';

  @override
  void initState() {
    super.initState();
    _loadExistingPin();
  }

  Future<void> _loadExistingPin() async {
    if (widget.mode == PinEntryMode.verify) {
      try {
        await ref.read(pinProvider.notifier).loadPin();
        final pin = ref.read(pinProvider);
        debugPrint('Loaded PIN: ${pin != null ? 'exists' : 'not found'}'); // Debug log
        
        if (pin == null) {
          if (!mounted) return;
          ToastService.showToast(
            context,
            'PIN not found. Please set up a new PIN.',
          );
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const PinEntryScreen(mode: PinEntryMode.setup),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error loading PIN: $e'); // Debug log
        if (!mounted) return;
        ToastService.showToast(
          context,
          'Failed to load PIN. Please try again.',
        );
      }
    }
  }

  void _onNumberPressed(String number) async {
    await HapticService.lightImpact(ref);
    if (currentPin.length < pinLength) {
      setState(() {
        currentPin += number;
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
      });
    }
  }

  void _handlePinComplete() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
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
          return;
        }

        // Confirming PIN
        if (currentPin == widget.setupConfirmPin) {
          await ref.read(pinProvider.notifier).setPin(currentPin);
          
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const MainLayoutScreen(),
            ),
          );
        } else {
          if (!mounted) return;
          await HapticService.errorVibrate(ref);
          ToastService.showToast(
            context,
            'PINs do not match. Please try again.',
          );
          setState(() {
            currentPin = '';
          });
        }
      } else {
        // Verify PIN
        final storedPin = ref.read(pinProvider);
        if (currentPin == storedPin) {
          if (!mounted) return;
          
          // If we're verifying for security method change, pop with success
          if (widget.message?.contains('confirm') ?? false) {
            Navigator.of(context).pop(true);
            return;
          }
          
          // Normal verification flow
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const MainLayoutScreen(),
            ),
          );
        } else {
          if (!mounted) return;
          await HapticService.errorVibrate(ref);
          ToastService.showToast(
            context,
            'Incorrect PIN. Please try again.',
          );
          setState(() {
            currentPin = '';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showToast(
        context,
        'An error occurred. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyPin(String enteredPin) async {
    final storedPin = ref.read(pinProvider);
    if (storedPin == enteredPin) {
      if (!mounted) return;
      
      // If we're verifying for security method change, pop with success
      if (widget.message?.contains('confirm') ?? false) {
        Navigator.of(context).pop(true);
        return;
      }
      
      // Normal verification flow
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => const MainLayoutScreen(),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Incorrect PIN';
        _enteredPin = '';
      });
      await HapticService.errorVibrate(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          middle: Text(
            widget.mode == PinEntryMode.setup
                ? widget.setupConfirmPin == null
                    ? 'Setup PIN'
                    : 'Confirm PIN'
                : widget.message ?? 'Enter your PIN',
            style: TextStyle(
              color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
          border: null,
          automaticallyImplyLeading: false, // This removes the back button
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: CupertinoActivityIndicator(),
                ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Remove the duplicate text since we now have it in the navigation bar
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
                    const Spacer(),
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
                                bottom: i == 3 ? 24 : 8,
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
                                        Expanded(
                                          child: widget.mode == PinEntryMode.verify && 
                                                 widget.message == null
                                              ? _buildBiometricButton()
                                              : const SizedBox(),
                                        ),
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
      onPressed: () async {
        await HapticService.lightImpact(ref);
        final (authenticated, error) = await BiometricService.authenticate();
        if (!mounted) return;
        
        if (authenticated) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const MainLayoutScreen(),
            ),
          );
        } else if (error != null) {
          ToastService.showToast(context, error);
        }
      },
      child: Container(
        height: 55,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await HapticService.lightImpact(ref);
            final (authenticated, error) = await BiometricService.authenticate();
            if (!mounted) return;
            
            if (authenticated) {
              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => const MainLayoutScreen(),
                ),
              );
            } else if (error != null) {
              ToastService.showToast(context, error);
            }
          },
          child: const Icon(
            CupertinoIcons.person_crop_circle,
            size: 28,
          ),
        ),
      ),
    );
  }
}
