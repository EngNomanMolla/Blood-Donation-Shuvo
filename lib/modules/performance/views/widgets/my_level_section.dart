import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../../models/performance_model.dart';

/// "My Level" section showing current level progress card
class MyLevelSection extends StatelessWidget {
  final CurrentLevelModel level;

  const MyLevelSection({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Level',
          style: AllStyles.titleTextStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 8),
        _LevelProgressCard(level: level),
        const SizedBox(height: 8),
        _LevelDetailCard(level: level),
      ],
    );
  }
}

// ── Progress Card ──────────────────────────────────────────────────────────

class _LevelProgressCard extends StatelessWidget {
  final CurrentLevelModel level;

  const _LevelProgressCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            level.levelName,
            style: AllStyles.titleTextStyle.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              // Background track
              Container(
                height: 28,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              // Filled portion
              FractionallySizedBox(
                widthFactor: level.progressFraction,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    level.progressLabel,
                    style: AllStyles.subtitleTextStyle.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Detail Card ────────────────────────────────────────────────────────────

class _LevelDetailCard extends StatelessWidget {
  final CurrentLevelModel level;

  const _LevelDetailCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: level.progressFraction,
              minHeight: 8,
              backgroundColor: AppColors.borderGray,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          ...level.requirements.map(
            (req) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: BulletText(text: req),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Bullet Text ───────────────────────────────────────────────────

class BulletText extends StatelessWidget {
  final String text;

  const BulletText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6, right: 8),
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AllStyles.subtitleTextStyle.copyWith(
              fontSize: 13,
              color: AppColors.black.withValues(alpha: 0.75),
            ),
          ),
        ),
      ],
    );
  }
}
