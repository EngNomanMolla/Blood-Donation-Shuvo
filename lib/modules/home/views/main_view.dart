import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/modules/home/views/home_view.dart';
import 'package:blood_donation/modules/wallet/views/wallet_view.dart';
import 'package:blood_donation/modules/more/views/more_view.dart';
import 'package:blood_donation/modules/home/widgets/bottom_nav_bar.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  final List<Widget> pages = [
    const HomeView(),
    WalletView(),
    const MoreView(),
  ];

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MainController());

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Main Content
          Obx(() => IndexedStack(
                index: controller.currentIndex.value,
                children: controller.pages,
              )),
          
          // Floating Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Obx(() => BottomNavBar(
                  selectedIndex: controller.currentIndex.value,
                  onTap: controller.changePage,
                )),
          ),
        ],
      ),
    );
  }
}
