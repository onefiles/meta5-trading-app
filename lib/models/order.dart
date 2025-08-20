import 'package:uuid/uuid.dart';

enum OrderType { buy, sell, balance, credit }

class Order {
  final String id;
  String get ticket => id;
  final String symbol;
  final OrderType type;
  final double lots;
  final double openPrice;
  double currentPrice;
  final int openTime; // Android版と同じLong型（ミリ秒タイムスタンプ）
  double profit;
  final double? stopLoss;
  final double? takeProfit;
  final double commission;
  final double swap;
  bool isActive; // Android版と同じフィールド追加

  Order({
    String? id,
    String? ticket,
    required this.symbol,
    required this.type,
    required this.lots,
    required this.openPrice,
    required this.currentPrice,
    int? openTime, // Long型タイムスタンプ
    this.stopLoss,
    this.takeProfit,
    this.commission = 0.0,
    this.swap = 0.0,
    double? profit,
    this.isActive = true, // Android版と同じデフォルト値
  })  : id = id ?? ticket ?? const Uuid().v4(),
        openTime = openTime ?? DateTime.now().millisecondsSinceEpoch,
        profit = profit ?? 0.0 {
    updateProfit();
  }

  void updatePrice(double newPrice) {
    currentPrice = newPrice;
    updateProfit();
  }

  void updateProfit() {
    final contractSize = _getContractSize();
    final priceDiff = type == OrderType.buy
        ? currentPrice - openPrice
        : openPrice - currentPrice;

    if (symbol == 'XAUUSD') {
      // GOLD: 1ロット = 100オンス
      profit = priceDiff * lots * contractSize;
    } else if (symbol == 'USDJPY') {
      // USDJPY: 1ロット = 100,000通貨
      profit = priceDiff * lots * contractSize;
    } else if (symbol == 'GBPJPY') {
      // GBPJPY: 1ロット = 100,000通貨
      profit = priceDiff * lots * contractSize;
    } else if (symbol == 'BTCJPY') {
      // BTCJPY: 1ロット = 1 BTC
      profit = priceDiff * lots * contractSize;
    } else {
      profit = priceDiff * lots * contractSize;
    }
  }

  // Android版と同じコントラクトサイズ計算
  double _getContractSize() {
    switch (symbol) {
      case 'XAUUSD':
        return 100.0; // ゴールドは100オンス単位
      case 'USDJPY':
      case 'GBPJPY':
        return 100000.0; // 100,000通貨単位
      case 'BTCJPY':
        return 1.0; // 1 BTC単位
      default:
        return 100000.0; // デフォルト
    }
  }

  String get typeText {
    switch (type) {
      case OrderType.buy:
        return 'buy';
      case OrderType.sell:
        return 'sell';
      case OrderType.balance:
        return 'balance';
      case OrderType.credit:
        return 'credit';
    }
  }

  String get symbolDisplay {
    // Android版のgetSymbolDisplayNameと同じロジック
    switch (symbol) {
      case 'XAUUSD':
        return 'GOLD';
      case 'USDJPY':
        return 'USD_JPY';
      default:
        return symbol;
    }
  }
  
  // Android版のgetFormattedProfitと同じメソッド追加
  String getFormattedProfit() {
    final sign = profit >= 0 ? '+' : '';
    return '$sign${profit.toStringAsFixed(2)}';
  }
  
  // Android版のgetTypeTextと同じメソッド追加
  String getTypeText() {
    switch (type) {
      case OrderType.buy:
        return '買い';
      case OrderType.sell:
        return '売り';
      case OrderType.balance:
        return '残高';
      case OrderType.credit:
        return 'クレジット';
    }
  }
  
  // DateTimeヘルパーメソッド（互換性のため）
  DateTime get openTimeAsDateTime => DateTime.fromMillisecondsSinceEpoch(openTime);
  
  // Android版と同じ計算メソッド
  double calculateProfit() {
    final contractSize = _getContractSize();
    switch (type) {
      case OrderType.buy:
        return (currentPrice - openPrice) * lots * contractSize;
      case OrderType.sell:
        return (openPrice - currentPrice) * lots * contractSize;
      case OrderType.balance:
      case OrderType.credit:
        return 0.0;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'type': type.index,
      'lots': lots,
      'openPrice': openPrice,
      'currentPrice': currentPrice,
      'openTime': openTime,
      'profit': profit,
      'stopLoss': stopLoss,
      'takeProfit': takeProfit,
      'commission': commission,
      'swap': swap,
      'isActive': isActive,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      symbol: json['symbol'],
      type: OrderType.values[json['type']],
      lots: json['lots']?.toDouble() ?? 0.0,
      openPrice: json['openPrice']?.toDouble() ?? 0.0,
      currentPrice: json['currentPrice']?.toDouble() ?? 0.0,
      openTime: json['openTime'],
      profit: json['profit']?.toDouble() ?? 0.0,
      stopLoss: json['stopLoss']?.toDouble(),
      takeProfit: json['takeProfit']?.toDouble(),
      commission: json['commission']?.toDouble() ?? 0.0,
      swap: json['swap']?.toDouble() ?? 0.0,
      isActive: json['isActive'] ?? true,
    );
  }
}