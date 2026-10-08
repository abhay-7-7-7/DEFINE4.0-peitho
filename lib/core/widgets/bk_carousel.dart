import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';
import 'bk_button.dart';

/// A neubrutalist swipeable carousel with brutalist pagination dots and arrow controls.
class BkCarousel extends StatefulWidget {
  const BkCarousel({
    super.key,
    required this.items,
    this.height = 200,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showArrows = true,
    this.showIndicators = true,
  });

  final List<Widget> items;
  final double height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showArrows;
  final bool showIndicators;

  @override
  State<BkCarousel> createState() => _BkCarouselState();
}

class _BkCarouselState extends State<BkCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.autoPlay && widget.items.length > 1) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final next = (_currentIndex + 1) % widget.items.length;
      _pageController.animateToPage(
        next,
        duration: BkMotion.carouselSlide,
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    BkMotion.hapticClick();
    _pageController.animateToPage(
      index,
      duration: BkMotion.carouselSlide,
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, i) => widget.items[i],
              ),
              if (widget.showArrows && widget.items.length > 1) ...[
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: BkButton(
                      label: '<',
                      size: BkButtonSize.icon,
                      variant: BkButtonVariant.outline,
                      leading: const Icon(Icons.chevron_left, size: 20),
                      onPressed: _currentIndex > 0
                          ? () => _goTo(_currentIndex - 1)
                          : null,
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: BkButton(
                      label: '>',
                      size: BkButtonSize.icon,
                      variant: BkButtonVariant.outline,
                      leading: const Icon(Icons.chevron_right, size: 20),
                      onPressed: _currentIndex < widget.items.length - 1
                          ? () => _goTo(_currentIndex + 1)
                          : null,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (widget.showIndicators && widget.items.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.items.length, (i) {
              final isSelected = i == _currentIndex;
              return GestureDetector(
                onTap: () => _goTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 24 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isSelected ? t.primary : t.muted,
                    border: Border.all(color: t.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: t.shadowColor,
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
