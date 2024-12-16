class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

final List<OnboardingItem> onboardingItems = [
  const OnboardingItem(
    title: 'Track Expenses',
    description: 'Keep track of your daily expenses and income with ease',
    imagePath: 'assets/images/track_expenses.svg',
  ),
  const OnboardingItem(
    title: 'Smart Budget',
    description: "Set budgets and get notifications when you're close to limits",
    imagePath: 'assets/images/budgeting.svg',
  ),
  const OnboardingItem(
    title: 'Get Insights',
    description: 'Get detailed insights about your spending habits',
    imagePath: 'assets/images/insights.svg',
  ),
]; 