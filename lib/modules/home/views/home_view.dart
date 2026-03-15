import 'dart:async';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  bool showBalance = false;
  bool showNotification = false;

  Timer? balanceTimer;

  @override
  void dispose() {
    balanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [

            /// Main Screen
            Column(
              children: [
                _headerSection(),
                bannerSlider(),
              ],
            ),

            /// Notification Panel (Right Slide)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOut,
              top: 0,
              bottom: 0,
              right: showNotification ? 0 : -screenWidth,
              width: screenWidth,
              child: _notificationPanel(),
            ),
          ],
        ),
      ),
    );
  }

  /// HEADER
  Widget _headerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [

          /// Profile Image
          SizedBox(
            width: 60,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: .25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: .15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/300",
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// Balance Button
          Expanded(
            child: GestureDetector(
              onTap: () {

                setState(() {
                  showBalance = true;
                });

                /// cancel old timer
                balanceTimer?.cancel();

                /// auto hide after 5 seconds
                balanceTimer = Timer(const Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      showBalance = false;
                    });
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    // const Icon(
                    //   Icons.currency_exchange,
                    //   size: 16,
                    //   color: AppColors.white,
                    // ),
                    Text(
                       "৳",
                        style: AllStyles.subtitleTextStyle.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                      
                        ),
                      ),

                    const SizedBox(width: 6),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        showBalance ? "12,500" : "Tap Balance",
                        key: ValueKey(showBalance),
                        style: AllStyles.subtitleTextStyle.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          /// Notification Icon
          SizedBox(
            width: 50,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showNotification = true;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [

                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFF7D7E1),
                    child: Icon(Icons.notifications_none),
                  ),

                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// NOTIFICATION PANEL
  Widget _notificationPanel() {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [

          /// Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Text(
                  "Notifications",
                  style: AllStyles.headingTextStyle,
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      showNotification = false;
                    });
                  },
                  icon: const Icon(Icons.close),
                )
              ],
            ),
          ),

          const Divider(),

          /// Notification List
          Expanded(
            child: ListView(
              children: const [

                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text("Payment Received"),
                  subtitle: Text("You received ৳500"),
                ),

                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text("Cashback"),
                  subtitle: Text("You earned ৳20 cashback"),
                ),

                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text("Special Offer"),
                  subtitle: Text("Get discount on your next payment"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }




Widget bannerSlider() {

  final PageController controller = PageController();
  final List<String> images = [
    "https://picsum.photos/800/400?1",
    "https://picsum.photos/800/400?2",
    "https://picsum.photos/800/400?3",
  ];

  int currentIndex = 0;
  Timer? timer;

  return StatefulBuilder(
    builder: (context, setState) {

      timer ??= Timer.periodic(const Duration(seconds: 3), (t) {

        if (currentIndex < images.length - 1) {
          currentIndex++;
        } else {
          currentIndex = 0;
        }

        controller.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );

        setState(() {});
      });

      return Column(
        children: [

          /// Slider
          SizedBox(
            height: 170,
            child: PageView.builder(
              controller: controller,
              itemCount: images.length,
              onPageChanged: (index) {
                currentIndex = index;
                setState(() {});
              },
              itemBuilder: (context, index) {

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(images[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                );

              },
            ),
          ),

          const SizedBox(height: 10),

          /// Dot Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 8,
                width: currentIndex == index ? 18 : 8,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Colors.red
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              );

            }),
          )

        ],
      );
    },
  );
}
}