import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/bottom_nav_bar.dart';
import 'providers/bottom_navbar_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final showBottomNavbar = ref.watch(bottomNavbarVisibilityProvider);

    return CupertinoApp(
      theme: CupertinoThemeData(
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
        primaryColor: CupertinoColors.systemPurple,
      ),
      home: CupertinoPageScaffold(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        child: Stack(
          children: [
            // Your main content goes here
            if (showBottomNavbar)
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: BottomNavBar(),
              ),
          ],
        ),
      ),
    );
  }
}