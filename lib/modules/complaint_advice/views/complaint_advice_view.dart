import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../data/providers/profile_provider.dart';
import '../../../../data/repositories/profile_repository.dart';

class ComplaintAdviceView extends StatefulWidget {
  const ComplaintAdviceView({super.key});

  @override
  State<ComplaintAdviceView> createState() => _ComplaintAdviceViewState();
}

class _ComplaintAdviceViewState extends State<ComplaintAdviceView> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isLoading = false;
  bool _isPrefilling = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      // 1. Try fast local storage phone
      if (Get.isRegistered<StorageService>()) {
        final storage = Get.find<StorageService>();
        if (storage.userPhone != null && storage.userPhone!.isNotEmpty) {
          _phoneController.text = storage.userPhone!;
        }
      }

      // 2. Fetch fresh profile details to auto-fill name, phone, address
      final profileProvider = Get.isRegistered<ProfileProvider>()
          ? Get.find<ProfileProvider>()
          : Get.put(ProfileProvider());
      final profileRepo = Get.isRegistered<ProfileRepository>()
          ? Get.find<ProfileRepository>()
          : Get.put(ProfileRepository(provider: profileProvider));

      final profile = await profileRepo.getProfile();
      if (profile != null && mounted) {
        if (_nameController.text.trim().isEmpty && profile.name.isNotEmpty) {
          _nameController.text = profile.name;
        }
        if (_phoneController.text.trim().isEmpty && profile.phone != null) {
          _phoneController.text = profile.phone!;
        }
        if (_addressController.text.trim().isEmpty) {
          final addressParts = [profile.upazila, profile.district, profile.division]
              .where((p) => p != null && p.trim().isNotEmpty)
              .join(', ');
          if (addressParts.isNotEmpty) {
            _addressController.text = addressParts;
          }
        }
      }
    } catch (e) {
      debugPrint("Error prefilling user data: $e");
    } finally {
      if (mounted) {
        setState(() => _isPrefilling = false);
      }
    }
  }

  void _submitFeedback() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim(); // optional
    final message = _messageController.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'সতর্কতা',
        'অনুগ্রহ করে আপনার নাম লিখুন',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (phone.isEmpty) {
      Get.snackbar(
        'সতর্কতা',
        'অনুগ্রহ করে আপনার মোবাইল নম্বর লিখুন',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (message.isEmpty) {
      Get.snackbar(
        'সতর্কতা',
        'অনুগ্রহ করে আপনার অভিযোগ বা পরামর্শ লিখুন',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulate network delay / submit
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
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
                'আপনার মতামত আমরা গ্রহণ করেছি।\nআমাদের সেবার মান উন্নয়নে আপনার অভিযোগ ও পরামর্শ অত্যন্ত গুরুত্বপূর্ণ। আমাদের টিম দ্রুত এটি পর্যালোচনা করবে।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),

              // Action Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.back(); // return to home
                  },
                  child: const Text(
                    'ঠিক আছে',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: _isPrefilling
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'আমরা আপনার মতামতকে গুরুত্ব দিই। অ্যাপের যেকোনো সমস্যা, অভিযোগ বা সেবার মান বাড়াতে আপনার পরামর্শ জানান।',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 12,
                              color: Color(0xFF334155),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Name Field
                  _buildLabel('আপনার নাম'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _nameController,
                    hintText: 'নাম লিখুন',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 14),

                  // Phone Field
                  _buildLabel('মোবাইল নম্বর'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'e.g. 017XXXXXXXX',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),

                  // Address Field (Optional)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('ঠিকানা'),
                      const Text(
                        '(ঐচ্ছিক / Optional)',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _addressController,
                    hintText: 'আপনার এলাকা বা পূর্ণ ঠিকানা',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 14),

                  // Message / Complaint Box
                  _buildLabel('আপনার অভিযোগ বা পরামর্শ'),
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
                      controller: _messageController,
                      minLines: 5,
                      maxLines: 7,
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
                      onPressed: _isLoading ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
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
            ),
    );
  }

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
}

