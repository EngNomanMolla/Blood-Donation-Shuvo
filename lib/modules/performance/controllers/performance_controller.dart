import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/performance_model.dart';

class PerformanceController extends GetxController {
  // ── Stats ────────────────────────────────────────────────────────────────

  final List<StatCardModel> stats = const [
    StatCardModel(
      label: 'Total User',
      value: '1,250',
      icon: Icons.people_alt_rounded,
    ),
    StatCardModel(
      label: 'Total Earning',
      value: '1500',
      icon: Icons.attach_money_rounded,
    ),
    StatCardModel(
      label: 'Total Withdraw',
      value: '1,000',
      icon: Icons.account_balance_wallet_rounded,
    ),
    StatCardModel(
      label: 'Current Balance',
      value: '500',
      icon: Icons.account_balance_rounded,
    ),
  ];

  // ── Current Level ────────────────────────────────────────────────────────

  final CurrentLevelModel currentLevel = const CurrentLevelModel(
    levelName: 'Level C',
    progressFraction: 0.50,
    progressLabel: '50%',
    requirements: [
      'Reach 500+ Registration',
      'Requirement: 1,000+ Registrations For Level A.',
    ],
  );

  // ── Available Levels ─────────────────────────────────────────────────────

  final List<LevelModel> availableLevels = const [
    LevelModel(prefix: 'Level', letter: 'A', subtitle: 'Reach 1000+\nRegistration'),
    LevelModel(prefix: 'Level', letter: 'B', subtitle: 'Reach 700+\nRegistration'),
  ];
}
