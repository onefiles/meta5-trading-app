import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'order.dart';

class TradeHistory {
  final String id;
  String get ticket => id;
  final String symbol;
  final OrderType type;
  final double lots;
  final double openPrice;
  final double closePrice;
  final double profit;
  final int openTime; // Android版と同じLong型
  final int closeTime; // Android版と同じLong型
  final double? stopLoss;
  final double? takeProfit;
  final double commission;
  final double swap;
  final String? description; // カスタムメッセージ（Balance/Credit用）
  
  // Android版と同じ持続時間計算
  Duration get holdingDuration {
    final closeDateTime = DateTime.fromMillisecondsSinceEpoch(closeTime);
    final openDateTime = DateTime.fromMillisecondsSinceEpoch(openTime);
    return closeDateTime.difference(openDateTime);
  }

  TradeHistory({
    String? id,
    String? ticket,
    required this.symbol,
    required this.type,
    required this.lots,
    required this.openPrice,
    required this.closePrice,
    required this.profit,
    int? openTime, // Long型タイムスタンプ
    int? closeTime, // Long型タイムスタンプ
    this.stopLoss,
    this.takeProfit,
    this.commission = 0.0,
    this.swap = 0.0,
    this.description,
  }) : id = id ?? ticket ?? const Uuid().v4(),
       openTime = openTime ?? DateTime.now().millisecondsSinceEpoch,
       closeTime = closeTime ?? DateTime.now().millisecondsSinceEpoch;

  String get formattedProfit {
    final sign = profit >= 0 ? '' : '';
    return '$sign${profit.toStringAsFixed(2)}';
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

  String get symbolDisplayName {
    switch (symbol) {
      case 'XAUUSD':
        return 'GOLD';
      case 'USDJPY':
        return 'USD_JPY';
      default:
        return symbol;
    }
  }

  String get formattedDuration {
    final totalSeconds = holdingDuration.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(1, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
  }

  String get formattedCloseTime {
    // FXGT時間（東ヨーロッパ時間）GMT+2/+3
    final time = DateTime.fromMillisecondsSinceEpoch(closeTime);
    final fxgtTime = time.toUtc().add(const Duration(hours: 3)); // 夏時間
    return DateFormat('yyyy/MM/dd HH:mm:ss').format(fxgtTime);
  }

  String get formattedOpenTime {
    // FXGT時間（東ヨーロッパ時間）GMT+2/+3
    final openDateTime = DateTime.fromMillisecondsSinceEpoch(openTime);
    final fxgtTime = openDateTime.toUtc().add(const Duration(hours: 3)); // 夏時間
    return DateFormat('MM/dd HH:mm:ss').format(fxgtTime);
  }
  
  // DateTimeヘルパーメソッド（互換性のため）
  DateTime get openTimeAsDateTime => DateTime.fromMillisecondsSinceEpoch(openTime);
  DateTime get closeTimeAsDateTime => DateTime.fromMillisecondsSinceEpoch(closeTime);

  double get priceMovement {
    switch (type) {
      case OrderType.buy:
        return closePrice - openPrice;
      case OrderType.sell:
        return openPrice - closePrice;
      case OrderType.balance:
      case OrderType.credit:
        return 0.0;
    }
  }

  String get formattedPriceMovement {
    final movement = priceMovement;
    final sign = movement >= 0 ? '+' : '';
    return '$sign${movement.toStringAsFixed(2)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'type': type.index,
      'lots': lots,
      'openPrice': openPrice,
      'closePrice': closePrice,
      'profit': profit,
      'openTime': openTime,
      'closeTime': closeTime,
      'description': description,
    };
  }

  factory TradeHistory.fromJson(Map<String, dynamic> json) {
    return TradeHistory(
      id: json['id'],
      symbol: json['symbol'],
      type: OrderType.values[json['type']],
      lots: json['lots'],
      openPrice: json['openPrice'],
      closePrice: json['closePrice'],
      profit: json['profit'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      description: json['description'],
    );
  }
}