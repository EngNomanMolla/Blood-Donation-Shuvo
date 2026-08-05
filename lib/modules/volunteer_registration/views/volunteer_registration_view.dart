import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/volunteer_registration_controller.dart';

class VolunteerRegistrationView extends GetView<VolunteerRegistrationController> {
  const VolunteerRegistrationView({super.key});

  static const _primaryRed = Color(0xFFE53935);
  static const _darkRed = Color(0xFFB71C1C);
  static const _bgLight = Color(0xFFFFF5F5);
  static const _hintGray = Color(0xFFAAAAAA);
  static const _labelColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: Column(
        children: [
          // ── App Bar ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryRed, _darkRed],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 24,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Become a Volunteer',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ),

          // ── Body ──
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  _label('Full Name'),
                  _textField(
                    controller: controller.fullNameController,
                    hint: 'Nahid Hasan',
                  ),
                  const SizedBox(height: 20),

                  // Gender
                  _label('Gender'),
                  Obx(
                    () => _dropdown(
                      value: controller.selectedGender.value.isEmpty
                          ? null
                          : controller.selectedGender.value,
                      hint: 'Select your Gender',
                      items: controller.genderOptions,
                      onChanged: (v) => controller.selectedGender.value = v ?? '',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Mobile
                  _label('Active Mobile Number'),
                  _textField(
                    controller: controller.mobileController,
                    keyboardType: TextInputType.phone,
                    readOnly: true,
                  ),
                  const SizedBox(height: 20),

                  // Blood Group
                  _label('Your Blood Group'),
                  Obx(
                    () => _dropdown(
                      value: controller.selectedBloodGroup.value.isEmpty
                          ? null
                          : controller.selectedBloodGroup.value,
                      hint: 'Select your blood group',
                      items: controller.bloodGroupOptions,
                      onChanged: (v) => controller.selectedBloodGroup.value = v ?? '',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Address
                  _label('Your Address'),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _compactDropdown(
                            value: controller.selectedDistrict.value.isEmpty
                                ? null
                                : controller.selectedDistrict.value,
                            hint: 'District',
                            items: controller.districtOptions,
                            onChanged: (v) =>
                                controller.selectedDistrict.value = v ?? '',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _compactDropdown(
                            value: controller.selectedUpazila.value.isEmpty
                                ? null
                                : controller.selectedUpazila.value,
                            hint: 'Upazila',
                            items: controller.upazilaOptions,
                            onChanged: (v) =>
                                controller.selectedUpazila.value = v ?? '',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _compactDropdown(
                            value: controller.selectedThana.value.isEmpty
                                ? null
                                : controller.selectedThana.value,
                            hint: 'Thana',
                            items: controller.thanaOptions,
                            onChanged: (v) =>
                                controller.selectedThana.value = v ?? '',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  _label('Your Email'),
                  _textField(
                    controller: controller.emailController,
                    hint: 'nahid.hasan@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  // Date of Birth
                  _label('Date Of Birth'),
                  Builder(
                    builder: (ctx) {
                      return GestureDetector(
                        onTap: () => controller.pickDate(ctx),
                        child: AbsorbPointer(
                          child: _textField(
                            controller: controller.dobController,
                            hint: 'DD/MM/YYYY',
                            suffixIcon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 18,
                              color: _primaryRed,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Extra Feature: Dual Role Checkbox
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _primaryRed.withValues(alpha: 0.1)),
                    ),
                    child: Obx(() => CheckboxListTile(
                      value: controller.isAlsoDonor.value,
                      onChanged: controller.toggleAlsoDonor,
                      activeColor: _primaryRed,
                      contentPadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      title: const Text(
                        'Do you want to be a donor also?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _labelColor,
                        ),
                      ),
                      subtitle: Text(
                        'This will register you as both a volunteer and donor at the same time.',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    )),
                  ),

                  const SizedBox(height: 32),

                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_primaryRed, _darkRed],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _primaryRed.withValues(alpha: 0.35),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Complete Registration',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                      )),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _labelColor,
      ),
    ),
  );

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    bool readOnly = false,
  }) => Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: readOnly ? _hintGray : _labelColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: _hintGray),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primaryRed, width: 1.5),
        ),
      ),
    ),
  );

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: _hintGray),
        ),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _hintGray, size: 22),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: _labelColor),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );

  Widget _compactDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        hint: Text(
          hint,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: _hintGray),
          overflow: TextOverflow.ellipsis,
        ),
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _hintGray, size: 18),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: _labelColor),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}
