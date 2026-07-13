import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/modules/doner_request/controllers/doner_request_controller.dart';
import 'package:blood_donation/modules/doner_request/models/doner_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';


class DonateScreen extends GetView<DonateController> {
  const DonateScreen({super.key});
 
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
              controller: controller.scrollController,
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

  Widget _buildFilterRow() {
    return Row(
      children: [
        _buildDropdown(
          selected: controller.selectedDivision,
          label: 'Division',
          onTap: () => _showLocationPicker(
            title: 'Select Division',
            items: controller.divisions,
            selectedValue: controller.selectedDivision,
            isLoading: controller.isDivisionsLoading,
            onSelect: (val) {
              controller.selectedDivision.value = val;
            },
          ),
        ),
        const SizedBox(width: 8),
        _buildDropdown(
          selected: controller.selectedDistrict,
          label: 'District',
          onTap: () {
            if (controller.selectedDivision.value == 'Division') {
              Get.snackbar('Alert', 'Please select a Division first',
                  backgroundColor: Colors.orangeAccent, colorText: Colors.white);
              return;
            }
            _showLocationPicker(
              title: 'Select District',
              items: controller.districts,
              selectedValue: controller.selectedDistrict,
              isLoading: controller.isDistrictsLoading,
              onSelect: (val) {
                controller.selectedDistrict.value = val;
              },
            );
          },
        ),
        const SizedBox(width: 8),
        _buildDropdown(
          selected: controller.selectedUpazila,
          label: 'Upazila',
          onTap: () {
            if (controller.selectedDistrict.value == 'District') {
              Get.snackbar('Alert', 'Please select a District first',
                  backgroundColor: Colors.orangeAccent, colorText: Colors.white);
              return;
            }
            _showLocationPicker(
              title: 'Select Upazila',
              items: controller.upazilas,
              selectedValue: controller.selectedUpazila,
              isLoading: controller.isUpazilasLoading,
              onSelect: (val) {
                controller.selectedUpazila.value = val;
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required RxString selected,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Obx(() {
        final isSelected = selected.value != label;
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? primaryRed : const Color(0xFFFFCDD5),
                width: 1.5,
              ),
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
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? primaryRed : Colors.grey.shade600,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isSelected ? primaryRed : Colors.grey.shade600,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showLocationPicker({
    required String title,
    required List<String> items,
    required RxString selectedValue,
    required RxBool isLoading,
    required Function(String) onSelect,
  }) {
    final searchTxt = ''.obs;
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  if (selectedValue.value != 'Division' && 
                      selectedValue.value != 'District' && 
                      selectedValue.value != 'Upazila')
                    TextButton(
                      onPressed: () {
                        onSelect(title.contains('Division') 
                            ? 'Division' 
                            : (title.contains('District') ? 'District' : 'Upazila'));
                        Get.back();
                      },
                      child: const Text('Reset', style: TextStyle(color: primaryRed)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  onChanged: (v) => searchTxt.value = v,
                  decoration: const InputDecoration(
                    hintText: 'Search locations...',
                    prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(() {
                if (isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: primaryRed));
                }
                
                final query = searchTxt.value.toLowerCase();
                final filtered = items.where((item) => item.toLowerCase().contains(query)).toList();
                
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No locations found', style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, index) {
                    final item = filtered[index];
                    final isChosen = item == selectedValue.value;
                    return ListTile(
                      onTap: () {
                        onSelect(item);
                        Get.back();
                      },
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isChosen ? FontWeight.w700 : FontWeight.w500,
                          color: isChosen ? primaryRed : const Color(0xFF1A1A2E),
                        ),
                      ),
                      trailing: isChosen ? const Icon(Icons.check_circle_rounded, color: primaryRed) : null,
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Donor List ────────────────────────────────────────────────────────────

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(
        5,
        (index) => _buildSingleShimmerItem(),
      ),
    );
  }

  Widget _buildSingleShimmerItem() {
    return Container(
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
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar placeholder
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Info placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 100,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Blood drop placeholder
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDonorList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerList();
      }
      
      final donors = controller.filteredDonors;
      if (donors.isEmpty) {
        return  Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'No donors found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }

      return Column(
        children: [
          ...donors
              .asMap()
              .entries
              .map((e) => _buildDonorCard(e.value, e.key)),
          if (controller.isLoadingMore.value)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _buildSingleShimmerItem(),
            ),
        ],
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${donor.age} Years | ${donor.gender}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      Expanded(
                        child: Text(
                          donor.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
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
