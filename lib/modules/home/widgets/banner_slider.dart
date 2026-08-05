import 'dart:async';
import 'package:flutter/material.dart';
import '../constants.dart';

/// Reusable banner slider widget with auto-scroll capability
class BannerSlider extends StatefulWidget {
  final List<String> images;
  final double height;
  final double borderRadius;
  final Duration autoScrollDuration;
  final Duration animationDuration;

  const BannerSlider({
    super.key,
    required this.images,
    this.height = HomeConstants.bannerHeight,
    this.borderRadius = HomeConstants.bannerBorderRadius,
    this.autoScrollDuration =
        const Duration(seconds: HomeConstants.bannerAutoScrollDuration),
    this.animationDuration =
        const Duration(milliseconds: HomeConstants.bannerAnimationDuration),
  });

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  late PageController _pageController;
  late Timer _autoScrollTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.images.isEmpty) return;
    _autoScrollTimer = Timer.periodic(widget.autoScrollDuration, (_) {
      if (mounted && widget.images.isNotEmpty) {
        _currentIndex = (_currentIndex + 1) % widget.images.length;
        _pageController.animateToPage(
          _currentIndex,
          duration: widget.animationDuration,
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImageSlider(),
        const SizedBox(height: 10),
        _buildDots(),
      ],
    );
  }

  Widget _buildImageSlider() {
    return SizedBox(
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Image.network(
                widget.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade100,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey.shade400,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade50,
                    alignment: Alignment.center,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.images.length,
        (index) => AnimatedContainer(
          duration: HomeConstants.dotsAnimationDuration,
          margin:
              const EdgeInsets.symmetric(horizontal: HomeConstants.indicatorSpacing),
          height: HomeConstants.indicatorSize,
          width: _currentIndex == index
              ? HomeConstants.selectedIndicatorWidth
              : HomeConstants.indicatorSize,
          decoration: BoxDecoration(
            color:
                _currentIndex == index ? Colors.red : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
