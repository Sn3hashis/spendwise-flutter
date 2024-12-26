import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, ThemeData, Brightness;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import 'package:lottie/lottie.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';

class LanguageSelector extends ConsumerWidget {
  final String selectedLanguage;
  
  const LanguageSelector({
    super.key,
    required this.selectedLanguage, 
  });

  static const List<(IconData, String, String, String)> languages = [
    (CupertinoIcons.globe, 'English', 'English (US)', '🇺🇸'),
    (CupertinoIcons.globe, 'Hindi', 'हिंदी', '🇮🇳'),
    (CupertinoIcons.globe, 'Spanish', 'Español', '🇪🇸'),
    (CupertinoIcons.globe, 'French', 'Français', '🇫🇷'),
    (CupertinoIcons.globe, 'German', 'Deutsch', '🇩🇪'),
    (CupertinoIcons.globe, 'Italian', 'Italiano', '🇮🇹'),
    (CupertinoIcons.globe, 'Portuguese', 'Português', '🇵🇹'),
    (CupertinoIcons.globe, 'Russian', 'Русский', '🇷🇺'),
    (CupertinoIcons.globe, 'Japanese', '日本語', '🇯🇵'),
    (CupertinoIcons.globe, 'Korean', '한국어', '🇰🇷'),
    (CupertinoIcons.globe, 'Chinese', '中文', '🇨🇳'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);

    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: isDarkMode ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          middle: const Text('Language'),
          border: null,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Theme(
                    data: ThemeData(
                      brightness: isDarkMode ? Brightness.dark : Brightness.light,
                    ),
                    child: Lottie.asset(
                      'assets/animations/language.json',
                      height: 200,
                      width: 200,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppTheme.cardDark : AppTheme.cardLight,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Select Language',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 400,
                      child: ListView.builder(
                        itemCount: languages.length,
                        itemBuilder: (context, index) {
                          final (_, language, nativeName, flag) = languages[index];
                          final isSelected = language == selectedLanguage;
                          return HapticFeedbackWrapper(
                            onPressed: () {
                              Navigator.pop(context, language);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    flag,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          language,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: isDarkMode 
                                                ? AppTheme.textPrimaryDark 
                                                : AppTheme.textPrimaryLight,
                                          ),
                                        ),
                                        Text(
                                          nativeName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDarkMode 
                                                ? AppTheme.textSecondaryDark 
                                                : AppTheme.textSecondaryLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      CupertinoIcons.checkmark_alt,
                                      color: CupertinoColors.systemBlue,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
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