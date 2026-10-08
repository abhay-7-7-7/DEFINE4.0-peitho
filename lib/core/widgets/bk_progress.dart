import 'package:flutter/material.dart';
import '../theme/bk_tokens.dart';

class BkProgress extends StatefulWidget {
  const BkProgress({
    super.key,
    this.value,
    this.height = 16.0,
    this.color,
    this.backgroundColor,
  });

  /// Value between 0.0 and 1.0. If null, the progress indicator is indeterminate.
  final double? value;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  @override
  State<BkProgress> createState() => _BkProgressState();
}

class _BkProgressState extends State<BkProgress>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.value == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(BkProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value == null && _controller == null) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      )..repeat();
    } else if (widget.value != null && _controller != null) {
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final barColor = widget.color ?? t.primary;
    final bgColor = widget.backgroundColor ?? t.muted;

    return Container(
      height: widget.height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: t.border, width: t.borderWidth),
        boxShadow: [
          BoxShadow(
            color: t.shadowColor,
            offset: Offset(t.shadowOffset * 0.75, t.shadowOffset * 0.75),
            blurRadius: 0,
          ),
        ],
      ),
      child: widget.value != null
          ? FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widget.value!.clamp(0.0, 1.0),
              child: Container(color: barColor),
            )
          : AnimatedBuilder(
              animation: _controller!,
              builder: (context, child) {
                final v = _controller!.value;
                final left = ((v * 2.0) - 0.5).clamp(0.0, 1.0);
                const width = 0.4;
                return Stack(
                  children: [
                    Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment(left * 2 - 1, 0),
                        widthFactor: width,
                        child: Container(color: barColor),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
