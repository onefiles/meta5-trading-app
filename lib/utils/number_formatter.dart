// Android版と同じ数値フォーマット機能
class NumberFormatter {
  /// Android版と同じスペース区切りフォーマット（コンマではなくスペース）
  static String formatWithSpaces(double value) {
    final formatted = value.toInt().toString();
    return _addSpaces(formatted);
  }
  
  /// 損益フォーマット（スペース区切り + .00固定）
  static String formatProfit(double profit) {
    final absValue = profit.abs();
    final formatted = formatWithSpaces(absValue);
    final sign = profit < 0 ? '-' : '';
    return '$sign$formatted.00';
  }
  
  /// 価格フォーマット（通貨ペア別、Android版と同じロジック）
  static String formatPrice(double price, String symbol) {
    if (symbol == "BTCJPY") {
      // BTCJPYは整数表示（小数点なし、スペース区切り）
      final integerFormatted = price.toInt().toString();
      return _addSpaces(integerFormatted);
    } else if (symbol == "GBPJPY") {
      // GBPJPYは小数点3桁で表示（スペース区切り）
      final formatted = price.toStringAsFixed(3);
      final parts = formatted.split(".");
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : "000";
      
      return "${_addSpaces(integerPart)}.$decimalPart";
    } else {
      // その他は小数点2桁（スペース区切り）
      final formatted = price.toStringAsFixed(2);
      final parts = formatted.split(".");
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : "00";
      
      return "${_addSpaces(integerPart)}.$decimalPart";
    }
  }
  
  /// 価格範囲フォーマット（Android版のformatPriceWithSpacesと同じ）
  static String formatPriceRange(double openPrice, double currentPrice, String symbol) {
    final openFormatted = formatPrice(openPrice, symbol);
    final currentFormatted = formatPrice(currentPrice, symbol);
    return "$openFormatted → $currentFormatted";
  }
  
  /// Android版と同じスペース追加ロジック
  static String _addSpaces(String number) {
    final reversed = number.split('').reversed.toList();
    final chunks = <String>[];
    
    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      chunks.add(reversed.sublist(i, end).reversed.join());
    }
    
    return chunks.reversed.join(' '); // コンマではなくスペース
  }
  
  /// 証拠金等の表示用フォーマット（Android版のformatNumberWithSpacesと同じ）
  static String formatAmount(double amount) {
    final formatted = amount.toInt().toString();
    return _addSpaces(formatted);
  }
}