import 'package:blood_donation/modules/donor/controllers/doner_registration_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DonerRegistrationView extends StatelessWidget {
  const DonerRegistrationView({super.key});
 
  static const _pink = Color(0xFFE8285A);
  static const _lightPink = Color(0xFFFFF0F3);
  static const _hintGray = Color(0xFFAAAAAA);
  static const _labelColor = Color(0xFF333333);
  static const _borderColor = Color(0xFFE0E0E0);
 
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RegistrationController());
 
    return Scaffold(
      backgroundColor: _lightPink,
      body: Column(
        children: [
          // ── App Bar ──
          Container(
            color: _pink,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 16,
              left: 12,
              right: 16,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 24),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      'Registration',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
 
          // ── Body ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full Name
                  _label('Full Name'),
                  _textField(
                    controller: ctrl.fullNameController,
                    hint: 'Nahid hasan',
                  ),
                  const SizedBox(height: 16),
 
                  // Gender
                  _label('Gender'),
                  Obx(() => _dropdown(
                        value: ctrl.selectedGender.value.isEmpty
                            ? null
                            : ctrl.selectedGender.value,
                        hint: 'select your Gender',
                        items: ctrl.genderOptions,
                        onChanged: (v) => ctrl.selectedGender.value = v ?? '',
                      )),
                  const SizedBox(height: 16),
 
                  // Mobile
                  _label('Active Mobile Number'),
                  _textField(
                    controller: ctrl.mobileController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
 
                  // Blood Group
                  _label('your Blood Group'),
                  Obx(() => _dropdown(
                        value: ctrl.selectedBloodGroup.value.isEmpty
                            ? null
                            : ctrl.selectedBloodGroup.value,
                        hint: 'select your blood group',
                        items: ctrl.bloodGroupOptions,
                        onChanged: (v) =>
                            ctrl.selectedBloodGroup.value = v ?? '',
                      )),
                  const SizedBox(height: 16),
 
                  // Address
                  _label('Your Adress'),
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: _compactDropdown(
                              value: ctrl.selectedDistrict.value.isEmpty
                                  ? null
                                  : ctrl.selectedDistrict.value,
                              hint: 'District',
                              items: ctrl.districtOptions,
                              onChanged: (v) =>
                                  ctrl.selectedDistrict.value = v ?? '',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _compactDropdown(
                              value: ctrl.selectedUpazila.value.isEmpty
                                  ? null
                                  : ctrl.selectedUpazila.value,
                              hint: 'Upazila',
                              items: ctrl.upazilaOptions,
                              onChanged: (v) =>
                                  ctrl.selectedUpazila.value = v ?? '',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _compactDropdown(
                              value: ctrl.selectedThana.value.isEmpty
                                  ? null
                                  : ctrl.selectedThana.value,
                              hint: 'Thana',
                              items: ctrl.thanaOptions,
                              onChanged: (v) =>
                                  ctrl.selectedThana.value = v ?? '',
                            ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 16),
 
                  // Email
                  _label('Your email'),
                  _textField(
                    controller: ctrl.emailController,
                    hint: 'example@gmail.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
 
                  // Date of Birth
                  _label('Date Of birth'),
                  Builder(builder: (ctx) {
                    return GestureDetector(
                      onTap: () => ctrl.pickDate(ctx),
                      child: AbsorbPointer(
                        child: _textField(
                          controller: ctrl.dobController,
                          hint: 'DD/MM/YYYY',
                          suffixIcon: const Icon(Icons.calendar_today_outlined,
                              size: 18, color: _hintGray),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
 
                  // Terms
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888888)),
                        children: [
                          const TextSpan(text: 'By continuing, you agree to\n'),
                          TextSpan(
                            text: 'Terms of Use',
                            style: const TextStyle(
                                color: _pink, fontWeight: FontWeight.w500),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: const TextStyle(
                                color: _pink, fontWeight: FontWeight.w500),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
 
                  // Register Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: ctrl.onRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Registration Complete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  // ── Helpers ──
 
  static Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500, color: _labelColor),
        ),
      );
 
  static Widget _textField({
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: _labelColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: _hintGray),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _pink, width: 1.5),
          ),
        ),
      );
 
  static Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint,
                style: const TextStyle(fontSize: 14, color: _hintGray)),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: _hintGray, size: 22),
            style: const TextStyle(fontSize: 14, color: _labelColor),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
 
  static Widget _compactDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            hint: Text(hint,
                style: const TextStyle(fontSize: 12, color: _hintGray),
                overflow: TextOverflow.ellipsis),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down,
                color: _hintGray, size: 18),
            style: const TextStyle(fontSize: 12, color: _labelColor),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
          ),
        ),
      );
}
 
