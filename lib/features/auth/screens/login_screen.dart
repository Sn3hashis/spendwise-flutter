import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import 'sign_up_screen.dart';
import '../../../core/widgets/exit_dialog.dart';
import 'forgot_password_screen.dart';
import 'pin_entry_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';
import '../../../core/services/haptic_service.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../../../core/services/toast_service.dart';
import '../providers/pin_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/security_preferences_provider.dart';
import '../services/biometric_service.dart';
import '../../../features/main/screens/main_layout_screen.dart';
import '../../../features/auth/screens/biometric_auth_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ToastService.showToast(context, 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      await HapticService.lightImpact(ref);

      // Load PIN status
      await ref.read(pinProvider.notifier).loadPin();

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => ref.read(pinProvider) != null
              ? const PinEntryScreen(mode: PinEntryMode.verify)
              : const PinEntryScreen(mode: PinEntryMode.setup),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ToastService.showToast(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try silent sign in first - this is much faster if user is already signed in
      final silentSignIn = await GoogleSignIn().signInSilently();
      if (!mounted) return;

      if (silentSignIn != null) {
        // User was previously signed in - directly authenticate with Firebase
        final authService = ref.read(authServiceProvider);
        final userCredential = await authService.signInWithGoogle(
          googleAccount: silentSignIn,
        );
        if (!mounted) return;

        if (userCredential.user != null) {
          await HapticService.lightImpact(ref);
          await _handleSuccessfulLogin();
          return;
        }
      }

      // If silent sign in failed, show account picker
      final googleSignIn = GoogleSignIn();
      final googleAccount = await googleSignIn.signIn();
      if (!mounted) return;

      if (googleAccount != null) {
        final authService = ref.read(authServiceProvider);
        final userCredential = await authService.signInWithGoogle(
          googleAccount: googleAccount,
        );

        if (!mounted) return;

        if (userCredential.user != null) {
          await HapticService.lightImpact(ref);
          await _handleSuccessfulLogin();
        } else {
          ToastService.showToast(
            context,
            'Failed to sign in with Google. Please try again.',
          );
        }
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (!mounted) return;

      String errorMessage = 'Failed to sign in with Google';
      if (e is String) {
        errorMessage = e;
      } else if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }

      ToastService.showToast(context, errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showAccountPicker() async {
    final googleSignIn = GoogleSignIn();

    try {
      // Get current signed in account
      final currentAccount = await googleSignIn.signInSilently();
      if (!mounted) return;

      final isDarkMode = ref.watch(themeProvider);

      showCupertinoModalPopup(
        context: context,
        builder: (context) => Container(
          color:
              isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isDarkMode
                            ? CupertinoColors.systemGrey4
                            : CupertinoColors.systemGrey5,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Choose an account',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                        ),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 17,
                            color: isDarkMode
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.systemBlue,
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentAccount != null)
                          _buildAccountTile(currentAccount),
                        _buildAddAccountTile(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing account picker: $e');
      // Fallback to regular sign in
      await _signInWithGoogle();
    }
  }

  Widget _buildAccountTile(GoogleSignInAccount account) {
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        Navigator.pop(context);
        await _signInWithGoogle(existingAccount: account);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDarkMode
                  ? CupertinoColors.systemGrey4
                  : CupertinoColors.systemGrey5,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isDarkMode
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
              backgroundImage: account.photoUrl != null
                  ? NetworkImage(account.photoUrl!)
                  : null,
              child: account.photoUrl == null
                  ? Icon(
                      CupertinoIcons.person_circle_fill,
                      size: 40,
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName ?? '',
                    style: TextStyle(
                      fontSize: 17,
                      color: isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                  Text(
                    account.email,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode
                          ? CupertinoColors.systemGrey
                          : CupertinoColors.systemGrey2,
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

  Widget _buildAddAccountTile() {
    final isDarkMode = ref.watch(themeProvider);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () async {
        Navigator.pop(context);
        await _signInWithGoogle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? CupertinoColors.systemGrey6
                    : CupertinoColors.systemGrey5,
              ),
              child: Icon(
                CupertinoIcons.add,
                color: isDarkMode
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemBlue,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Add another account',
              style: TextStyle(
                fontSize: 17,
                color: isDarkMode
                    ? CupertinoColors.activeBlue
                    : CupertinoColors.systemBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle({GoogleSignInAccount? existingAccount}) async {
    final googleSignIn = GoogleSignIn();
    final googleAccount = existingAccount ?? await googleSignIn.signIn();
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithGoogle(
        googleAccount: googleAccount,
      );

      if (!mounted) return;

      if (userCredential.user != null) {
        await HapticService.lightImpact(ref);
        await _handleSuccessfulLogin();
      } else {
        ToastService.showToast(
          context,
          'Failed to sign in with Google. Please try again.',
        );
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      if (!mounted) return;

      String errorMessage = 'Failed to sign in with Google';
      if (e is String) {
        errorMessage = e;
      } else if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }

      ToastService.showToast(context, errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (Navigator.of(context).canPop()) {
      return true;
    }
    final shouldPop = await ExitDialog.show(context);
    if (shouldPop ?? false) {
      SystemNavigator.pop();
      return true;
    }
    return false;
  }

  Future<void> _handleSuccessfulLogin() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'No user found after login';
      }

      // Load security preferences first
      await ref.read(securityPreferencesProvider.notifier).loadPreferences();
      final securityMethod = ref.read(securityPreferencesProvider);

      // Only load PIN if it's the selected security method
      if (securityMethod == SecurityMethod.pin) {
        await ref.read(pinProvider.notifier).loadPin();
      }

      if (!mounted) return;

      switch (securityMethod) {
        case SecurityMethod.biometric:
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (context) => const BiometricAuthScreen(),
            ),
          );
          break;

        case SecurityMethod.pin:
          Navigator.of(context).pushReplacement(
            CupertinoPageRoute(
              builder: (context) => ref.read(pinProvider) != null
                  ? const PinEntryScreen(mode: PinEntryMode.verify)
                  : const PinEntryScreen(mode: PinEntryMode.setup),
            ),
          );
          break;
      }
    } catch (e) {
      debugPrint('Error in login flow: $e');
      if (!mounted) return;
      ToastService.showToast(
        context,
        e.toString(),
      );
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
    final isDarkMode = ref.watch(themeProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop) {
            SystemNavigator.pop();
          }
        }
      },
      child: SystemUIWrapper(
        child: CupertinoPageScaffold(
          backgroundColor:
              isDarkMode ? CupertinoColors.black : CupertinoColors.white,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/login_animation.json',
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? CupertinoColors.systemGrey6.darkColor
                        : CupertinoColors.systemGrey6,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: CupertinoTextField.borderless(
                              controller: _emailController,
                              placeholder: 'Email',
                              prefix: const Icon(
                                CupertinoIcons.mail,
                                color: CupertinoColors.systemGrey,
                              ),
                              padding: const EdgeInsets.all(12),
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                color: isDarkMode
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                              ),
                              placeholderStyle: const TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: CupertinoTextField.borderless(
                              controller: _passwordController,
                              placeholder: 'Password',
                              prefix: const Icon(
                                CupertinoIcons.lock,
                                color: CupertinoColors.systemGrey,
                              ),
                              suffix: GestureDetector(
                                onTap: () async {
                                  await HapticService.lightImpact(ref);
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                child: Icon(
                                  _isPasswordVisible
                                      ? CupertinoIcons.eye_slash
                                      : CupertinoIcons.eye,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              obscureText: !_isPasswordVisible,
                              style: TextStyle(
                                color: isDarkMode
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                              ),
                              placeholderStyle: const TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              CupertinoButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                onPressed: () async {
                                  await HapticService.lightImpact(ref);
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forgot password ?',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 0),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 2),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: CupertinoColors.destructiveRed,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          HapticFeedbackWrapper(
                            onPressed: _isLoading ? () {} : _handleLogin,
                            child: CupertinoButton.filled(
                              onPressed: _isLoading ? () {} : _handleLogin,
                              borderRadius: BorderRadius.circular(12),
                              child: _isLoading
                                  ? const CupertinoActivityIndicator(
                                      color: CupertinoColors.white)
                                  : const Text('LOGIN'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: CupertinoColors.systemGrey4,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'Or',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: CupertinoColors.systemGrey4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          HapticFeedbackWrapper(
                            onPressed: _isLoading
                                ? () {}
                                : () => _handleGoogleSignIn(),
                            child: CupertinoButton(
                              onPressed: _isLoading
                                  ? () {}
                                  : () => _handleGoogleSignIn(),
                              color: isDarkMode
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/google_logo.svg',
                                    height: 24,
                                    width: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Sign in with Google',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  color: CupertinoColors.systemGrey,
                                  fontSize: 14,
                                ),
                              ),
                              HapticFeedbackWrapper(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) =>
                                          const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
