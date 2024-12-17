import 'package:flutter/cupertino.dart';
import '../../../core/widgets/system_ui_wrapper.dart';
import '../../../features/settings/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required Color iconBackground,
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
                color: iconBackground.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: iconBackground,
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
            const Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.systemGrey,
              size: 22,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemGrey5,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CupertinoColors.systemGrey4,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            CupertinoIcons.person_alt,
                            size: 40,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Iriana Saliha',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'iriana.saliha@example.com',
                              style: TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                
                // Account Section
                _buildProfileItem(
                  icon: CupertinoIcons.creditcard,
                  title: 'Account',
                  iconBackground: CupertinoColors.systemBlue,
                  onTap: () {},
                ),
                const SizedBox(height: 9),
                _buildProfileItem(
                  icon: CupertinoIcons.settings,
                  title: 'Settings',
                  iconBackground: CupertinoColors.systemGrey,
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 9),
                _buildProfileItem(
                  icon: CupertinoIcons.square_arrow_down,
                  title: 'Export Data',
                  iconBackground: CupertinoColors.systemPurple,
                  onTap: () {},
                ),
                
                const SizedBox(height: 22),
                
                // Additional Items
                _buildProfileItem(
                  icon: CupertinoIcons.tag,
                  title: 'Manage Category',
                  iconBackground: CupertinoColors.systemGreen,
                  onTap: () {},
                ),
                const SizedBox(height: 9),
                _buildProfileItem(
                  icon: CupertinoIcons.person_2,
                  title: 'Manage Payees',
                  iconBackground: CupertinoColors.systemOrange,
                  onTap: () {},
                ),
                const SizedBox(height: 9),
                _buildProfileItem(
                  icon: CupertinoIcons.money_dollar_circle,
                  title: 'Lend Management',
                  iconBackground: CupertinoColors.systemIndigo,
                  onTap: () {},
                ),
                
                const SizedBox(height: 22),
                
                // Logout Button with padding at the bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildProfileItem(
                      icon: CupertinoIcons.arrow_right_circle,
                      title: 'Logout',
                      iconBackground: CupertinoColors.systemRed,
                      onTap: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
