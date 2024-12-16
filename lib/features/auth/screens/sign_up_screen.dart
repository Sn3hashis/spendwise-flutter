import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import '../../../core/widgets/exit_dialog.dart';
import 'package:lottie/lottie.dart';
import 'otp_verification_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _agreedToTerms = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  void _validateField(String? value, String fieldName) {
    setState(() {
      switch (fieldName) {
        case 'name':
          _nameError = value?.isEmpty ?? true ? 'Please enter your name' : null;
          break;
        case 'email':
          if (value?.isEmpty ?? true) {
            _emailError = 'Please enter your email';
          } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
              .hasMatch(value!)) {
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

  Future<bool> _onWillPop() async {
    if (Navigator.of(context).canPop()) {
      return true;
    }
    final shouldPop = await ExitDialog.show(context);
    return shouldPop ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

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
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? CupertinoColors.black
                                          : CupertinoColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CupertinoTextFormFieldRow(
                                          controller: _nameController,
                                          placeholder: 'Name',
                                          prefix: const Icon(
                                            CupertinoIcons.person,
                                            color: CupertinoColors.systemGrey,
                                            size: 20,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? CupertinoColors.white
                                                : CupertinoColors.black,
                                          ),
                                          onChanged: (value) =>
                                              _validateField(value, 'name'),
                                          decoration: const BoxDecoration(),
                                        ),
                                        if (_nameError != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, bottom: 8),
                                            child: Text(
                                              _nameError!,
                                              style: const TextStyle(
                                                color:
                                                    CupertinoColors.systemRed,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? CupertinoColors.black
                                          : CupertinoColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CupertinoTextFormFieldRow(
                                          controller: _emailController,
                                          placeholder: 'Email',
                                          prefix: const Icon(
                                            CupertinoIcons.mail,
                                            color: CupertinoColors.systemGrey,
                                            size: 20,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: TextStyle(
                                            color: isDarkMode
                                                ? CupertinoColors.white
                                                : CupertinoColors.black,
                                          ),
                                          onChanged: (value) =>
                                              _validateField(value, 'email'),
                                          decoration: const BoxDecoration(),
                                        ),
                                        if (_emailError != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, bottom: 8),
                                            child: Text(
                                              _emailError!,
                                              style: const TextStyle(
                                                color:
                                                    CupertinoColors.systemRed,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDarkMode
                                          ? CupertinoColors.black
                                          : CupertinoColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CupertinoTextFormFieldRow(
                                                controller: _passwordController,
                                                placeholder: 'Password',
                                                prefix: const Icon(
                                                  CupertinoIcons.lock,
                                                  color: CupertinoColors
                                                      .systemGrey,
                                                  size: 20,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                obscureText:
                                                    !_isPasswordVisible,
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? CupertinoColors.white
                                                      : CupertinoColors.black,
                                                ),
                                                onChanged: (value) =>
                                                    _validateField(
                                                        value, 'password'),
                                                decoration:
                                                    const BoxDecoration(),
                                              ),
                                            ),
                                            CupertinoButton(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                              onPressed: () => setState(() {
                                                _isPasswordVisible =
                                                    !_isPasswordVisible;
                                              }),
                                              child: Icon(
                                                _isPasswordVisible
                                                    ? CupertinoIcons.eye_slash
                                                    : CupertinoIcons.eye,
                                                color:
                                                    CupertinoColors.systemGrey,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_passwordError != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, bottom: 8),
                                            child: Text(
                                              _passwordError!,
                                              style: const TextStyle(
                                                color:
                                                    CupertinoColors.systemRed,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      CupertinoCheckbox(
                                        value: _agreedToTerms,
                                        onChanged: (value) => setState(() =>
                                            _agreedToTerms = value ?? false),
                                      ),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            text:
                                                'By signing up, you agree to the ',
                                            style: TextStyle(
                                              color: CupertinoColors.systemGrey,
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
                                    onPressed: _agreedToTerms
                                        ? () {
                                            bool isValid = true;
                                            _validateField(
                                                _nameController.text, 'name');
                                            _validateField(
                                                _emailController.text, 'email');
                                            _validateField(
                                                _passwordController.text,
                                                'password');

                                            isValid = _nameError == null &&
                                                _emailError == null &&
                                                _passwordError == null;

                                            if (isValid) {
                                              Navigator.push(
                                                context,
                                                CupertinoPageRoute(
                                                  builder: (context) =>
                                                      OtpVerificationScreen(
                                                    email: _emailController.text
                                                        .trim(),
                                                  ),
                                                ),
                                              );
                                            }
                                          }
                                        : null,
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 4),
                                      child: Text(
                                        'Sign Up',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
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
                                    onPressed: () {
                                      // Add Google sign up logic
                                    },
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
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        child: const Text(
                                          'Login',
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
