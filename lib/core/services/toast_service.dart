import 'package:flutter/cupertino.dart';

class ToastService {
  static OverlayEntry? _currentToast;

  static void showToast(BuildContext context, String message, {Duration? duration}) {
    if (_currentToast != null) {
      _currentToast!.remove();
      _currentToast = null;
    }

    final overlay = Overlay.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        bottom: keyboardHeight > 0 
            ? keyboardHeight + 8 // Show just above keyboard with 8px padding
            : MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: CupertinoColors.systemRed,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentToast!);

    Future.delayed(duration ?? const Duration(seconds: 1), () {
      if (_currentToast != null) {
        _currentToast!.remove();
        _currentToast = null;
      }
    });
  }
} 