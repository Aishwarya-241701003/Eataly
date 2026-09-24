class AppConstants {
  // App Name
  static const String appName = "Eataly";

  // Padding
  static const double screenPadding = 20;
  static const double cardPadding = 16;

  // Radius
  static const double radiusSmall = 12;
  static const double radiusMedium = 18;
  static const double radiusLarge = 24;
  static const double radiusXL = 30;

  // Icon Sizes
  static const double iconSmall = 18;
  static const double iconMedium = 24;
  static const double iconLarge = 32;

  // Animation
  static const Duration animationDuration =
      Duration(milliseconds: 250);

  // Pickup Slots
  static const List<String> pickupSlots = [
    "12:00 PM",
    "12:15 PM",
    "12:30 PM",
    "12:45 PM",
    "1:00 PM",
    "1:15 PM",
    "1:30 PM",
    "1:45 PM",
  ];

  // Categories
  static const List<String> categories = [
    "All",
    "Meals",
    "Snacks",
    "Pizza",
    "Drinks",
    "Desserts",
  ];
}
