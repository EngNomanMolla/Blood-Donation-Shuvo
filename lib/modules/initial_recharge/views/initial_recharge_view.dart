import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/initial_recharge_controller.dart';

class InitialRechargeView extends GetView<InitialRechargeController> {
  const InitialRechargeView({super.key});

  static const Color _primaryRed = Color(0xFFE8285A);
  static const Color _darkRed = Color(0xFF9E1B3B);
  static const Color _hintGray = Color(0xFFAAAAAA);
  static const Color _labelColor = Color(0xFF2D2D2D);
  static const Color _borderColor = Color(0xFFE5E7EB);
  static const String _paymentNumber = '01717006474';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background decorative blobs
          _buildBackground(),

          Obx(() {
            if (controller.isLoading.value &&
                controller.rechargeStatus.value == 'initial') {
              return const Center(
                child: CircularProgressIndicator(color: _primaryRed),
              );
            }

            return Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: _buildBody(context),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_primaryRed, _darkRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33E8285A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          if (controller.isGeneralRecharge)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Get.back(),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.isGeneralRecharge
                    ? 'Recharge Wallet'
                    : 'Activate Wallet',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                controller.isGeneralRecharge
                    ? 'Add balance to your account'
                    : 'Complete one-time activation',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (!controller.isGeneralRecharge)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 20),
                tooltip: 'Log Out',
                onPressed: () async {
                  final storage = Get.find<StorageService>();
                  await storage.clearAuth();
                  Get.offAllNamed(AppRoutes.login);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (controller.rechargeStatus.value) {
      case 'pending':
        return _buildPendingScreen(context);
      case 'rejected':
        return _buildRejectedScreen(context);
      case 'initial':
      default:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Select Payment Method
              _label('Select Payment Method', icon: Icons.payment_rounded),
              _buildMethodSelector(),
              const SizedBox(height: 14),

              // Selected Method Details
              Obx(() => _buildPaymentInstruction()),
              const SizedBox(height: 18),

              // Quick Amount Suggestions
              _label('Recharge Amount', icon: Icons.monetization_on_outlined),
              _buildAmountSection(),
              const SizedBox(height: 16),

              _label('Sender Mobile Number', icon: Icons.phone_android_rounded),
              _buildTextField(
                controller: controller.senderNumberController,
                hint: '01XXXXXXXXX',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_iphone_rounded,
                    color: _primaryRed, size: 20),
              ),
              const SizedBox(height: 16),

              _label('Transaction ID (TrxID)', icon: Icons.receipt_long_rounded),
              _buildTextField(
                controller: controller.transactionIdController,
                hint: 'e.g. 9J58A4X7',
                prefixIcon: const Icon(Icons.pin_rounded,
                    color: _primaryRed, size: 20),
              ),
              const SizedBox(height: 16),

              _label('Note (Optional)', icon: Icons.edit_note_rounded),
              _buildTextField(
                controller: controller.noteController,
                hint: 'e.g. Wallet recharge payment',
                prefixIcon: const Icon(Icons.note_alt_outlined,
                    color: _primaryRed, size: 20),
              ),
              const SizedBox(height: 26),

              // Action Button
              Obx(() => _buildSubmitButton()),
              const SizedBox(height: 24),
            ],
          ),
        );
    }
  }

  Widget _buildAmountSection() {
    final quickAmounts = ['50', '100', '200', '500'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: controller.amountController,
          hint: '50',
          keyboardType: TextInputType.number,
          prefixText: '৳ ',
        ),
        const SizedBox(height: 8),
        Row(
          children: quickAmounts.map((amt) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () {
                    controller.amountController.text = amt;
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '৳$amt',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _primaryRed,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPendingScreen(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber.shade200, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Colors.amber,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Verification Pending',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your initial wallet activation recharge request of ৳${controller.rechargeAmount.value.toStringAsFixed(0)} is currently under review by our admin team.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Verification usually takes a few minutes. Please check status below or try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.fetchInitialRechargeStatus(
                        showFeedback: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                  shadowColor: _primaryRed.withValues(alpha: 0.3),
                ),
                icon: controller.isLoading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Check Verification Status',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () async {
                final storage = Get.find<StorageService>();
                await storage.clearAuth();
                Get.offAllNamed(AppRoutes.login);
              },
              icon:
                  const Icon(Icons.logout_rounded, color: Colors.grey, size: 18),
              label: const Text(
                'Log Out from Account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectedScreen(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.shade200, width: 2),
              ),
              child: const Icon(
                Icons.cancel_rounded,
                color: Colors.red,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Activation Rejected',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your initial wallet recharge verification has been rejected by the administrator.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            if (controller.rejectReason.value.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.red.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rejection Reason:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.rejectReason.value,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.rechargeStatus.value = 'initial';
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.edit_note_rounded, size: 20),
                label: const Text(
                  'Submit New Recharge Request',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () async {
                final storage = Get.find<StorageService>();
                await storage.clearAuth();
                Get.offAllNamed(AppRoutes.login);
              },
              icon:
                  const Icon(Icons.logout_rounded, color: Colors.grey, size: 18),
              label: const Text(
                'Log Out from Account',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryRed.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _darkRed.withValues(alpha: 0.03),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector() {
    return Row(
      children: [
        _buildMethodCard('bkash', 'bKash', const Color(0xFFE2125D)),
        const SizedBox(width: 8),
        _buildMethodCard('nagad', 'Nagad', const Color(0xFFF7941D)),
        const SizedBox(width: 8),
        _buildMethodCard('rocket', 'Rocket', const Color(0xFF8C3494)),
      ],
    );
  }

  Widget _buildMethodCard(String value, String label, Color color) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.selectedMethod.value == value;
        return GestureDetector(
          onTap: () => controller.selectMethod(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : _borderColor,
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isSelected ? Colors.white : _labelColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaymentInstruction() {
    final method = controller.selectedMethod.value;
    final Color methodColor = method == 'bkash'
        ? const Color(0xFFE2125D)
        : method == 'nagad'
            ? const Color(0xFFF7941D)
            : const Color(0xFF8C3494);

    final String methodName = method == 'bkash'
        ? 'bKash'
        : method == 'nagad'
            ? 'Nagad'
            : 'Rocket';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: methodColor.withValues(alpha: 0.25), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: methodColor.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top bar with Send Money title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.send_to_mobile_rounded,
                    color: methodColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$methodName Send Money',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: methodColor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Main Number Box
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: methodColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.phone_rounded,
                            color: methodColor, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Number',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey[500],
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1),
                            const Text(
                              _paymentNumber,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Color(0xFF1E293B),
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Compact Copy Icon Button
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                              const ClipboardData(text: _paymentNumber));
                          Get.snackbar(
                            'নম্বর কপি হয়েছে!',
                            '$_paymentNumber ক্লিপবোর্ডে কপি করা হয়েছে',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF1E293B),
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                            margin: const EdgeInsets.all(16),
                            borderRadius: 10,
                            icon: const Icon(Icons.check_circle_rounded,
                                color: Colors.greenAccent, size: 20),
                          );
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: methodColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.copy_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // 3 Steps Guide
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildStepRow(
                          '১', 'আপনার $methodName অ্যাপে গিয়ে Send Money করুন'),
                      const SizedBox(height: 5),
                      _buildStepRow('২', 'টাকা পাঠানোর পর প্রাপ্ত TrxID কপি করুন'),
                      const SizedBox(height: 5),
                      _buildStepRow('৩',
                          'নিচের ফর্মে TrxID ও আপনার নম্বর দিয়ে সাবমিট করুন'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(String stepNum, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFF64748B),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNum,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              color: Color(0xFF475569),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: _primaryRed),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _labelColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    Widget? prefixIcon,
    String? prefixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: _labelColor,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13.5,
            color: _hintGray,
          ),
          prefixIcon: prefixIcon,
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _primaryRed,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryRed, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final loading = controller.isLoading.value;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: loading ? null : controller.onRecharge,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryRed.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
          shadowColor: _primaryRed.withValues(alpha: 0.35),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    controller.isGeneralRecharge
                        ? 'Submit Recharge Request'
                        : 'Submit Activation Request',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
