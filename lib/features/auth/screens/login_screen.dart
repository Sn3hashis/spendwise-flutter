import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spendwise/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import 'sign_up_screen.dart';
import '../../../core/widgets/exit_dialog.dart';
import 'forgot_password_screen.dart';
import 'pin_entry_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onLogin() {
    // Add login logic here
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (context) => const PinEntryScreen(mode: PinEntryMode.setup),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (Navigator.of(context).canPop()) {
      return true;
    }
    final shouldPop = await ExitDialog.show(context);
    return shouldPop ?? false;
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
              Expanded(
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
                                      onTap: () => setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      }),
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
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CupertinoButton(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      onPressed: () {
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
                                const SizedBox(height: 24),
                                CupertinoButton.filled(
                                  onPressed: _onLogin,
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      'LOGIN',
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
                                CupertinoButton(
                                  onPressed: () {
                                    // Add Google sign in logic
                                    Navigator.of(context).pushReplacement(
                                      CupertinoPageRoute(
                                        builder: (context) =>
                                            const PinEntryScreen(
                                                mode: PinEntryMode.setup),
                                      ),
                                    );
                                  },
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
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
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
            ],
          ),
        ),
      ),
    );
  }
}
