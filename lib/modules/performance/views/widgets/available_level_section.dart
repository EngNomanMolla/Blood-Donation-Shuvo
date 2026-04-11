import 'package:flutter/material.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../../models/performance_model.dart';

/// "Available Level" section displaying unlockable level cards
class AvailableLevelSection extends StatelessWidget {
  final List<LevelModel> levels;

  const AvailableLevelSection({super.key, required this.levels});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Level',
          style: AllStyles.titleTextStyle.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: levels

              .map(
                (level) => Expanded(
                  child: Padding(
                    // Gap between cards, only between items
                    padding: EdgeInsets.only(
                      right: levels.last == level ? 0 : 12,
                    ),
                    child: _LevelCard(level: level),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final LevelModel level;

  const _LevelCard({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
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
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${level.prefix} ',
                  style: AllStyles.titleTextStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.black,
                  ),
                ),
                TextSpan(
                  text: level.letter,
                  style: AllStyles.titleTextStyle.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            level.subtitle,
            style: AllStyles.subtitleTextStyle.copyWith(
              fontSize: 13,
              color: AppColors.black.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
