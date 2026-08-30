import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/wallet_repository.dart';
import '../../../data/providers/wallet_provider.dart';
import '../models/performance_model.dart';

class PerformanceController extends GetxController {
  final WalletRepository walletRepository;

  PerformanceController({WalletRepository? walletRepository})
      : walletRepository = walletRepository ?? Get.put(WalletRepository(Get.put(WalletProvider())));

  // ── Observables ──────────────────────────────────────────────────────────
  final RxList<StatCardModel> stats = <StatCardModel>[].obs;
  final Rxn<CurrentLevelModel> currentLevel = Rxn<CurrentLevelModel>();
  final RxList<LevelModel> availableLevels = <LevelModel>[].obs;
  
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPerformanceDetails();
  }

  Future<void> fetchPerformanceDetails() async {
    isLoading.value = true;
    try {
      // 1. Fetch performance API
      final performanceResponse = await walletRepository.getVolunteerPerformance();
      debugPrint("Volunteer Performance API debug - Code: ${performanceResponse.statusCode}");
      debugPrint("Volunteer Performance API debug - Body: ${performanceResponse.body}");

      // 2. Fetch wallet API
      final walletResponse = await walletRepository.getVolunteerWallet();
      debugPrint("Volunteer Wallet API debug - Code: ${walletResponse.statusCode}");
      debugPrint("Volunteer Wallet API debug - Body: ${walletResponse.body}");

      double balanceVal = 0;
      double totalEarningVal = 0;
      double totalWithdrawVal = 0;

      if (walletResponse.statusCode == 200) {
        final decodedWallet = jsonDecode(walletResponse.body);
        balanceVal = (decodedWallet['balance'] ?? 0).toDouble();
        totalEarningVal = (decodedWallet['earnings'] ?? decodedWallet['total_earning'] ?? decodedWallet['total_earnings'] ?? 0).toDouble();
        totalWithdrawVal = (decodedWallet['withdrawals'] ?? decodedWallet['total_withdraw'] ?? decodedWallet['total_withdraws'] ?? decodedWallet['total_withdrawal'] ?? decodedWallet['withdraws'] ?? 0).toDouble();
      }

      if (performanceResponse.statusCode == 200) {
        final decodedPerf = jsonDecode(performanceResponse.body);

        final int countVal = decodedPerf['count'] ?? 0;
        final String currentLevelStr = decodedPerf['current_level'] ?? 'C';
        final String nextLevelStr = decodedPerf['next_level'] ?? 'B';
        final int nextGoalVal = decodedPerf['next_goal'] ?? 300;
        final double progressVal = (decodedPerf['progress'] ?? 0.0).toDouble();

        // Stats card mapping
        stats.assignAll([
          StatCardModel(
            label: 'Total User',
            value: countVal.toString(),
            icon: Icons.people_alt_rounded,
          ),
          StatCardModel(
            label: 'Total Earning',
            value: '৳ ${totalEarningVal.toStringAsFixed(0)}',
            icon: Icons.attach_money_rounded,
          ),
          StatCardModel(
            label: 'Total Withdraw',
            value: '৳ ${totalWithdrawVal.toStringAsFixed(0)}',
            icon: Icons.account_balance_wallet_rounded,
          ),
          StatCardModel(
            label: 'Current Balance',
            value: '৳ ${balanceVal.toStringAsFixed(0)}',
            icon: Icons.account_balance_rounded,
          ),
        ]);

        // Current level requirements & mapping
        final List<dynamic> levelsList = decodedPerf['levels'] ?? [];
        final List<String> requirements = [];
        requirements.add('Reach $nextGoalVal+ Registrations for Level $nextLevelStr');
        requirements.add('Requirement: 700+ Registrations For Level A.');

        final int percentVal = (progressVal * 100).toInt();

        currentLevel.value = CurrentLevelModel(
          levelName: 'Level $currentLevelStr',
          progressFraction: progressVal,
          progressLabel: '$percentVal%',
          requirements: requirements,
        );

        // Available levels mapping (levels that are next/higher than current)
        final mappedLevels = levelsList
            .map((lvl) {
              final String name = lvl['name'] ?? '';
              final int requirement = lvl['requirement'] ?? 0;
              return LevelModel(
                prefix: 'Level',
                letter: name,
                subtitle: 'Reach $requirement+\nRegistration',
              );
            })
            .where((lvl) => lvl.letter != currentLevelStr)
            .toList();

        // Sort levels alphabetically (A, B, C...)
        mappedLevels.sort((a, b) => a.letter.compareTo(b.letter));

        availableLevels.assignAll(mappedLevels);
      } else {
        Get.snackbar('Error', 'Failed to fetch performance details',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Error fetching volunteer performance details: $e");
      Get.snackbar('Error', 'An error occurred while loading performance data',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
