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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ToastService.showToast(context, 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (!mounted) return;
      await HapticService.lightImpact(ref);
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => const PinEntryScreen(mode: PinEntryMode.setup),
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
      final userCredential = await _authService.signInWithGoogle();
      
      if (!mounted) return;
      
      if (userCredential.user != null) {
        await HapticService.lightImpact(ref);
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const PinEntryScreen(mode: PinEntryMode.setup),
          ),
        );
      } else {
        ToastService.showToast(context, 'Failed to sign in with Google');
      }
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
          backgroundColor: isDarkMode ? CupertinoColors.black : CupertinoColors.white,
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
                                    _isPasswordVisible =
                                        !_isPasswordVisible;
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
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                onPressed: () async {
                                  await HapticService.lightImpact(ref);
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => const ForgotPasswordScreen(),
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
                              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            onPressed: _isLoading ? () {} : _onLogin,
                            child: CupertinoButton.filled(
                              onPressed: _isLoading ? () {} : _onLogin,
                              borderRadius: BorderRadius.circular(12),
                              child: _isLoading
                                  ? const CupertinoActivityIndicator(color: CupertinoColors.white)
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
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
                            onPressed: _isLoading ? () {} : () => _handleGoogleSignIn(),
                            child: CupertinoButton(
                              onPressed: _isLoading ? () {} : () => _handleGoogleSignIn(),
                              color: isDarkMode
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                              borderRadius: BorderRadius.circular(12),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
