import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import '../../../core/widgets/exit_dialog.dart';
import 'email_sent_screen.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (Navigator.of(context).canPop()) {
      return true;
    }
    final shouldPop = await ExitDialog.show(context);
    return shouldPop ?? false;
  }

  void _handleResetPassword() async {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendPasswordResetEmail(_emailController.text.trim());
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => EmailSentScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final authService = ref.watch(authServiceProvider);

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
                              'Forgot Password',
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
                          'assets/animations/forgot_password_animation.json',
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Don't worry.",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? CupertinoColors.white
                                        : CupertinoColors.black,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Enter your email and we'll send you a link to reset your password.",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                const SizedBox(height: 32),
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
                                const SizedBox(height: 24),
                                if (_errorMessage != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: CupertinoColors.destructiveRed,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                                SizedBox(
                                  width: double.infinity,
                                  child: CupertinoButton.filled(
                                    onPressed: _isLoading ? null : _handleResetPassword,
                                    borderRadius: BorderRadius.circular(12),
                                    child: _isLoading
                                        ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                                        : const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4),
                                            child: Text(
                                              'Continue',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                  ),
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
