// In your main app scaffold where the bottom navbar is defined
final showBottomNavbar = ref.watch(bottomNavbarVisibilityProvider);

return CupertinoPageScaffold(
  // ... other properties
  child: Stack(
    children: [
      // Your main content
      if (showBottomNavbar)  // Add this condition
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: YourBottomNavbarWidget(),
        ),
    ],
  ),
); 