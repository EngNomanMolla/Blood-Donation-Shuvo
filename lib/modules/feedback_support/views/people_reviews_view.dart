import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blood_donation/core/utils/app_colors.dart';
import 'package:blood_donation/core/utils/text_styles.dart';
import '../controllers/feedback_support_controller.dart';

class PeopleReviewsView extends GetView<FeedbackSupportController> {
  const PeopleReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildRatingSummary(),
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('People\'s Reviews', style: AllStyles.headingTextStyle.copyWith(fontSize: 18, color: AppColors.white)),
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Obx(() => Text(
                controller.averageRating.value.toString(),
                style: AllStyles.headingTextStyle.copyWith(fontSize: 48, color: AppColors.primary),
              )),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < 4.8.toInt() ? Colors.orange : Colors.grey.shade300,
                    size: 20,
                  );
                }),
              ),
              const SizedBox(height: 5),
              Obx(() => Text(
                '${controller.totalReviews.value} reviews',
                style: AllStyles.subtitleTextStyle.copyWith(color: AppColors.darkGray),
              )),
            ],
          ),
          const SizedBox(width: 30),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.8),
                _buildRatingBar(4, 0.15),
                _buildRatingBar(3, 0.03),
                _buildRatingBar(2, 0.01),
                _buildRatingBar(1, 0.01),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double progress) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$star', style: AllStyles.subtitleTextStyle.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Recent Reviews',
            style: AllStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        Obx(() => ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.reviews.length,
          itemBuilder: (context, index) {
            final review = controller.reviews[index];
            return _buildReviewCard(review);
          },
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGray.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(review['avatar']),
                radius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review['name'], style: AllStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold)),
                    Text(review['date'], style: AllStyles.subtitleTextStyle.copyWith(fontSize: 12, color: AppColors.darkGray)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < review['rating'].toInt() ? Colors.orange : Colors.grey.shade300,
                    size: 16,
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: AllStyles.subtitleTextStyle.copyWith(color: AppColors.black.withValues(alpha: 0.8), height: 1.4),
          ),
        ],
      ),
    );
  }
}
