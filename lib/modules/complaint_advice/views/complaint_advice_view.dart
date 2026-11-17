import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/app_colors.dart';
import '../controllers/complaint_advice_controller.dart';
import '../models/complaint_model.dart';

class ComplaintAdviceView extends StatelessWidget {
  const ComplaintAdviceView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<ComplaintAdviceController>()
        ? Get.find<ComplaintAdviceController>()
        : Get.put(ComplaintAdviceController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'অভিযোগ ও পরামর্শ',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: TabBar(
              controller: controller.tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3.5,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
              tabs: [
                const Tab(
                  iconMargin: EdgeInsets.only(bottom: 2),
                  icon: Icon(Icons.edit_note_rounded, size: 20),
                  text: 'নতুন অভিযোগ',
                ),
                Tab(
                  iconMargin: const EdgeInsets.only(bottom: 2),
                  icon: const Icon(Icons.track_changes_rounded, size: 20),
                  child: Obx(() {
                    final count = controller.complaints.length;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('অভিযোগের স্ট্যাটাস'),
                        if (count > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildFormTab(context, controller),
          _buildHistoryTab(context, controller),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: NEW COMPLAINT FORM
  // =========================================================================
  Widget _buildFormTab(BuildContext context, ComplaintAdviceController controller) {
    return Obx(() {
      if (controller.isPrefilling.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFF1F4),
                    Color(0xFFFFE8ED),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD1DC)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আপনার মতামত আমাদের অনুপ্রেরণা',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'সেবার মান উন্নয়ন বা যেকোনো অভিযোগ নির্ভয়ে আমাদের জানান। আপনার সকল তথ্য সুরক্ষিত থাকবে।',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form Title
            const Text(
              'অভিযোগ বা পরামর্শ ফর্ম',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 14),

            // 1. Name Field
            _buildLabel('আপনার নাম *'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: controller.nameController,
              hintText: 'উদা: মো: শুভ',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 14),

            // 2. Phone Field
            _buildLabel('মোবাইল নম্বর *'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: controller.phoneController,
              hintText: 'উদা: +88017XXXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            // 3. Address Field
            _buildLabel('বর্তমান ঠিকানা / অবস্থান (ঐচ্ছিক)'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: controller.addressController,
              hintText: 'উদা: ময়মনসিংহ সদর, ময়মনসিংহ',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 14),

            // 4. Message Field
            _buildLabel('অভিযোগ বা পরামর্শের বিবরণ *'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.messageController,
                maxLines: 5,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFF1E293B),
                ),
                decoration: const InputDecoration(
                  hintText: 'আপনার অভিযোগ, মতামত বা গঠনমূলক পরামর্শ এখানে বিস্তারিত লিখুন...',
                  hintStyle: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12.5,
                    color: Color(0xFF94A3B8),
                  ),
                  contentPadding: EdgeInsets.all(14),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value
                    ? null
                    : () async {
                        final success = await controller.submitComplaint();
                        if (success) {
                          _showSuccessDialog(controller);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'মতামত জমা দিন',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }

  void _showSuccessDialog(ComplaintAdviceController controller) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon Circle
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF10B981),
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title
              const Text(
                'ধন্যবাদ!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),

              // Message Body
              const Text(
                'আপনার মতামত আমরা সফলভাবে গ্রহণ করেছি।\nআমাদের টিম দ্রুত এটি পর্যালোচনা করবে। আপনি যেকোনো সময় "অভিযোগের স্ট্যাটাস" ট্যাব থেকে স্ট্যাটাস ট্র্যাক করতে পারেন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Get.back(); // close dialog
                      },
                      child: const Text(
                        'ঠিক আছে',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Get.back(); // close dialog
                        controller.tabController.animateTo(1); // switch to status tab
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.track_changes_rounded, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'স্ট্যাটাস দেখুন',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // =========================================================================
  // TAB 2: COMPLAINTS STATUS & HISTORY
  // =========================================================================
  Widget _buildHistoryTab(BuildContext context, ComplaintAdviceController controller) {
    return Column(
      children: [
        // Filter Chips Row
        _buildFilterBar(controller),

        // Complaints List View
        Expanded(
          child: Obx(() {
            if (controller.isLoadingHistory.value && controller.complaints.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final items = controller.filteredComplaints;

            if (items.isEmpty) {
              return _buildEmptyState(controller);
            }

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () => controller.fetchComplaints(refresh: true),
              child: ListView.separated(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                itemCount: items.length + (controller.isLoadingMore.value ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                      ),
                    );
                  }

                  final complaint = items[index];
                  return _buildComplaintCard(context, complaint);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterBar(ComplaintAdviceController controller) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Obx(() {
        final current = controller.selectedFilter.value;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip(
                label: 'সকল',
                count: controller.complaints.length,
                isSelected: current == 'all',
                onTap: () => controller.selectedFilter.value = 'all',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'অপেক্ষমাণ',
                count: controller.pendingCount,
                isSelected: current == 'pending',
                activeColor: const Color(0xFFD97706),
                onTap: () => controller.selectedFilter.value = 'pending',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'পর্যালোচনাধীন',
                count: controller.inReviewCount,
                isSelected: current == 'in_review',
                activeColor: const Color(0xFF2563EB),
                onTap: () => controller.selectedFilter.value = 'in_review',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'সমাধানকৃত',
                count: controller.resolvedCount,
                isSelected: current == 'resolved',
                activeColor: const Color(0xFF059669),
                onTap: () => controller.selectedFilter.value = 'resolved',
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                label: 'বাতিল',
                count: controller.rejectedCount,
                isSelected: current == 'rejected',
                activeColor: const Color(0xFFDC2626),
                onTap: () => controller.selectedFilter.value = 'rejected',
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    Color activeColor = AppColors.primary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, ComplaintItem complaint) {
    final statusTheme = _getStatusTheme(complaint.status, complaint.statusLabel);
    final hasAdminNote = complaint.adminNote != null && complaint.adminNote!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Complaint ID Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined, size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 5),
                      Text(
                        'আইডি: #${complaint.id}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusTheme.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusTheme.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusTheme.icon, size: 13, color: statusTheme.text),
                      const SizedBox(width: 5),
                      Text(
                        statusTheme.label,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: statusTheme.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Body Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date & Time
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 5),
                    Text(
                      _formatDateTime(complaint.createdAt),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // User's Complaint Message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.format_quote_rounded,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          complaint.message,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Color(0xFF1E293B),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Optional Address Row
                if (complaint.address != null && complaint.address!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          complaint.address!,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                // Admin Note Section (If Reviewed / Responded)
                if (hasAdminNote) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusTheme.bg.withValues(alpha: 0.5),
                          statusTheme.bg.withValues(alpha: 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: statusTheme.text.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.admin_panel_settings_rounded,
                                size: 14,
                                color: statusTheme.text,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'অ্যাডমিনের মতামত / মন্তব্য',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusTheme.text,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            complaint.adminNote!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12.5,
                              color: Color(0xFF1E293B),
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (complaint.reviewedAt != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.done_all_rounded, size: 12, color: Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                'পর্যালোচিত: ${_formatDateTime(complaint.reviewedAt)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else if (complaint.status.toLowerCase() == 'pending') ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFEF3C7)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFD97706)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'আপনার অভিযোগটি পর্যালোচনা করা হচ্ছে, শীঘ্রই আপডেট পাবেন।',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ComplaintAdviceController controller) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.mark_chat_read_outlined,
                  size: 46,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'কোনো অভিযোগ পাওয়া যায়নি',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'আপনি এখনো কোনো অভিযোগ বা পরামর্শ জমা দেননি। সেবার মান বাড়াতে আপনার মতামত আমাদের অত্যন্ত জরুরি।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                controller.tabController.animateTo(0);
              },
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text(
                'নতুন অভিযোগ লিখুন',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Form Fields
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          color: Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          hintText: hintText,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Date Formatter
  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final day = local.day.toString().padLeft(2, '0');
    final month = months[local.month - 1];
    final year = local.year;

    final hour24 = local.hour;
    final hour12 = hour24 == 0 ? 12 : (hour24 > 12 ? hour24 - 12 : hour24);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';

    return '$day $month $year • $hour12:$minute $period';
  }

  _StatusTheme _getStatusTheme(String status, String defaultLabel) {
    switch (status.toLowerCase()) {
      case 'approved':
      case 'resolved':
        return const _StatusTheme(
          bg: Color(0xFFD1FAE5),
          border: Color(0xFFA7F3D0),
          text: Color(0xFF047857),
          icon: Icons.check_circle_rounded,
          label: 'সমাধানকৃত',
        );
      case 'in_review':
      case 'processing':
        return const _StatusTheme(
          bg: Color(0xFFDBEAFE),
          border: Color(0xFFBFDBFE),
          text: Color(0xFF1D4ED8),
          icon: Icons.manage_search_rounded,
          label: 'পর্যালোচনাধীন',
        );
      case 'rejected':
        return const _StatusTheme(
          bg: Color(0xFFFEE2E2),
          border: Color(0xFFFECACA),
          text: Color(0xFFB91C1C),
          icon: Icons.cancel_rounded,
          label: 'বাতিলকৃত',
        );
      case 'pending':
      default:
        return const _StatusTheme(
          bg: Color(0xFFFEF3C7),
          border: Color(0xFFFDE68A),
          text: Color(0xFFB45309),
          icon: Icons.schedule_rounded,
          label: 'অপেক্ষমাণ',
        );
    }
  }
}

class _StatusTheme {
  final Color bg;
  final Color border;
  final Color text;
  final IconData icon;
  final String label;

  const _StatusTheme({
    required this.bg,
    required this.border,
    required this.text,
    required this.icon,
    required this.label,
  });
}
