import 'package:intl/intl.dart';

/// Single source of truth for currency formatting across TradeMind Mobile.
/// Matches the web UI symbol (₹) and Indian/International numbering conventions.
class CurrencyFormatter {
  static const String defaultSymbol = '₹';

  static final NumberFormat _standardFormatter = NumberFormat.currency(
    symbol: defaultSymbol,
    decimalDigits: 2,
    customPattern: '¤#,##,##0.00',
  );

  static final NumberFormat _integerFormatter = NumberFormat.currency(
    symbol: defaultSymbol,
    decimalDigits: 0,
    customPattern: '¤#,##,##0',
  );

  /// Format amount with symbol and optional custom decimal places
  static String format(
    num? amount, {
    String? symbol,
    int? decimals,
    bool compact = false,
  }) {
    if (amount == null) return '${symbol ?? defaultSymbol}0';

    final effectiveSymbol = symbol ?? defaultSymbol;

    if (compact) {
      if (amount.abs() >= 10000000) {
        return '$effectiveSymbol${(amount / 10000000).toStringAsFixed(1)}Cr';
      }
      if (amount.abs() >= 100000) {
        return '$effectiveSymbol${(amount / 100000).toStringAsFixed(1)}L';
      }
      if (amount.abs() >= 1000) {
        return '$effectiveSymbol${(amount / 1000).toStringAsFixed(1)}k';
      }
    }

    if (decimals == 0) {
      if (effectiveSymbol == defaultSymbol) {
        return _integerFormatter.format(amount);
      }
      return '$effectiveSymbol${NumberFormat('#,##0').format(amount)}';
    }

    if (effectiveSymbol == defaultSymbol) {
      return _standardFormatter.format(amount);
    }
    return '$effectiveSymbol${NumberFormat('#,##0.00').format(amount)}';
  }

  /// Format without currency symbol
  static String formatNumber(num? amount, {int decimals = 2}) {
    if (amount == null) return '0.00';
    if (decimals == 0) {
      return NumberFormat('#,##0').format(amount);
    }
    return NumberFormat('#,##0.00').format(amount);
  }

  /// Format margin percentage (+25.4% or -12.0%)
  static String formatMargin(num? marginPct) {
    if (marginPct == null) return '0.0%';
    final sign = marginPct > 0 ? '+' : '';
    return '$sign${marginPct.toStringAsFixed(1)}%';
  }
}
