import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/haptic_service.dart';

class HapticFeedbackWrapper extends ConsumerWidget {
  final Widget child;
  final VoidCallback onPressed;

  const HapticFeedbackWrapper({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        await HapticService.lightImpact(ref);
        onPressed();
      },
      child: child,
    );
  }
} 