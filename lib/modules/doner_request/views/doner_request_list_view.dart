import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/modules/doner_request/controllers/doner_request_controller.dart';
import 'package:blood_donation/modules/doner_request/models/doner_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class DonateScreen extends StatelessWidget {
  DonateScreen({super.key});
 
  final DonateController controller = Get.put(DonateController());
 
  static const Color primaryRed = Color(0xFFE8194B);
  static const Color lightPink = Color(0xFFFFF0F3);
  static const Color softPink = Color(0xFFFFE4EA);
 
  /// Get blood type from route arguments
  String get _bloodType => Get.arguments?['bloodType'] ?? 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildFilterRow(),
                    const SizedBox(height: 16),
                    _buildDonorList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  // ── Header ────────────────────────────────────────────────────────────────
 
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE8194B), Color(0xFFFF5B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
 
              // Title
              const Expanded(
                child: Text(
                  'Doners',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),

              // Empty space (where notification icon was)
              const SizedBox(width: 36),
            ],
          ),
        ),
      ),
    );
  }
 
  // ── Search Bar ────────────────────────────────────────────────────────────
 
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) => controller.searchQuery.value = v,
        style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
        decoration: InputDecoration(
          hintText: 'Search',
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
 
  // ── Filter Row ────────────────────────────────────────────────────────────
 
  Widget _buildFilterRow() {
    return Row(
      children: [
        _buildDropdown(controller.selectedDistrict),
        const SizedBox(width: 8),
        _buildDropdown(controller.selectedUpazila),
        const SizedBox(width: 8),
        _buildDropdown(controller.selectedThana),
      ],
    );
  }
 
  Widget _buildDropdown(RxString selected) {
    return Expanded(
      child: Obx(() => GestureDetector(
            onTap: () {},
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFCDD5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selected.value,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryRed,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: primaryRed,
                    size: 18,
                  ),
                ],
              ),
            ),
          )),
    );
  }
 
  // ── Donor List ────────────────────────────────────────────────────────────
 
  Widget _buildDonorList() {
    return Obx(() {
      final donors = controller.filteredDonors;
      return Column(
        children: donors
            .asMap()
            .entries
            .map((e) => _buildDonorCard(e.value, e.key))
            .toList(),
      );
    });
  }
 
  Widget _buildDonorCard(Donor donor, int index) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.donorDetails,
          arguments: {
            'donor': donor,
            'bloodType': _bloodType,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: softPink, width: 2),
                ),
                child: ClipOval(
                child: Image.network(
                  donor.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: softPink,
                    child: const Icon(Icons.person, color: primaryRed),
                  ),
                ),
              ),
            ),
 
            const SizedBox(width: 12),
 
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donor.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${donor.age} Years | ${donor.gender}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12, color: primaryRed.withValues(alpha: 0.8)),
                      const SizedBox(width: 3),
                      Text(
                        donor.location,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
 
            // Blood drop icon
            _buildBloodDropIcon(),
          ],
        ),
      ),
      ),
    );
  }
 
  Widget _buildBloodDropIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8194B), Color(0xFFFF5B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryRed.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(height: 2),
          Text(
            _bloodType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
