import 'package:blood_donation/modules/doner_details/controllers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DonerDetailsView extends StatelessWidget {
  DonerDetailsView({super.key});

  final ProfileController controller = Get.put(ProfileController());

  static const Color primaryRed = Color(0xFFE8194B);
  static const Color lightPink = Color(0xFFFFF0F3);
  static const Color softPink = Color(0xFFFFDDE5);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPink,
      // ── Native AppBar — Flutter handles SafeArea automatically ──
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8194B), Color(0xFFFF6B8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildTopSection(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        _buildDonorProfileSection(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── Top: gradient strip + floating card + avatar ─────────────────────────

  Widget _buildTopSection() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Gradient continuation below appbar
        Container(
          height: 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8194B), Color(0xFFFF6B8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),

        // White card — top padding makes room for the avatar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 44, 16, 0),
          child: _buildProfileCard(),
        ),

        // Avatar — centred, straddles gradient and card
        Positioned(
          top: 8,
          child: _buildAvatar(),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Obx(
      () => Container(
        width: 82,
        height: 82,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.network(
            controller.user.value.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: softPink,
              child: const Icon(Icons.person, color: primaryRed, size: 36),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Obx(() {
      final user = controller.user.value;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.10),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildStatItem(user.bloodType, 'Blood Type', isBloodType: true),
                _buildDivider(),
                _buildStatItem('${user.donated}', 'Donated'),
                _buildDivider(),
                _buildStatItem('${user.liveSave}', 'Live Save'),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatItem(String value, String label,
      {bool isBloodType = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isBloodType
                  ? const Color(0xFFFFEEF1)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isBloodType ? primaryRed : const Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() =>
      Container(width: 1, height: 40, color: Colors.grey.shade200);

  // ── Donor Profile ─────────────────────────────────────────────────────────

  Widget _buildDonorProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donar Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        _buildDonorCard(),
      ],
    );
  }

  Widget _buildDonorCard() {
    return Obx(() {
      final donor = controller.donor.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.bloodtype,
                      color: primaryRed,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  donor.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 14),

            if (donor.age > 0) _buildDetailRow('${donor.age} Years  ${donor.gender}'),
            if (donor.hospital.isNotEmpty) _buildDetailRow(donor.hospital),
            if (donor.location.isNotEmpty) _buildDetailRow(donor.location),
            if (donor.date.isNotEmpty) _buildDetailRow(donor.date),
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: primaryRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Your Mobile Balance Is Not Sufficient',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final phone = controller.donor.value.phone;
                    if (phone.isNotEmpty) {
                      final url = Uri.parse('tel:$phone');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        'Call',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF555555),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: primaryRed, width: 1.8),
                    ),
                    child: const Center(
                      child: Text(
                        'Recharge',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: primaryRed,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
