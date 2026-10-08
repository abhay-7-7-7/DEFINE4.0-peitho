import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

class BkPagination extends StatelessWidget {
  const BkPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxVisible = 5,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prev button
        _buildButton(
          context: context,
          t: t,
          label: 'PREV',
          enabled: currentPage > 1,
          onTap: () => onPageChanged(currentPage - 1),
        ),
        const SizedBox(width: 8),
        // Page numbers
        ...List.generate(totalPages, (index) {
          final page = index + 1;
          if (totalPages > maxVisible) {
            if (page != 1 && page != totalPages && (page < currentPage - 1 || page > currentPage + 1)) {
              if (page == currentPage - 2 || page == currentPage + 2) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('...', style: TextStyle(fontWeight: FontWeight.bold)),
                );
              }
              return const SizedBox.shrink();
            }
          }

          final isSelected = page == currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onPageChanged(page),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected ? t.primary : t.card,
                  border: Border.all(color: t.border, width: t.borderWidth),
                  boxShadow: isSelected
                      ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$page',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      color: isSelected ? t.primaryForeground : t.foreground,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        // Next button
        _buildButton(
          context: context,
          t: t,
          label: 'NEXT',
          enabled: currentPage < totalPages,
          onTap: () => onPageChanged(currentPage + 1),
        ),
      ],
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required BkTokens t,
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: t.card,
            border: Border.all(color: t.border, width: t.borderWidth),
            boxShadow: enabled
                ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: t.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
