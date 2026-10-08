import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

/// Neubrutalist interactive rating component with bold star glyphs and tactile feedback.
class BkRating extends StatefulWidget {
  const BkRating({
    super.key,
    required this.rating,
    this.onChanged,
    this.maxStars = 5,
    this.size = 28.0,
    this.readOnly = false,
    this.showScore = true,
  });

  final double rating;
  final ValueChanged<double>? onChanged;
  final int maxStars;
  final double size;
  final bool readOnly;
  final bool showScore;

  @override
  State<BkRating> createState() => _BkRatingState();
}

class _BkRatingState extends State<BkRating> {
  int _lastTappedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.maxStars, (index) {
            final starIndex = index + 1;
            final isFilled = starIndex <= widget.rating;
            final isTapped = _lastTappedIndex == index;

            Widget star = GestureDetector(
              onTap: widget.readOnly
                  ? null
                  : () {
                      BkMotion.hapticClick();
                      setState(() => _lastTappedIndex = index);
                      widget.onChanged?.call(starIndex.toDouble());
                    },
              child: AnimatedScale(
                scale: isTapped ? 1.25 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: BkMotion.bounce,
                onEnd: () {
                  if (mounted && _lastTappedIndex != -1) {
                    setState(() => _lastTappedIndex = -1);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: isFilled ? t.accent : t.muted,
                      border: Border.all(color: t.border, width: t.borderWidth),
                      boxShadow: [
                        BoxShadow(
                          color: t.shadowColor,
                          offset:
                              Offset(t.shadowOffset - 2, t.shadowOffset - 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.star,
                        size: widget.size * 0.65,
                        color:
                            isFilled ? t.accentForeground : t.mutedForeground,
                      ),
                    ),
                  ),
                ),
              ),
            );

            return star;
          }),
        ),
        if (widget.showScore) ...[
          const SizedBox(width: 12),
          Text(
            '${widget.rating.toStringAsFixed(1)} / ${widget.maxStars}.0',
            style: GoogleFonts.dmMono(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: t.foreground,
            ),
          ),
        ],
      ],
    );
  }
}
