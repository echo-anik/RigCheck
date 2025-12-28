/// Utility functions for currency conversion and formatting
class CurrencyUtils {
  static const double usdToBdtRate = 120.0;

  /// Convert BDT to USD
  static double bdtToUsd(double bdt) {
    return bdt / usdToBdtRate;
  }

  /// Convert USD to BDT
  static double usdToBdt(double usd) {
    return usd * usdToBdtRate;
  }

  /// Format price in BDT with proper symbol
  static String formatBdt(double amount, {bool includeSymbol = true}) {
    final formatted = amount.toStringAsFixed(0);
    if (includeSymbol) {
      return '৳$formatted';
    }
    return formatted;
  }

  /// Format price in USD with proper symbol
  static String formatUsd(double amount, {bool includeSymbol = true}) {
    final formatted = amount.toStringAsFixed(2);
    if (includeSymbol) {
      return '\$$formatted';
    }
    return formatted;
  }

  /// Format price in selected currency
  static String formatPrice(
    double bdtAmount, {
    required bool showUsd,
    bool includeSymbol = true,
  }) {
    if (showUsd) {
      final usdAmount = bdtToUsd(bdtAmount);
      return formatUsd(usdAmount, includeSymbol: includeSymbol);
    } else {
      return formatBdt(bdtAmount, includeSymbol: includeSymbol);
    }
  }

  /// Get currency symbol
  static String getSymbol(bool isUsd) {
    return isUsd ? '\$' : '৳';
  }

  /// Get currency code
  static String getCode(bool isUsd) {
    return isUsd ? 'USD' : 'BDT';
  }

  /// Parse price string and convert if needed
  static double parsePrice(String priceStr, {bool fromUsd = false}) {
    // Remove currency symbols and commas
    final cleaned = priceStr.replaceAll(RegExp(r'[৳$,\s]'), '');
    final amount = double.tryParse(cleaned) ?? 0.0;
    
    if (fromUsd) {
      return usdToBdt(amount);
    }
    return amount;
  }
}
