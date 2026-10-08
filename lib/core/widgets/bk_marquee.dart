import 'package:flutter/material.dart';

class BkMarquee extends StatefulWidget {
  const BkMarquee({
    super.key,
    required this.children,
    this.speed = 50.0,
    this.gap = 32.0,
    this.height = 48.0,
  });

  final List<Widget> children;
  final double speed;
  final double gap;
  final double height;

  @override
  State<BkMarquee> createState() => _BkMarqueeState();
}

class _BkMarqueeState extends State<BkMarquee> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startMarquee();
    });
  }

  void _startMarquee() {
    if (!mounted || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return;

    final durationSeconds = maxScroll / widget.speed;

    _animationController.duration = Duration(milliseconds: (durationSeconds * 1000).round());
    _animationController.reset();

    Tween<double>(begin: 0, end: maxScroll).animate(_animationController)
      ..addListener(() {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_animationController.value * maxScroll);
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reset();
          _animationController.forward();
        }
      });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.of(context).disableAnimations;

    final repeatedContent = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int repeat = 0; repeat < 4; repeat++) ...[
          for (final child in widget.children) ...[
            child,
            SizedBox(width: widget.gap),
          ],
        ],
      ],
    );

    if (disableAnimations) {
      return SizedBox(
        height: widget.height,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: repeatedContent,
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: ListView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        children: [repeatedContent],
      ),
    );
  }
}
