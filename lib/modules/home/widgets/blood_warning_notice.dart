import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_colors.dart';

/// Animated warning/notice banner displayed before the blood request section
class BloodWarningNotice extends StatefulWidget {
  const BloodWarningNotice({super.key});

  @override
  State<BloodWarningNotice> createState() => _BloodWarningNoticeState();
}

class _BloodWarningNoticeState extends State<BloodWarningNotice> {
  final List<_NoticeItem> _notices = const [
    _NoticeItem(
      text: 'প্রতারণা ও যেকোনো ধরনের আর্থিক লেনদেন থেকে বিরত থাকুন।',
      icon: Icons.gpp_maybe_rounded,
      highlightWord: 'সতর্কতা',
    ),
    _NoticeItem(
      text: 'রক্ত গ্রহণের পর অবশ্যই রক্তদাতার যাতায়াত খরচ বহন করুন।',
      icon: Icons.commute_rounded,
      highlightWord: 'যাতায়াত',
    ),
    _NoticeItem(
      text: 'প্রয়োজনীয় রক্ত পরীক্ষা (Blood Test) সম্পন্ন করে নিরাপদ রক্ত গ্রহণ নিশ্চিত করুন।',
      icon: Icons.health_and_safety_rounded,
      highlightWord: 'পরীক্ষা',
    ),
    _NoticeItem(
      text: 'রক্তদাতার প্রতি সর্বোচ্চ সম্মান, কৃতজ্ঞতা ও সহযোগিতা বজায় রাখুন।',
      icon: Icons.volunteer_activism_rounded,
      highlightWord: 'কৃতজ্ঞতা',
    ),
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _notices.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToNext() {
    _timer?.cancel();
    setState(() {
      _currentIndex = (_currentIndex + 1) % _notices.length;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _notices[_currentIndex];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: _goToNext,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF5F6),
                Color(0xFFFFF0F2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFFFCDD2).withOpacity(0.9),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: Header badge & dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.campaign_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'জরুরি সতর্কবার্তা',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Dots indicator
                  Row(
                    children: List.generate(_notices.length, (index) {
                      final isSelected = index == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        height: 5,
                        width: isSelected ? 16 : 5,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Animated Notice message with icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final inAnimation = Tween<Offset>(
                    begin: const Offset(0.0, 0.45),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  );
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: inAnimation,
                      child: child,
                    ),
                  );
                },
                child: Row(
                  key: ValueKey<int>(_currentIndex),
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        currentItem.icon,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        currentItem.text,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2B2B2B),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoticeItem {
  final String text;
  final IconData icon;
  final String highlightWord;

  const _NoticeItem({
    required this.text,
    required this.icon,
    required this.highlightWord,
  });
}

