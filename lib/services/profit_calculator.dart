import '../models/order.dart';

class ProfitCalculator {
  // レバレッジ設定
  static const double leverage = 1000.0;
  
  // 契約サイズ（1ロットあたりの通貨単位）
  static const Map<String, double> contractSizes = {
    'GBPJPY': 100000.0,    // 10万GBP
    'EURUSD': 100000.0,    // 10万EUR
    'USDJPY': 100000.0,    // 10万USD
    'BTCJPY': 1.0,         // 1BTC
    'XAUUSD': 100.0,       // 100オンス
  };
  
  // 最小価格変動幅（pip）
  static const Map<String, double> pipSizes = {
    'GBPJPY': 0.001,       // 0.001 = 1pip
    'EURUSD': 0.0001,      // 0.0001 = 1pip
    'USDJPY': 0.01,        // 0.01 = 1pip
    'BTCJPY': 1.0,         // 1円 = 1pip
    'XAUUSD': 0.01,        // 0.01ドル = 1pip
  };

  /// 損益計算（Android版と同じロジック）
  static double calculateProfit({
    required String symbol,
    required OrderType orderType,
    required double lots,
    required double openPrice,
    required double currentPrice,
  }) {
    // Android版と同じコントラクトサイズ
    double multiplier;
    switch (symbol) {
      case 'XAUUSD':
        multiplier = 100.0;
        break;
      case 'USDJPY':
      case 'GBPJPY':
        multiplier = 100000.0;
        break;
      case 'BTCJPY':
        multiplier = 1.0;
        break;
      default:
        multiplier = 100000.0;
    }
    
    // Android版と同じ損益計算
    switch (orderType) {
      case OrderType.buy:
        return (currentPrice - openPrice) * lots * multiplier;
      case OrderType.sell:
        return (openPrice - currentPrice) * lots * multiplier;
      case OrderType.balance:
      case OrderType.credit:
        return 0.0; // 残高操作では損益計算なし
    }
  }
  
  /// 必要証拠金計算（Android版と同じ固定レート使用）
  static double calculateRequiredMargin({
    required String symbol,
    required double lots,
    required double price,
  }) {
    // Android版と同じ固定為替レートとレバレッジ
    const double gbpjpyRate = 195.0; // Android版と同じ固定値
    const double leverage = 1000.0; // レバレッジ1000倍
    
    switch (symbol) {
      case 'GBPJPY':
        // Android版と同じ計算式
        return lots * 100000 * gbpjpyRate / leverage;
        
      case 'BTCJPY':
        // BTC/JPY: 必要証拠金 = ロット数 × 価格 ÷ レバレッジ
        return (lots * price) / leverage;
        
      case 'XAUUSD':
        // XAU/USD: Android版と同じ固定USD/JPYレート使用
        const double usdJpyRate = 148.25; // 固定レート
        return (lots * 100.0 * price * usdJpyRate) / leverage;
        
      case 'EURUSD':
        // EUR/USD: Android版と同じ固定USD/JPYレート使用
        const double usdJpyRate = 148.25; // 固定レート
        return (lots * 100000.0 * price * usdJpyRate) / leverage;
        
      case 'USDJPY':
        // USD/JPY: 必要証拠金 = ロット数 × 契約サイズ ÷ レバレッジ
        return (lots * 100000.0) / leverage;
        
      default:
        return (lots * 100000.0 * price) / leverage;
    }
  }
  
  /// 1pipあたりの価値計算
  static double calculatePipValue({
    required String symbol,
    required double lots,
  }) {
    final contractSize = contractSizes[symbol] ?? 100000.0;
    final pipSize = pipSizes[symbol] ?? 0.0001;
    
    switch (symbol) {
      case 'GBPJPY':
        return lots * contractSize * pipSize;
        
      case 'BTCJPY':
        return lots * pipSize;
        
      case 'XAUUSD':
        final usdJpyRate = _getUsdJpyRate();
        return lots * contractSize * pipSize * usdJpyRate;
        
      case 'EURUSD':
        final usdJpyRate = _getUsdJpyRate();
        return lots * contractSize * pipSize * usdJpyRate;
        
      case 'USDJPY':
        return lots * contractSize * pipSize;
        
      default:
        return lots * contractSize * pipSize;
    }
  }
  
  /// スワップポイント計算（デモ用）
  static double calculateSwapPoints({
    required String symbol,
    required OrderType orderType,
    required double lots,
    required int daysHeld,
  }) {
    // デモ用のスワップレート（年率）
    final Map<String, Map<String, double>> swapRates = {
      'GBPJPY': {'buy': 0.0021, 'sell': -0.0035},
      'EURUSD': {'buy': -0.0015, 'sell': 0.0008},
      'USDJPY': {'buy': 0.0012, 'sell': -0.0025},
      'BTCJPY': {'buy': 0.0, 'sell': 0.0},
      'XAUUSD': {'buy': -0.0008, 'sell': -0.0008},
    };
    
    final typeKey = orderType == OrderType.buy ? 'buy' : 'sell';
    final swapRate = swapRates[symbol]?[typeKey] ?? 0.0;
    final contractSize = contractSizes[symbol] ?? 100000.0;
    
    // 年率を日割り計算
    return (lots * contractSize * swapRate * daysHeld) / 365;
  }
  
  /// 手数料計算（通常は0だが、将来の拡張用）
  static double calculateCommission({
    required String symbol,
    required double lots,
  }) {
    // ほとんどのFXブローカーは手数料無料
    // 株式や一部の商品では手数料がかかる場合がある
    return 0.0;
  }
  
  /// Android版と同じUSD/JPYレート（固定値）
  static double _getUsdJpyRate() {
    // Android版では動的レート取得はしていないため、固定値を使用
    return 148.25;
  }
  
  /// 証拠金維持率計算
  static double calculateMarginLevel({
    required double equity,
    required double requiredMargin,
  }) {
    if (requiredMargin <= 0) return 0.0; // ポジションがない場合は0%表示
    return (equity / requiredMargin) * 100;
  }
  
  /// 余剰証拠金計算
  static double calculateFreeMargin({
    required double equity,
    required double requiredMargin,
  }) {
    return equity - requiredMargin;
  }
  
  /// 有効証拠金計算
  static double calculateEquity({
    required double balance,
    required double totalProfit,
  }) {
    return balance + totalProfit;
  }
  
  /// 価格フォーマット（Android版と同じスペース区切り）
  static String formatPrice(double price, String symbol) {
    if (symbol == 'BTCJPY') {
      // BTCJPYは整数表示（スペース区切り）
      final integerFormatted = price.toInt().toString();
      return _addSpaces(integerFormatted);
    } else if (symbol == 'GBPJPY') {
      // GBPJPYは小数点3桁（スペース区切り）
      final formatted = price.toStringAsFixed(3);
      final parts = formatted.split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '000';
      return '${_addSpaces(integerPart)}.$decimalPart';
    } else {
      // その他は小数点2桁（スペース区切り）
      final formatted = price.toStringAsFixed(2);
      final parts = formatted.split('.');
      final integerPart = parts[0];
      final decimalPart = parts.length > 1 ? parts[1] : '00';
      return '${_addSpaces(integerPart)}.$decimalPart';
    }
  }
  
  /// Android版と同じスペース追加（コンマではなくスペース）
  static String _addSpaces(String number) {
    final reversed = number.split('').reversed.toList();
    final chunks = <String>[];
    
    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      chunks.add(reversed.sublist(i, end).reversed.join());
    }
    
    return chunks.reversed.join(' '); // Android版と同じスペース区切り
  }
  
  /// 損益フォーマット（Android版と同じ）
  static String formatProfit(double profit) {
    final absValue = profit.abs();
    final formatted = _addSpaces(absValue.toInt().toString());
    final sign = profit < 0 ? '-' : '';
    return '$sign$formatted.00';
  }
  
  /// 証拠金等のフォーマット（Android版と同じ）
  static String formatAmount(double amount) {
    final formatted = amount.toInt().toString();
    return _addSpaces(formatted);
  }
}