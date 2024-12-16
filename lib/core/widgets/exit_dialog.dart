import 'package:flutter/cupertino.dart';

class ExitDialog {
  static Future<bool?> show(BuildContext context) {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (context) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          child: CupertinoAlertDialog(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Exit Application?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Are you sure you want to exit the application?',
                style: TextStyle(fontSize: 16),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: const Text(
                  'No',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text(
                  'Yes',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
