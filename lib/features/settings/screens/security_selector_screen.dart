import 'package:flutter/material.dart' show Theme, ThemeData;
import 'package:flutter/cupertino.dart';
import '../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/toast_service.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';
import '../../auth/providers/security_preferences_provider.dart';
import '../../auth/services/biometric_service.dart';
import '../../auth/screens/pin_entry_screen.dart';
import '../../auth/providers/pin_provider.dart';

class SecuritySelectorScreen extends ConsumerStatefulWidget {
  const SecuritySelectorScreen({super.key});

  @override
  ConsumerState<SecuritySelectorScreen> createState() => _SecuritySelectorScreenState();
}

class _SecuritySelectorScreenState extends ConsumerState<SecuritySelectorScreen> {
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _ensurePinIsDefault();
  }

  Future<void> _ensurePinIsDefault() async {
    final currentMethod = ref.read(securityPreferencesProvider);
    if (currentMethod != SecurityMethod.biometric) {
      await ref.read(securityPreferencesProvider.notifier).setSecurityMethod(SecurityMethod.pin);
    }
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await BiometricService.isAvailable();
    setState(() {
      _isBiometricAvailable = isAvailable;
    });
  }

  Widget _buildSecurityOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required SecurityMethod method,
    required bool isSelected,
    required bool isEnrolled,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HapticFeedbackWrapper(
        onPressed: () async {
          if (method == SecurityMethod.biometric && !_isBiometricAvailable) {
            ToastService.showToast(context, 'Biometric authentication not available on this device');
            return;
          }

          try {
            if (method == SecurityMethod.biometric) {
              final (authenticated, error) = await BiometricService.authenticate();
              if (!authenticated) {
                if (error != null) {
                  ToastService.showToast(context, error);
                }
                return;
              }
              
              await ref.read(securityPreferencesProvider.notifier).setSecurityMethod(method);
            } else if (method == SecurityMethod.pin) {
              final existingPin = ref.read(pinProvider);
              if (existingPin != null) {
                final result = await Navigator.push<bool>(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const PinEntryScreen(
                      mode: PinEntryMode.verify,
                      message: 'Enter your current PIN to confirm',
                    ),
                  ),
                );
                
                if (result == true) {
                  await ref.read(securityPreferencesProvider.notifier).setSecurityMethod(method);
                }
              } else {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const PinEntryScreen(mode: PinEntryMode.setup),
                  ),
                );
              }
            }
          } catch (e) {
            if (!mounted) return;
            ToastService.showToast(context, 'Failed to set security method');
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF3B30),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode 
                            ? AppTheme.textPrimaryDark 
                            : AppTheme.textPrimaryLight,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode 
                            ? AppTheme.textSecondaryDark 
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                    if (isEnrolled || method == SecurityMethod.pin) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Enrolled',
                        style: TextStyle(
                          color: CupertinoColors.activeBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  CupertinoIcons.checkmark_alt,
                  color: const Color(0xFFFF3B30),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final securityMethod = ref.watch(securityPreferencesProvider);
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoPageScaffold(
      backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        middle: const Text('Security'),
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isBiometricAvailable)
              _buildSecurityOption(
                context: context,
                icon: CupertinoIcons.person_crop_circle,
                title: 'Biometric',
                description: 'Use fingerprint or face ID',
                method: SecurityMethod.biometric,
                isSelected: securityMethod == SecurityMethod.biometric,
                isEnrolled: securityMethod == SecurityMethod.biometric,
                isDarkMode: isDarkMode,
              ),
            _buildSecurityOption(
              context: context,
              icon: CupertinoIcons.lock_fill,
              title: 'PIN',
              description: 'Use 4-digit PIN code',
              method: SecurityMethod.pin,
              isSelected: securityMethod == SecurityMethod.pin,
              isEnrolled: true,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }
} 