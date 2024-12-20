import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';
import '../../../core/services/toast_service.dart';
import '../../main/screens/main_layout_screen.dart';
import 'pin_entry_screen.dart';
import 'dart:async';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';

class BiometricAuthScreen extends ConsumerStatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  ConsumerState<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends ConsumerState<BiometricAuthScreen> {
  int _attempts = 0;
  bool _isLocked = false;
  Timer? _lockoutTimer;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    super.dispose();
  }

  void _switchToPin() {
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (context) => const PinEntryScreen(mode: PinEntryMode.verify),
      ),
    );
  }

  Future<void> _authenticate() async {
    try {
      final (authenticated, error) = await BiometricService.authenticate();
      if (!mounted) return;

      if (authenticated) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const MainLayoutScreen(),
          ),
        );
      } else {
        setState(() {
          _attempts++;
          if (error?.contains('LockedOut') ?? false) {
            _isLocked = true;
            _startLockoutTimer();
          }
        });

        if (error != null) {
          ToastService.showToast(context, error);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showToast(context, 'Biometric authentication failed.');
    }
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isLocked = false;
          _attempts = 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.person_crop_circle,
                  size: 64,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                ),
                const SizedBox(height: 24),
                Text(
                  'Biometric Authentication',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Use your fingerprint or face to unlock',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDarkMode ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2,
                  ),
                ),
                const SizedBox(height: 32),
                if (_isLocked) ...[
                  const Text(
                    'Too many attempts. Please wait 30 seconds or use PIN.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: CupertinoColors.destructiveRed,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  CupertinoButton.filled(
                    onPressed: _authenticate,
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(height: 16),
                ],
                CupertinoButton(
                  onPressed: _switchToPin,
                  child: const Text('Use PIN Instead'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 