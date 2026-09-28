import 'package:blood_donation/app/routes/app_routes.dart';
import 'package:blood_donation/core/services/storage_service.dart';
import 'package:blood_donation/data/providers/profile_provider.dart';
import 'package:blood_donation/data/repositories/profile_repository.dart';
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
    return Obx(() => Row(
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
          isLoading: controller.isDivisionsLoading.value,
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
          isDisabled: controller.selectedDivision.value == 'Division',
          isLoading: controller.isDistrictsLoading.value,
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
          isDisabled: controller.selectedDistrict.value == 'District',
          isLoading: controller.isUpazilasLoading.value,
        ),
      ],
    ));
  }

  Widget _buildDropdown({
    required RxString selected,
    required String label,
    required VoidCallback onTap,
    bool isDisabled = false,
    bool isLoading = false,
  }) {
    final isSelected = selected.value != label;
    final actualText = isLoading ? 'Loading...' : selected.value;
    return Expanded(
      child: GestureDetector(
        onTap: (isDisabled || isLoading) ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: (isDisabled || isLoading) ? Colors.grey.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (isDisabled || isLoading)
                  ? Colors.grey.shade200
                  : (isSelected ? primaryRed : const Color(0xFFFFCDD5)),
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
                  actualText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: (isDisabled || isLoading)
                        ? Colors.grey.shade400
                        : (isSelected ? primaryRed : Colors.grey.shade600),
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: primaryRed,
                  ),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: (isDisabled || isLoading)
                      ? Colors.grey.shade400
                      : (isSelected ? primaryRed : Colors.grey.shade600),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
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
      onTap: () => _onDonorCardTapped(donor),
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
                  child: donor.imageUrl.isNotEmpty
                      ? Image.network(
                          donor.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: softPink,
                            child: const Icon(Icons.person, color: primaryRed, size: 28),
                          ),
                        )
                      : Container(
                          color: softPink,
                          child: const Icon(Icons.person, color: primaryRed, size: 28),
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

  Future<void> _onDonorCardTapped(Donor donor) async {
    final storage = Get.find<StorageService>();

    // 1. Fast path: check local storage status
    final isApprovedLocal = storage.hasRecharged || storage.initialRechargeStatus == 'approved';
    if (isApprovedLocal) {
      Get.toNamed(
        AppRoutes.donorDetails,
        arguments: {
          'donor': donor,
          'bloodType': _bloodType,
        },
      );
      return;
    }

    // 2. Fetch fresh profile status to be 100% accurate (e.g. if recently approved by admin)
    try {
      final profileProvider = Get.isRegistered<ProfileProvider>()
          ? Get.find<ProfileProvider>()
          : Get.put(ProfileProvider());
      final profileRepo = Get.isRegistered<ProfileRepository>()
          ? Get.find<ProfileRepository>()
          : Get.put(ProfileRepository(provider: profileProvider));

      final profile = await profileRepo.getProfile();
      if (profile != null) {
        await storage.setHasRecharged(profile.hasCompletedInitialRecharge);
        if (profile.initialRechargeStatus != null) {
          await storage.setInitialRechargeStatus(profile.initialRechargeStatus!);
        }

        if (profile.initialRechargeStatus == 'approved' || profile.hasCompletedInitialRecharge) {
          Get.toNamed(
            AppRoutes.donorDetails,
            arguments: {
              'donor': donor,
              'bloodType': _bloodType,
            },
          );
          return;
        }

        // Show membership & status modal
        _showMembershipStatusDialog(
          status: profile.initialRechargeStatus ?? 'initial',
          rejectReason: profile.initialRechargeRejectReason,
          amount: profile.initialRechargeAmount > 0 ? profile.initialRechargeAmount : 50.0,
        );
        return;
      }
    } catch (e) {
      debugPrint("Error checking membership on donor click: $e");
    }

    // 3. Fallback with storage status
    _showMembershipStatusDialog(
      status: storage.initialRechargeStatus ?? 'initial',
      amount: 50.0,
    );
  }

  void _showMembershipStatusDialog({
    required String status,
    String? rejectReason,
    double amount = 50.0,
  }) {
    final isPending = status == 'pending';
    final isRejected = status == 'rejected';

    Color themeColor;
    IconData icon;
    String statusTitle;
    String statusBadge;
    String message;
    String actionButtonText;

    if (isPending) {
      themeColor = const Color(0xFFF59E0B);
      icon = Icons.hourglass_top_rounded;
      statusTitle = 'ভেরিফিকেশন প্রক্রিয়াধীন';
      statusBadge = 'Pending Review';
      message = 'আপনার ৳${amount.toStringAsFixed(0)} মেম্বারশিপ রিচার্জ ভেরিফিকেশন অ্যাডমিন পর্যালোচনায় রয়েছে। অনুমোদন সম্পন্ন হলে আপনি ডোনারের সম্পূর্ণ প্রোফাইল ও নম্বর দেখতে পারবেন।';
      actionButtonText = 'ভেরিফিকেশন স্ট্যাটাস দেখুন';
    } else if (isRejected) {
      themeColor = const Color(0xFFEF4444);
      icon = Icons.cancel_outlined;
      statusTitle = 'রিচার্জ বাতিল হয়েছে';
      statusBadge = 'Rejected';
      message = 'আপনার পূর্ববর্তী রিচার্জ রিকোয়েস্টটি গৃহীত হয়নি${(rejectReason != null && rejectReason.isNotEmpty) ? ' (কারণ: $rejectReason)' : ''}। ডোনারের প্রোফাইল দেখতে পুনরায় রিচার্জ করুন।';
      actionButtonText = 'পুনরায় রিচার্জ করুন';
    } else {
      themeColor = primaryRed;
      icon = Icons.workspace_premium_rounded;
      statusTitle = 'মেম্বারশিপ প্রয়োজন';
      statusBadge = '৳${amount.toStringAsFixed(0)} এককালীন রিচার্জ';
      message = 'ডোনারের সম্পূর্ণ প্রোফাইল, ঠিকানা এবং সরাসরি ফোন নম্বর দেখতে আপনাকে মেম্বার হতে হবে। মাত্র ৳${amount.toStringAsFixed(0)} রিচার্জ করে মেম্বারশিপ সক্রিয় করুন।';
      actionButtonText = 'মেম্বার হতে রিচার্জ করুন (৳${amount.toStringAsFixed(0)})';
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Header
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1.5),
                ),
                child: Icon(icon, color: themeColor, size: 34),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                statusTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: themeColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusBadge,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Message Body
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.toNamed(AppRoutes.initialRecharge);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          actionButtonText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Dismiss / Cancel Button
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'বন্ধ করুন / পরে দেখবো',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
