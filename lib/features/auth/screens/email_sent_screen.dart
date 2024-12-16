import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import 'login_screen.dart';

class EmailSentScreen extends StatelessWidget {
  final String email;

  const EmailSentScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor:
            isDarkMode ? CupertinoColors.black : CupertinoColors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(),
                Lottie.asset(
                  'assets/animations/email_sent_animation.json',
                  height: 200,
                  width: 200,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),
                Text(
                  'Your email is on the way',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text.rich(
                  TextSpan(
                    text: 'Check your email ',
                    style: TextStyle(
                      fontSize: 16,
                      color: CupertinoColors.systemGrey,
                    ),
                    children: [
                      TextSpan(
                        text: email,
                        style: TextStyle(
                          color: CupertinoTheme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text:
                            ' and\nfollow the instructions to reset your password',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed: () {
                        // Pop until login screen
                        Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      color: CupertinoColors.systemIndigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          color: CupertinoTheme.of(context).primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
