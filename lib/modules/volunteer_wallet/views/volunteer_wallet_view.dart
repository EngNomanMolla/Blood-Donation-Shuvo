import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/volunteer_wallet_controller.dart';

class VolunteerWalletView extends GetView<VolunteerWalletController> {
  const VolunteerWalletView({super.key});

  static const Color primaryRed = Color(0xFFE53935);
  static const Color darkRed = Color(0xFFB71C1C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(115),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryRed, darkRed],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            boxShadow: [
              BoxShadow(
                color: primaryRed.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      _AppBarIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Get.back(),
                      ),
                      const Expanded(
                        child: Text(
                          'Volunteer Wallet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 44),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildBalanceCard(context),
            const SizedBox(height: 16),
            _buildTabSelector(),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.activeTab.value == 'transactions') {
                return _buildTransactionHistory();
              } else {
                return _buildWithdrawalHistory();
              }
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: primaryRed.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: primaryRed.withValues(alpha: 0.05), width: 1.5),
      ),
      child: Column(
        children: [
          // Current Balance Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        '৳${controller.walletBalance.value}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: darkRed,
                        ),
                      )),
                ],
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => _WithdrawBottomSheet(controller: controller),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [primaryRed, darkRed]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Withdraw',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Color(0xFFF1F1F1), height: 1, thickness: 1.5),
          ),
          
          // Stats Row
          Obx(() => Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  'Earnings',
                  controller.totalEarning.value,
                  Icons.arrow_downward_rounded,
                  Colors.green[600]!,
                ),
              ),
              Container(width: 1.5, height: 40, color: const Color(0xFFF1F1F1)),
              Expanded(
                child: _buildMiniStat(
                  'Withdrawals',
                  controller.totalWithdraw.value,
                  Icons.arrow_upward_rounded,
                  Colors.orange[700]!,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '৳$value',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transaction History',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              Icon(Icons.history_rounded, color: primaryRed.withValues(alpha: 0.5), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: primaryRed),
                ),
              );
            }
            if (controller.transactions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No transaction history found.',
                    style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final tx = controller.transactions[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.015),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: tx.statusColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          tx.type == 'Withdraw' ? Icons.account_balance_wallet_rounded : Icons.add_circle_rounded,
                          color: tx.statusColor.withValues(alpha: 0.9),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.type,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D2D2D),
                              ),
                            ),
                            Text(
                              'ID: ${tx.transactionId}',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${tx.isCredit ? '+' : '-'}৳${tx.amount}',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: tx.amountColor,
                            ),
                          ),
                          Text(
                            tx.formattedDate,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Obx(() {
        final active = controller.activeTab.value;
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.activeTab.value = 'transactions',
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: active == 'transactions' ? primaryRed : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: active == 'transactions'
                        ? [
                            BoxShadow(
                              color: primaryRed.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Transactions',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: active == 'transactions' ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.activeTab.value = 'withdrawals',
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: active == 'withdrawals' ? primaryRed : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: active == 'withdrawals'
                        ? [
                            BoxShadow(
                              color: primaryRed.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      'Withdrawals',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: active == 'withdrawals' ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildWithdrawalHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Withdrawal Requests',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              Icon(Icons.receipt_long_rounded, color: primaryRed.withValues(alpha: 0.5), size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isWithdrawalsLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: primaryRed),
                ),
              );
            }
            if (controller.withdrawals.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No withdrawal history found.',
                    style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.withdrawals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final wd = controller.withdrawals[index];
                Color statusBg;
                Color statusText;
                if (wd.status.toLowerCase() == 'pending') {
                  statusBg = const Color(0xFFFFF7ED);
                  statusText = const Color(0xFFC2410C);
                } else if (wd.status.toLowerCase() == 'approved' || wd.status.toLowerCase() == 'completed' || wd.status.toLowerCase() == 'successful') {
                  statusBg = const Color(0xFFF0FDF4);
                  statusText = const Color(0xFF15803D);
                } else {
                  statusBg = const Color(0xFFFEF2F2);
                  statusText = const Color(0xFFB91C1C);
                }

                Color brandColor = primaryRed;
                if (wd.method.toLowerCase() == 'bkash') {
                  brandColor = const Color(0xFFE2125D);
                } else if (wd.method.toLowerCase() == 'nagad') {
                  brandColor = const Color(0xFFF7941D);
                } else if (wd.method.toLowerCase() == 'rocket') {
                  brandColor = const Color(0xFF8C3494);
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.015),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: brandColor.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_rounded,
                              color: brandColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  wd.method.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  wd.accountNumber,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '৳${wd.amount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  wd.status.toUpperCase(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: statusText,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (wd.note != null && wd.note!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFF1F1F1), height: 1),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.notes_rounded, size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                wd.note!,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (wd.adminNote != null && wd.adminNote!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.feedback_outlined, size: 12, color: Colors.red[300]),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Admin: ${wd.adminNote!}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.red[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.access_time_rounded, size: 11, color: Colors.grey[400]),
                          const SizedBox(width: 4),
                          Text(
                            wd.formattedDate,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _WithdrawBottomSheet extends StatefulWidget {
  final VolunteerWalletController controller;

  const _WithdrawBottomSheet({required this.controller});

  @override
  State<_WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<_WithdrawBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedMethod = 'bkash';

  @override
  void dispose() {
    _amountController.dispose();
    _accountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final double amount = double.tryParse(_amountController.text) ?? 0.0;
    final double maxBalance = double.tryParse(widget.controller.walletBalance.value) ?? 0.0;

    if (amount > maxBalance) {
      Get.snackbar(
        'Invalid Amount',
        'Withdrawal amount cannot exceed your available balance.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final success = await widget.controller.submitWithdraw(
      amount: amount,
      method: _selectedMethod,
      accountNumber: _accountController.text.trim(),
      note: _noteController.text.trim(),
    );

    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              
              const Text(
                'Withdraw Funds',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Available Balance: ৳${widget.controller.walletBalance.value}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(child: _buildMethodCard('bkash', 'bKash', const Color(0xFFE2125D))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMethodCard('nagad', 'Nagad', const Color(0xFFF7941D))),
                  const SizedBox(width: 10),
                  Expanded(child: _buildMethodCard('rocket', 'Rocket', const Color(0xFF8C3494))),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (৳)',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  hintText: 'Enter withdrawal amount',
                  hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.monetization_on_outlined, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter amount';
                  final d = double.tryParse(val);
                  if (d == null || d <= 0) return 'Please enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _accountController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  hintText: 'Enter your Mobile Wallet number',
                  hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.phone_android_rounded, size: 20),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter account number';
                  if (val.length < 11) return 'Please enter a valid phone number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Note (Optional)',
                  labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                  hintText: 'Enter short notes or description',
                  hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.notes_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: Obx(() {
                  final isWithdrawing = widget.controller.isWithdrawing.value;
                  return ElevatedButton(
                    onPressed: isWithdrawing ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.red[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isWithdrawing
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : const Text(
                            'Submit Request',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard(String code, String name, Color color) {
    final bool isSelected = _selectedMethod == code;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = code),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
