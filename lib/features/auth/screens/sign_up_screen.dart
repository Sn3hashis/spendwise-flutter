import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import '../../../core/widgets/exit_dialog.dart';
import 'package:lottie/lottie.dart';
import 'otp_verification_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';
import 'pin_entry_screen.dart';
import '../services/auth_service.dart';
import '../../../core/services/toast_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  String? _errorMessage;

  void _validateField(String? value, String fieldName) {
    setState(() {
      switch (fieldName) {
        case 'name':
          _nameError = value?.isEmpty ?? true ? 'Please enter your name' : null;
          break;
        case 'email':
          if (value?.isEmpty ?? true) {
            _emailError = 'Please enter your email';
          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
            _emailError = 'Please enter a valid email';
          } else {
            _emailError = null;
          }
          break;
        case 'password':
          if (value?.isEmpty ?? true) {
            _passwordError = 'Please enter your password';
          } else if (value!.length < 6) {
            _passwordError = 'Password must be at least 6 characters';
          } else {
            _passwordError = null;
          }
          break;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (Navigator.of(context).canPop()) {
      return true;
    }
    final shouldPop = await ExitDialog.show(context);
    return shouldPop ?? false;
  }

  Future<void> _handleSignUp() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      ToastService.showToast(context, 'Please fill in all fields');
      return;
    }

    if (!_agreedToTerms) {
      ToastService.showToast(context, 'Please agree to the Terms of Service');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      // Show immediate feedback
      ToastService.showToast(context, 'Creating your account...');

      final userCredential = await authService.signUpWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );
      
      if (!mounted) return;

      // Navigate to OTP screen immediately after account creation
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => OtpVerificationScreen(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
          ),
        ),
      );

      // Show success message
      ToastService.showToast(
        context, 
        'Account created! Please check your email for verification code.',
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

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get Google account
      final googleAccount = await GoogleSignIn().signIn();
      if (googleAccount == null) {
        throw 'Google sign in was cancelled';
      }

      // Sign in with Google
      final authService = ref.read(authServiceProvider);
      final userCredential = await authService.signInWithGoogle(
        googleAccount: googleAccount,
      );
      
      if (!mounted) return;
      
      if (userCredential.user != null) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const PinEntryScreen(
              mode: PinEntryMode.setup,
            ),
          ),
        );
      } else {
        ToastService.showToast(context, 'Failed to sign up with Google');
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showToast(context, e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: SystemUIWrapper(
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
                              'Sign Up',
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
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Lottie.asset(
                          'assets/animations/signup_animation.json',
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
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
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Name Field
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
                                      controller: _nameController,
                                      placeholder: 'Full Name',
                                      prefix: const Icon(
                                        CupertinoIcons.person,
                                        color: CupertinoColors.systemGrey,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      style: TextStyle(
                                        color: isDarkMode
                                            ? CupertinoColors.white
                                            : CupertinoColors.black,
                                      ),
                                      placeholderStyle: const TextStyle(
                                        color: CupertinoColors.systemGrey,
                                      ),
                                      onChanged: (value) =>
                                          _validateField(value, 'name'),
                                    ),
                                  ),
                                  if (_nameError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 16),
                                      child: Text(
                                        _nameError!,
                                        style: const TextStyle(
                                          color: CupertinoColors.destructiveRed,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  // Email Field
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
                                      onChanged: (value) =>
                                          _validateField(value, 'email'),
                                    ),
                                  ),
                                  if (_emailError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 16),
                                      child: Text(
                                        _emailError!,
                                        style: const TextStyle(
                                          color: CupertinoColors.destructiveRed,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 16),
                                  // Password Field
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
                                      onChanged: (value) =>
                                          _validateField(value, 'password'),
                                    ),
                                  ),
                                  if (_passwordError != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, left: 16),
                                      child: Text(
                                        _passwordError!,
                                        style: const TextStyle(
                                          color: CupertinoColors.destructiveRed,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  const SizedBox(height: 24),
                                  // Terms and Conditions
                                  Row(
                                    children: [
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () => setState(() =>
                                            _agreedToTerms = !_agreedToTerms),
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: _agreedToTerms
                                                  ? CupertinoTheme.of(context)
                                                      .primaryColor
                                                  : CupertinoColors.systemGrey,
                                            ),
                                            color: _agreedToTerms
                                                ? CupertinoTheme.of(context)
                                                    .primaryColor
                                                : Colors.transparent,
                                          ),
                                          child: _agreedToTerms
                                              ? const Icon(
                                                  CupertinoIcons.check_mark,
                                                  size: 16,
                                                  color: CupertinoColors.white,
                                                )
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'I agree to the ',
                                            style: TextStyle(
                                              color: isDarkMode
                                                  ? CupertinoColors.white
                                                  : CupertinoColors.black,
                                              fontSize: 14,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Terms of Service',
                                                style: TextStyle(
                                                  color:
                                                      CupertinoTheme.of(context)
                                                          .primaryColor,
                                                ),
                                              ),
                                              const TextSpan(text: ' and '),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: TextStyle(
                                                  color:
                                                      CupertinoTheme.of(context)
                                                          .primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  CupertinoButton.filled(
                                    onPressed: (_isLoading || !_agreedToTerms) ? null : _handleSignUp,
                                    borderRadius: BorderRadius.circular(12),
                                    child: _isLoading
                                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                                        : const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4),
                                            child: Text(
                                              'Sign Up',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: CupertinoColors.white,
                                              ),
                                            ),
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
                                          'Or with',
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
                                  CupertinoButton(
                                    onPressed: _isLoading ? null : _handleGoogleSignUp,
                                    color: isDarkMode
                                        ? CupertinoColors.black
                                        : CupertinoColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/google_logo.svg',
                                          height: 24,
                                          width: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Sign up with Google',
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
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account? ',
                                        style: TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          await HapticService.lightImpact(ref);
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          'Sign In',
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
}
