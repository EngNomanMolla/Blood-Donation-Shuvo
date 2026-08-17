import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:blood_donation/app/routes/app_routes.dart';
import '../controllers/more_controller.dart';

class MoreView extends GetView<MoreController> {
  const MoreView({super.key});

  // Theme colors - Re-curated for premium feel
  static const Color primaryPink = Color(0xFFE91E8C);
  static const Color darkPink = Color(0xFFAD1457);
  static const Color accentPurple = Color(0xFF673AB7);
  static const Color glassWhite = Color(0x33FFFFFF);
  static const Color white = Colors.white;

  @override
  Widget build(BuildContext context) {
    Get.put(MoreController());

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          SliverToBoxAdapter(child: _buildStatsCard()),
          SliverToBoxAdapter(child: _buildActionCards()),
          SliverToBoxAdapter(child: _buildMenuList()),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          // 1. Premium Gradient Background with Blobs
          Container(
            height: 150,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryPink, darkPink],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: 20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.purple.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Header Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'My Profile',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                // Gap to position the card halfway
                const SizedBox(height: 24),

                // 3. Glassmorphism Profile Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Profile Image with Glow
                            GestureDetector(
                              onTap: controller.changeProfileImage,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primaryPink.withValues(alpha: 0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Obx(() {
                                      final avatar = controller.avatarUrl.value;
                                      if (avatar.isNotEmpty) {
                                        return CircleAvatar(
                                          radius: 36,
                                          backgroundImage: NetworkImage(avatar),
                                        );
                                      } else {
                                        return CircleAvatar(
                                          radius: 36,
                                          backgroundColor: Colors.grey.shade200,
                                          child: Icon(
                                            Icons.person_rounded,
                                            size: 38,
                                            color: Colors.grey.shade600,
                                          ),
                                        );
                                      }
                                    }),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: primaryPink,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_rounded,
                                        size: 14,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                             const SizedBox(height: 12),
                             Obx(() {
                               if (controller.isLoading.value && controller.name.value.isEmpty) {
                                 return const Text('Loading...');
                               }
                               if (controller.name.value.isEmpty) {
                                 return const SizedBox.shrink();
                               }
                               return Column(
                                 children: [
                                   Text(
                                     controller.name.value,
                                     style: const TextStyle(
                                       fontFamily: 'Poppins',
                                       fontSize: 20,
                                       fontWeight: FontWeight.bold,
                                       color: Color(0xFF1A1A1A),
                                       letterSpacing: 0.2,
                                     ),
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis,
                                     textAlign: TextAlign.center,
                                   ),
                                   const SizedBox(height: 4),
                                 ],
                               );
                             }),
                             Obx(() {
                               if (controller.isLoading.value && controller.email.value.isEmpty) {
                                 return const Text('...');
                               }
                               if (controller.email.value.isEmpty) {
                                 return const SizedBox.shrink();
                               }
                               return Column(
                                 children: [
                                   Text(
                                     controller.email.value,
                                     style: TextStyle(
                                       fontFamily: 'Poppins',
                                       fontSize: 13,
                                       color: Colors.grey[700],
                                       fontWeight: FontWeight.w400,
                                     ),
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis,
                                     textAlign: TextAlign.center,
                                   ),
                                   const SizedBox(height: 4),
                                 ],
                               );
                             }),
                             Obx(() {
                               if (controller.isLoading.value && controller.phone.value.isEmpty) {
                                 return const Text('...');
                               }
                               return Text(
                                 controller.phone.value.isNotEmpty
                                     ? controller.phone.value
                                     : 'N/A',
                                 style: TextStyle(
                                   fontFamily: 'Poppins',
                                   fontSize: 13,
                                   color: Colors.grey[600],
                                   fontWeight: FontWeight.w500,
                                 ),
                                 maxLines: 1,
                                 overflow: TextOverflow.ellipsis,
                                 textAlign: TextAlign.center,
                               );
                             }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatsCard() {
    return Obx(() {
      final bloodGroup = controller.bloodGroup.value.isNotEmpty
          ? controller.bloodGroup.value
          : 'N/A';
      final donations = controller.donationsCount.value.toString().padLeft(2, '0');
      final livesSaved = controller.livesSavedCount.value.toString().padLeft(2, '0');

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _buildStatTile(
              bloodGroup,
              'Type',
              Icons.bloodtype_outlined,
              const Color(0xFFFDECF4), // Soft Pink
              primaryPink,
            ),
            const SizedBox(width: 12),
            _buildStatTile(
              donations,
              'Donations',
              Icons.favorite_outline_rounded,
              const Color(0xFFE8EAF6), // Soft Indigo
              const Color(0xFF3F51B5),
            ),
            const SizedBox(width: 12),
            _buildStatTile(
              livesSaved,
              'Lives Saved',
              Icons.auto_awesome_rounded,
              const Color(0xFFE8F5E9), // Soft Green
              const Color(0xFF4CAF50),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatTile(
    String value,
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCards() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Join Our Community',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final isDonor = controller.isDonor.value;
            final isVolunteer = controller.isVolunteer.value;
            return Row(
              children: [
                Expanded(
                  child: _buildSmartCard(
                    title: 'Become A\nDonor',
                    doneTitle: 'Donor\nDashboard',
                    quickTitle: 'Become A\nDonor',
                    icon: Icons.water_drop_rounded,
                    mainColor: primaryPink,
                    accentColor: const Color(0xFFFF5C8D),
                    isAlready: isDonor,
                    hasExistingData: isVolunteer && !isDonor,
                    onTap: controller.handleBecomeDonor,
                    onAlreadyTap: () => Get.toNamed(AppRoutes.donorDashboard),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSmartCard(
                    title: 'Become A\nVolunteer',
                    doneTitle: 'Volunteer\nDashboard',
                    quickTitle: 'Become A\nVolunteer',
                    icon: Icons.volunteer_activism_rounded,
                    mainColor: accentPurple,
                    accentColor: const Color(0xFF9575CD),
                    isAlready: isVolunteer,
                    hasExistingData: isDonor && !isVolunteer,
                    onTap: controller.handleBecomeVolunteer,
                    onAlreadyTap: () => Get.toNamed(AppRoutes.volunteerDashboard),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  /// Smart card that renders one of 3 states:
  /// [isAlready] = true  -> Opens Dashboard
  /// [hasExistingData] = true -> Quick Register mode (flash icon)
  /// else -> Normal "Become" card
  Widget _buildSmartCard({
    required String title,
    required String doneTitle,
    required String quickTitle,
    required IconData icon,
    required Color mainColor,
    required Color accentColor,
    required bool isAlready,
    required bool hasExistingData,
    required VoidCallback onTap,
    VoidCallback? onAlreadyTap,
  }) {
    const double cardHeight = 96;
    if (isAlready) {
      // ── Already registered — clickable card going to dashboard ──
      return GestureDetector(
        onTap: onAlreadyTap,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(color: mainColor.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: mainColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: mainColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: mainColor, size: 18),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          doneTitle,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: mainColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: mainColor, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ── Normal or Quick Register card ──
    final displayTitle = hasExistingData ? quickTitle : title;
    final displayIcon = hasExistingData ? Icons.flash_on_rounded : icon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, accentColor],
          ),
          boxShadow: [
            BoxShadow(
              color: mainColor.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -15,
                bottom: -15,
                child: Icon(icon, size: 70, color: white.withValues(alpha: 0.12)),
              ),
              if (hasExistingData)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Data ready!',
                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(displayIcon, color: white, size: 18),
                    ),
                    Text(
                      displayTitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        letterSpacing: 0.2,
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


  Widget _buildMenuList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Settings',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Obx(() => ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredMenuItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.5,
                indent: 64,
                endIndent: 20,
                color: Colors.grey[100],
              ),
              itemBuilder: (context, index) {
                return _buildMenuItem(controller.filteredMenuItems[index]);
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MoreMenuItem item) {
    return InkWell(
      onTap: () {
        if (item.title == 'Logout') {
          controller.logout();
        } else if (item.route != null) {
          Get.toNamed(item.route!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECF4), // Very soft pink
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: primaryPink, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  letterSpacing: 0.1,
                ),
              ),
            ),
            if (item.hasToggle)
              Obx(
                () => Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                    value: controller.isAvailable.value,
                    activeTrackColor: primaryPink,
                    onChanged: controller.toggleAvailability,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[300]!,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}




