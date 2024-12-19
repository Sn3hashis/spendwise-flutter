import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/pin_entry_screen.dart';
import 'features/auth/providers/user_provider.dart';
import 'features/auth/providers/pin_provider.dart';
import 'features/auth/providers/security_preferences_provider.dart';
import 'features/auth/screens/biometric_auth_screen.dart';
import 'features/main/screens/main_layout_screen.dart';
import 'firebase_options.dart';
import 'core/utils/system_ui_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('has_completed_onboarding') ?? false;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: MyApp(hasCompletedOnboarding: hasCompletedOnboarding),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  final bool hasCompletedOnboarding;
  
  const MyApp({
    required this.hasCompletedOnboarding,
    super.key,
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final user = ref.read(userProvider);
    if (user != null) {
      // Load security preferences first
      await ref.read(securityPreferencesProvider.notifier).loadPreferences();
      final securityMethod = ref.read(securityPreferencesProvider);
      
      // Always load PIN on startup (it will check local storage first)
      await ref.read(pinProvider.notifier).loadPin();
      
      // If PIN exists but biometric is selected, don't show PIN screen
      if (securityMethod == SecurityMethod.biometric) {
        debugPrint('Biometric authentication selected');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final user = ref.watch(userProvider);
    final securityMethod = ref.watch(securityPreferencesProvider);
    
    late Widget homeWidget;
    
    if (!widget.hasCompletedOnboarding) {
      homeWidget = const OnboardingScreen();
    } else if (user == null) {
      homeWidget = const LoginScreen();
    } else {
      switch (securityMethod) {
        case SecurityMethod.biometric:
          homeWidget = const BiometricAuthScreen();
        case SecurityMethod.pin:
          homeWidget = const PinEntryScreen(mode: PinEntryMode.verify);
      }
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
      ),
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: isDarkMode ? AppTheme.getDarkTheme() : AppTheme.getLightTheme(),
        home: homeWidget,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.title),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoButton.filled(
                onPressed: _incrementCounter,
                child: const Text('Increment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
