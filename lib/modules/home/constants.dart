/// Constants for the Home module
class HomeConstants {
  HomeConstants._();

  // Banner configuration
  static const int bannerAutoScrollDuration = 3;
  static const int bannerAnimationDuration = 400;
  static const double bannerHeight = 170;
  static const double bannerBorderRadius = 20;

  // Balance display
  static const int balanceDisplayDuration = 3;
  static const String balanceCurrency = "৳";
  static const String balanceValue = "12,500";
  static const String balancePlaceholder = "Tap Balance";

  // Blood types
  static const List<String> bloodTypes = ['O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+'];

  // UI dimensions
  static const double headerPadding = 16;
  static const double headerVerticalPadding = 10;
  static const double sectionVerticalSpacing = 20;
  static const double componentBorderRadius = 20;
  static const double smallBorderRadius = 14;

  // Blood card
  static const double bloodCardBorderRadius = 16;

  // Quick actions
  static const int quickActionsGridColumns = 2;
  static const double quickActionAspectRatio = 2.4;

  // Animation durations
  static const Duration notificationPanelDuration = Duration(milliseconds: 350);
  static const Duration containerAnimationDuration = Duration(milliseconds: 300);
  static const Duration dotsAnimationDuration = Duration(milliseconds: 300);

  // Avatar
  static const double avatarRadius = 22;
  static const String avatarUrl = "https://i.pravatar.cc/300";

  // Donor banner
  static const double donorBannerHeight = 90;

  // Indicator dots
  static const double indicatorSize = 8;
  static const double selectedIndicatorWidth = 18;
  static const double indicatorSpacing = 4;
}
