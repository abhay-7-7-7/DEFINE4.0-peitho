import 'package:flutter/material.dart';
import '../theme/bk_tokens.dart';
import 'bk_button.dart';
import 'bk_card.dart';

/// Reusable neubrutalist loading state widget.
class BkLoadingState extends StatelessWidget {
  final String message;

  const BkLoadingState({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BkCard(
          backgroundColor: t.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: t.primary,
                    backgroundColor: t.border.withAlpha(50),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: t.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable neubrutalist empty state widget.
class BkEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const BkEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BkCard(
          backgroundColor: t.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: t.accent.withAlpha(80),
                    border: Border.all(color: t.border, width: t.borderWidth),
                  ),
                  child: Icon(icon, size: 32, color: t.foreground),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: t.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: t.mutedForeground,
                    height: 1.4,
                  ),
                ),
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 24),
                  BkButton(
                    onPressed: onAction,
                    variant: BkButtonVariant.primary,
                    label: actionLabel!,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable neubrutalist error state widget with retry.
class BkErrorState extends StatelessWidget {
  final String title;
  final String error;
  final VoidCallback? onRetry;
  final String retryLabel;

  const BkErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.error,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BkCard(
          backgroundColor: t.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: t.destructive.withAlpha(40),
                    border: Border.all(color: t.destructive, width: t.borderWidth),
                  ),
                  child: Icon(Icons.error_outline, size: 36, color: t.destructive),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: t.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'DM Mono',
                    color: t.mutedForeground,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  BkButton(
                    onPressed: onRetry,
                    variant: BkButtonVariant.secondary,
                    label: retryLabel,
                    leading: const Icon(Icons.refresh, size: 18),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Reusable neubrutalist offline state widget.
class BkOfflineState extends StatelessWidget {
  final VoidCallback? onRetry;

  const BkOfflineState({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BkCard(
          backgroundColor: t.card,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: t.warning.withAlpha(80),
                    border: Border.all(color: t.border, width: t.borderWidth),
                  ),
                  child: Icon(Icons.wifi_off_outlined, size: 32, color: t.foreground),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Connection',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: t.foreground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Unable to reach TradeMind servers. Check your connection or verify backend URL.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: t.mutedForeground,
                    height: 1.4,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 20),
                  BkButton(
                    onPressed: onRetry,
                    variant: BkButtonVariant.primary,
                    label: 'Check Connection',
                    leading: const Icon(Icons.refresh, size: 18),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
