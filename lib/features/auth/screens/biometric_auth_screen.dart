import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/biometric_service.dart';
import '../../../core/services/toast_service.dart';
import '../../main/screens/main_layout_screen.dart';
import 'pin_entry_screen.dart';

class BiometricAuthScreen extends ConsumerStatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  ConsumerState<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends ConsumerState<BiometricAuthScreen> {
  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final authenticated = await BiometricService.authenticate();
      if (!mounted) return;

      if (authenticated) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const MainLayoutScreen(),
          ),
        );
      } else {
        // Fallback to PIN if biometric fails
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(
            builder: (context) => const PinEntryScreen(mode: PinEntryMode.verify),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.showToast(context, 'Biometric authentication failed. Please use PIN.');
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(
          builder: (context) => const PinEntryScreen(mode: PinEntryMode.verify),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: CupertinoActivityIndicator(),
      ),
    );
  }
} 