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
    return Container(
      height: 313,
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
                        color: white.withOpacity(0.1),
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
                        color: Colors.purple.withOpacity(0.15),
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
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Profile Image with Glow
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: primaryPink.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 36,
                                    backgroundImage: NetworkImage(
                                      'https://i.pravatar.cc/300?u=nahid',
                                    ),
                                  ),
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
                            const SizedBox(height: 12),
                            const Text(
                              'Nahid Hasan',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'nahid.hasan@gmail.com',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: white, size: 22),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatTile(
            'O+',
            'Type',
            Icons.bloodtype_outlined,
            const Color(0xFFFDECF4), // Soft Pink
            primaryPink,
          ),
          const SizedBox(width: 12),
          _buildStatTile(
            '03',
            'Donor',
            Icons.favorite_outline_rounded,
            const Color(0xFFE8EAF6), // Soft Indigo
            const Color(0xFF3F51B5),
          ),
          const SizedBox(width: 12),
          _buildStatTile(
            '08',
            'Lives',
            Icons.auto_awesome_rounded,
            const Color(0xFFE8F5E9), // Soft Green
            const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
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
              color: Colors.black.withOpacity(0.04),
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
          Row(
            children: [
              Expanded(
                child: _buildAtmosphereCard(
                  title: 'Become A\nDonor',
                  icon: Icons.water_drop_rounded,
                  mainColor: primaryPink,
                  accentColor: const Color(0xFFFF5C8D),
                  onTap: () => Get.toNamed(AppRoutes.donor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAtmosphereCard(
                  title: 'Become A\nVolunteer',
                  icon: Icons.volunteer_activism_rounded,
                  mainColor: accentPurple,
                  accentColor: const Color(0xFF9575CD),
                  onTap: () => Get.toNamed(AppRoutes.volunteerRegistration),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtmosphereCard({
    required String title,
    required IconData icon,
    required Color mainColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 125,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [mainColor, accentColor],
          ),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Decorative background icon
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(icon, size: 100, color: white.withOpacity(0.12)),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: white, size: 24),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: white,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        height: 1.2,
                        letterSpacing: 0.3,
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
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.menuItems.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 0.5,
                indent: 64,
                endIndent: 20,
                color: Colors.grey[100],
              ),
              itemBuilder: (context, index) {
                return _buildMenuItem(controller.menuItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(MoreMenuItem item) {
    return InkWell(
      onTap: () {
        if (item.route != null) {
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
                    activeColor: primaryPink,
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




