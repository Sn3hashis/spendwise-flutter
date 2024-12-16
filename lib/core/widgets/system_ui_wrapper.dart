import 'package:flutter/material.dart';
import '../../../utils/system_ui_helper.dart';

class SystemUIWrapper extends StatefulWidget {
  final Widget child;

  const SystemUIWrapper({
    super.key,
    required this.child,
  });

  @override
  State<SystemUIWrapper> createState() => _SystemUIWrapperState();
}

class _SystemUIWrapperState extends State<SystemUIWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateSystemUI();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _updateSystemUI();
  }

  void _updateSystemUI() {
    final brightness = WidgetsBinding.instance.window.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    SystemUIHelper.setSystemUIOverlayStyle(isDarkMode: isDarkMode);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
