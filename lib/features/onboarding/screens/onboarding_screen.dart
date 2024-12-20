import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spendwise/features/onboarding/models/onboarding_item.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/widgets/system_ui_wrapper.dart';
import '../../../core/widgets/haptic_feedback_wrapper.dart';
import '../../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      CupertinoPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  Color _getCircleColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFF5A623); // Yellow for first screen
      case 1:
        return const Color(0xFF4A90E2); // Blue for second screen
      case 2:
        return const Color(0xFF9B59B6); // Purple for third screen
      default:
        return CupertinoColors.activeBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SystemUIWrapper(
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemBackground,
        child: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 16),
                    HapticFeedbackWrapper(
                      onPressed: () {
                        _completeOnboarding();
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onHorizontalDragEnd: (DragEndDetails details) {
                          if (details.primaryVelocity! > 0 &&
                              _currentPage > 0) {
                            // Swipe right - go to previous page
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else if (details.primaryVelocity! < 0 &&
                              _currentPage < onboardingItems.length - 1) {
                            // Swipe left - go to next page
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: onboardingItems.length,
                          itemBuilder: (context, index) {
                            return _OnboardingPage(
                                item: onboardingItems[index]);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 50,
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: CircularProgressIndicator(
                        value: (_currentPage + 1) / onboardingItems.length,
                        backgroundColor:
                            CupertinoColors.systemGrey.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getCircleColor(_currentPage),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    HapticFeedbackWrapper(
                      onPressed: () {
                        if (_currentPage < onboardingItems.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getCircleColor(_currentPage),
                        ),
                        child: Icon(
                          CupertinoIcons.arrow_right,
                          color: CupertinoColors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const _OnboardingPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(32),
              child: SvgPicture.asset(
                item.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              fontFamily: '.SF Pro Text',
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: CupertinoColors.systemGrey,
              fontFamily: '.SF Pro Text',
            ),
          ),
        ],
      ),
    );
  }
}
