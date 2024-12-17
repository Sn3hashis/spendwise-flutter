import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/haptic_service.dart';

enum HapticFeedbackType {
  light,
  medium,
  heavy,
}

class HapticFeedbackWrapper extends ConsumerWidget {
  final Widget child;
  final VoidCallback onPressed;
  final HapticFeedbackType feedbackType;

  const HapticFeedbackWrapper({
    super.key,
    required this.child,
    required this.onPressed,
    this.feedbackType = HapticFeedbackType.light,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        switch (feedbackType) {
          case HapticFeedbackType.light:
            await HapticService.lightImpact(ref);
            break;
          case HapticFeedbackType.medium:
            await HapticService.mediumImpact(ref);
            break;
          case HapticFeedbackType.heavy:
            await HapticService.heavyImpact(ref);
            break;
        }
        onPressed();
      },
      child: child,
    );
  }
} 