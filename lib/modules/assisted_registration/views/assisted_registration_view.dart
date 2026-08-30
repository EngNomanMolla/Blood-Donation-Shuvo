import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/assisted_registration_controller.dart';

class AssistedRegistrationView extends GetView<AssistedRegistrationController> {
  const AssistedRegistrationView({super.key});

  static const _primaryRed = Color(0xFFE53935);
  static const _darkRed = Color(0xFFB71C1C);
  static const _bgLight = Color(0xFFFFF5F5);
  static const _hintGray = Color(0xFFAAAAAA);
  static const _labelColor = Color(0xFF333333);
  static const _borderColor = Color(0xFFEEEEEE);

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
                      'Assisted Registration',
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
                  // Verification Section (First as requested)
                  _label('Donor Mobile Number'),
                  Row(
                    children: [
                      Expanded(
                        child: _textField(
                          controller: controller.mobileController,
                          hint: 'Type Number',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(() => ElevatedButton(
                        onPressed: controller.isSendingCode.value ? null : controller.onSendCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isSendingCode.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  _label('Verification Code'),
                  _textField(
                    controller: controller.verificationCodeController,
                    hint: 'Code',
                    keyboardType: TextInputType.number,
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Divider(color: _borderColor, thickness: 1.5),
                  ),

                  // Donor Details Section
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
                      hint: 'Select Gender',
                      items: controller.genderOptions,
                      onChanged: (v) => controller.selectedGender.value = v ?? '',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Blood Group
                  _label('Blood Group'),
                  Obx(
                    () => _dropdown(
                      value: controller.selectedBloodGroup.value.isEmpty
                          ? null
                          : controller.selectedBloodGroup.value,
                      hint: 'Select Blood Group',
                      items: controller.bloodGroupOptions,
                      onChanged: (v) => controller.selectedBloodGroup.value = v ?? '',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Address
                  _label('Address Details'),
                  Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: _compactDropdown(
                            value: controller.divisions.contains(controller.selectedDivision.value)
                                ? controller.selectedDivision.value
                                : null,
                            hint: controller.isDivisionsLoading.value ? 'Loading...' : 'Division',
                            items: controller.divisions,
                            onChanged: (v) =>
                                controller.selectedDivision.value = v ?? '',
                            isDisabled: controller.isDivisionsLoading.value,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _compactDropdown(
                            value: controller.districts.contains(controller.selectedDistrict.value)
                                ? controller.selectedDistrict.value
                                : null,
                            hint: controller.isDistrictsLoading.value ? 'Loading...' : 'District',
                            items: controller.districts,
                            onChanged: (v) =>
                                controller.selectedDistrict.value = v ?? '',
                            isDisabled: controller.selectedDivision.value.isEmpty || controller.isDistrictsLoading.value,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _compactDropdown(
                            value: controller.upazilas.contains(controller.selectedUpazila.value)
                                ? controller.selectedUpazila.value
                                : null,
                            hint: controller.isUpazilasLoading.value ? 'Loading...' : 'Upazila',
                            items: controller.upazilas,
                            onChanged: (v) =>
                                controller.selectedUpazila.value = v ?? '',
                            isDisabled: controller.selectedDistrict.value.isEmpty || controller.isUpazilasLoading.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email
                  _label('Email Address'),
                  _textField(
                    controller: controller.emailController,
                    hint: 'example@gmail.com',
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
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: _primaryRed,
                            ),
                          ),
                        ),
                      );
                    },
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
                        onPressed: controller.isRegistering.value ? null : controller.onRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isRegistering.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Registration Complete',
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
      style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: _labelColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: _hintGray),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
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
    bool isDisabled = false,
  }) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10),
    decoration: BoxDecoration(
      color: isDisabled ? Colors.grey.shade100 : Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: isDisabled ? Border.all(color: Colors.grey.shade200) : null,
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: isDisabled ? null : value,
        hint: Text(
          hint,
          style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: isDisabled ? Colors.grey.shade400 : _hintGray),
          overflow: TextOverflow.ellipsis,
        ),
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: isDisabled ? Colors.grey.shade400 : _hintGray, size: 18),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        style: TextStyle(fontFamily: 'Poppins', fontSize: 11, color: isDisabled ? Colors.grey.shade400 : _labelColor),
        items: isDisabled
            ? null
            : items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
        onChanged: isDisabled ? null : onChanged,
      ),
    ),
  );
}
