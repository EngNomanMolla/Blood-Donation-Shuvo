import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/initial_recharge_controller.dart';

class InitialRechargeView extends GetView<InitialRechargeController> {
  const InitialRechargeView({super.key});

  static const Color _primaryRed = Color(0xFFE8285A);
  static const Color _darkRed = Color(0xFF9E1B3B);
  static const Color _lightPink = Color(0xFFFFF0F3);
  static const Color _hintGray = Color(0xFFAAAAAA);
  static const Color _labelColor = Color(0xFF333333);
  static const Color _borderColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightPink,
      body: Stack(
        children: [
          // Background blobs
          _buildBackground(),

          Column(
            children: [
              // ── App Bar ──
              Container(
                color: _primaryRed,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  bottom: 16,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Activate Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout_rounded, color: Colors.white),
                      tooltip: 'Log Out',
                      onPressed: () async {
                        final storage = Get.find<StorageService>();
                        await storage.clearAuth();
                        Get.offAllNamed(AppRoutes.login);
                      },
                    ),
                  ],
                ),
              ),

              // ── Body ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome & instructions card
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),

                      // Select Payment Method
                      _label('Select Payment Method'),
                      _buildMethodSelector(),
                      const SizedBox(height: 20),

                      // Selected Method Details
                      Obx(() => _buildPaymentInstruction()),
                      const SizedBox(height: 20),

                      // Form Fields
                      _label('Recharge Amount (Min ৳ 1)'),
                      _buildTextField(
                        controller: controller.amountController,
                        hint: '50',
                        keyboardType: TextInputType.number,
                        prefixText: '৳ ',
                      ),
                      const SizedBox(height: 16),

                      _label('Sender Mobile Number'),
                      _buildTextField(
                        controller: controller.senderNumberController,
                        hint: '01XXXXXXXXX',
                        keyboardType: TextInputType.phone,
                        prefixIcon: const Icon(Icons.phone_iphone_rounded, color: _primaryRed, size: 20),
                      ),
                      const SizedBox(height: 16),

                      _label('Transaction ID'),
                      _buildTextField(
                        controller: controller.transactionIdController,
                        hint: 'TRX12345678',
                        prefixIcon: const Icon(Icons.receipt_long_rounded, color: _primaryRed, size: 20),
                      ),
                      const SizedBox(height: 16),

                      _label('Note (Optional)'),
                      _buildTextField(
                        controller: controller.noteController,
                        hint: 'Initial recharge payment',
                        prefixIcon: const Icon(Icons.note_alt_rounded, color: _primaryRed, size: 20),
                      ),
                      const SizedBox(height: 32),

                      // Action Button
                      Obx(() => _buildSubmitButton()),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primaryRed.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _darkRed.withValues(alpha: 0.04),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryRed, _darkRed],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryRed.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Wallet Activation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'To access the dashboard and request or donate blood, please complete a one-time activation recharge in your wallet. Send money to any of the numbers below and enter the payment details.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
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
        const SizedBox(width: 12),
        _buildMethodCard('nagad', 'Nagad', const Color(0xFFF7941D)),
        const SizedBox(width: 12),
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
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : _borderColor,
                width: 1.5,
              ),
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : _labelColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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
    String number = '';
    String instruction = '';

    if (method == 'bkash') {
      number = '01700-000000';
      instruction = 'Send Money (Personal)';
    } else if (method == 'nagad') {
      number = '01800-000000';
      instruction = 'Send Money (Personal)';
    } else {
      number = '01900-000000-0';
      instruction = 'Send Money (Personal)';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _lightPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline_rounded, color: _primaryRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: const TextStyle(
                    color: _labelColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: const TextStyle(
                    color: _primaryRed,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _labelColor,
        ),
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
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: _labelColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: _hintGray),
          prefixIcon: prefixIcon,
          prefixText: prefixText,
          prefixStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _primaryRed,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _borderColor, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _borderColor, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
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
      height: 54,
      child: ElevatedButton(
        onPressed: loading ? null : controller.onRecharge,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryRed,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryRed.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Complete Activation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
