import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

class BkStep {
  const BkStep({
    required this.title,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget? icon;
}

class BkStepper extends StatelessWidget {
  const BkStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.onStepTapped,
    this.orientation = Axis.horizontal,
  });

  final List<BkStep> steps;
  final int currentStep;
  final ValueChanged<int>? onStepTapped;
  final Axis orientation;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    if (orientation == Axis.horizontal) {
      return Row(
        children: List.generate(steps.length, (index) {
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          final isLast = index == steps.length - 1;

          final (circleBg, circleFg) = isCompleted
              ? (t.success, t.successForeground)
              : isActive
                  ? (t.primary, t.primaryForeground)
                  : (t.card, t.mutedForeground);

          return Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap:
                      onStepTapped != null ? () => onStepTapped!(index) : null,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: circleBg,
                      border: Border.all(color: t.border, width: t.borderWidth),
                      boxShadow: isActive || isCompleted
                          ? [
                              BoxShadow(
                                  color: t.shadowColor,
                                  offset: const Offset(3, 3))
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, size: 20, color: circleFg)
                          : Text(
                              '${index + 1}',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w900,
                                color: circleFg,
                              ),
                            ),
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      height: t.borderWidth,
                      color: isCompleted
                          ? t.border
                          : t.border.withValues(alpha: 0.3),
                    ),
                  ),
              ],
            ),
          );
        }),
      );
    }

    // Vertical stepper
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isCompleted = index < currentStep;
        final isActive = index == currentStep;
        final isLast = index == steps.length - 1;

        final (circleBg, circleFg) = isCompleted
            ? (t.success, t.successForeground)
            : isActive
                ? (t.primary, t.primaryForeground)
                : (t.card, t.mutedForeground);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  GestureDetector(
                    onTap: onStepTapped != null
                        ? () => onStepTapped!(index)
                        : null,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: circleBg,
                        border:
                            Border.all(color: t.border, width: t.borderWidth),
                        boxShadow: isActive || isCompleted
                            ? [
                                BoxShadow(
                                    color: t.shadowColor,
                                    offset: const Offset(3, 3))
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(Icons.check, size: 20, color: circleFg)
                            : Text(
                                '${index + 1}',
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.w900,
                                  color: circleFg,
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: t.borderWidth,
                        color: isCompleted
                            ? t.border
                            : t.border.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: t.foreground,
                        ),
                      ),
                      if (step.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          step.subtitle!,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: t.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
