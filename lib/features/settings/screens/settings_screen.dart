import 'package:flutter/cupertino.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import 'currency_selector_screen.dart';
import 'language_selector_screen.dart';
import 'package:lottie/lottie.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String currency = 'USD';
  String language = 'English';
  String theme = 'Dark';
  bool hapticsEnabled = true;
  String security = 'Fingerprint';
  bool notificationsEnabled = true;

  Future<void> _showThemeSelector() async {
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Theme'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => theme = 'Light');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.sun_max_fill,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Light'),
                if (theme == 'Light') ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => theme = 'Dark');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.moon_fill,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Dark'),
                if (theme == 'Dark') ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => theme = 'System');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.device_phone_portrait,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('System'),
                if (theme == 'System') ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _showSecuritySelector() async {
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Security Method'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => security = 'PIN');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.lock_circle,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('PIN'),
                if (security == 'PIN') ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => security = 'Fingerprint');
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.paintbrush,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Fingerprint'),
                if (security == 'Fingerprint') ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _showNotificationSelector() async {
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Notifications'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => notificationsEnabled = true);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.bell_fill,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('On'),
                if (notificationsEnabled) ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => notificationsEnabled = false);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.bell_slash_fill,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Off'),
                if (!notificationsEnabled) ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _showHapticsSelector() async {
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Haptics'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => hapticsEnabled = true);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.hand_raised_fill,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('On'),
                if (hapticsEnabled) ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => hapticsEnabled = false);
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.hand_raised_slash,
                  color: isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text('Off'),
                if (!hapticsEnabled) ...[
                  const SizedBox(width: 8),
                  Icon(
                    CupertinoIcons.checkmark_alt,
                    color: CupertinoColors.activeBlue,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 14),
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.label,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.systemGrey,
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor: isDarkMode 
            ? CupertinoColors.black 
            : CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Settings'),
          border: Border(
            bottom: BorderSide(
              color: isDarkMode 
                  ? CupertinoColors.systemGrey.withOpacity(0.5)
                  : CupertinoColors.systemGrey.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          backgroundColor: isDarkMode 
              ? CupertinoColors.black.withOpacity(0.8)
              : CupertinoColors.systemBackground.withOpacity(0.8),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            child: Column(
              children: [
                Center(
                  child: Lottie.asset(
                    'assets/animations/settings.json',
                    width: 200,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                // First Section
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: CupertinoIcons.money_dollar_circle,
                        title: 'Currency',
                        value: currency,
                        iconColor: CupertinoColors.systemGreen,
                        onTap: () async {
                          final result = await Navigator.push<String>(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const CurrencySelector(),
                            ),
                          );
                          if (result != null) {
                            setState(() => currency = result);
                          }
                        },
                      ),
                      _buildDivider(isDarkMode),
                      _buildSettingItem(
                        icon: CupertinoIcons.globe,
                        title: 'Language',
                        value: language,
                        iconColor: CupertinoColors.systemBlue,
                        onTap: () async {
                          final result = await Navigator.push<String>(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const LanguageSelector(),
                            ),
                          );
                          if (result != null) {
                            setState(() => language = result);
                          }
                        },
                      ),
                      _buildDivider(isDarkMode),
                      _buildSettingItem(
                        icon: CupertinoIcons.moon_stars,
                        title: 'Theme',
                        value: theme,
                        iconColor: CupertinoColors.systemIndigo,
                        onTap: _showThemeSelector,
                      ),
                      _buildDivider(isDarkMode),
                      _buildSettingItem(
                        icon: CupertinoIcons.hand_raised,
                        title: 'Haptics',
                        value: hapticsEnabled ? 'On' : 'Off',
                        iconColor: CupertinoColors.systemPurple,
                        onTap: _showHapticsSelector,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Second Section
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: CupertinoIcons.lock_shield,
                        title: 'Security',
                        value: security,
                        iconColor: CupertinoColors.systemRed,
                        onTap: _showSecuritySelector,
                      ),
                      _buildDivider(isDarkMode),
                      _buildSettingItem(
                        icon: CupertinoIcons.bell,
                        title: 'Notification',
                        value: notificationsEnabled ? 'On' : 'Off',
                        iconColor: CupertinoColors.systemOrange,
                        onTap: _showNotificationSelector,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Third Section
                Container(
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        icon: CupertinoIcons.info_circle,
                        title: 'About',
                        value: '',
                        iconColor: CupertinoColors.systemGrey,
                        onTap: () {},
                      ),
                      _buildDivider(isDarkMode),
                      _buildSettingItem(
                        icon: CupertinoIcons.question_circle,
                        title: 'Help',
                        value: '',
                        iconColor: CupertinoColors.systemGrey,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 0.5,
      color: isDarkMode 
          ? CupertinoColors.systemGrey.withOpacity(0.3)
          : CupertinoColors.systemGrey.withOpacity(0.2),
    );
  }
} 