import 'package:uuid/uuid.dart';

enum AlertCondition {
  above,
  below,
  crossesAbove,
  crossesBelow,
}

enum AlertStatus {
  active,
  triggered,
  expired,
  disabled,
}

class PriceAlert {
  final String id;
  final String symbol;
  final double targetPrice;
  final AlertCondition condition;
  final DateTime createdTime;
  final DateTime? expiryTime;
  AlertStatus status;
  final String? note;
  DateTime? triggeredTime;

  PriceAlert({
    String? id,
    required this.symbol,
    required this.targetPrice,
    required this.condition,
    DateTime? createdTime,
    this.expiryTime,
    this.status = AlertStatus.active,
    this.note,
    this.triggeredTime,
  })  : id = id ?? const Uuid().v4(),
        createdTime = createdTime ?? DateTime.now();

  String get conditionText {
    switch (condition) {
      case AlertCondition.above:
        return '以上';
      case AlertCondition.below:
        return '以下';
      case AlertCondition.crossesAbove:
        return '上抜け';
      case AlertCondition.crossesBelow:
        return '下抜け';
    }
  }

  String get statusText {
    switch (status) {
      case AlertStatus.active:
        return 'アクティブ';
      case AlertStatus.triggered:
        return '発動済み';
      case AlertStatus.expired:
        return '期限切れ';
      case AlertStatus.disabled:
        return '無効';
    }
  }

  bool shouldTrigger(double currentPrice, double? previousPrice) {
    if (status != AlertStatus.active) return false;

    switch (condition) {
      case AlertCondition.above:
        return currentPrice >= targetPrice;
      case AlertCondition.below:
        return currentPrice <= targetPrice;
      case AlertCondition.crossesAbove:
        return previousPrice != null &&
               previousPrice < targetPrice &&
               currentPrice >= targetPrice;
      case AlertCondition.crossesBelow:
        return previousPrice != null &&
               previousPrice > targetPrice &&
               currentPrice <= targetPrice;
    }
  }

  void trigger() {
    status = AlertStatus.triggered;
    triggeredTime = DateTime.now();
  }

  bool get isExpired {
    return expiryTime != null && DateTime.now().isAfter(expiryTime!);
  }

  PriceAlert copyWith({
    String? symbol,
    double? targetPrice,
    AlertCondition? condition,
    DateTime? expiryTime,
    AlertStatus? status,
    String? note,
    DateTime? triggeredTime,
  }) {
    return PriceAlert(
      id: id,
      symbol: symbol ?? this.symbol,
      targetPrice: targetPrice ?? this.targetPrice,
      condition: condition ?? this.condition,
      createdTime: createdTime,
      expiryTime: expiryTime ?? this.expiryTime,
      status: status ?? this.status,
      note: note ?? this.note,
      triggeredTime: triggeredTime ?? this.triggeredTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'symbol': symbol,
      'target_price': targetPrice,
      'condition': condition.index,
      'created_time': createdTime.millisecondsSinceEpoch,
      'expiry_time': expiryTime?.millisecondsSinceEpoch,
      'status': status.index,
      'note': note,
      'triggered_time': triggeredTime?.millisecondsSinceEpoch,
    };
  }

  factory PriceAlert.fromMap(Map<String, dynamic> map) {
    return PriceAlert(
      id: map['id'],
      symbol: map['symbol'],
      targetPrice: map['target_price'],
      condition: AlertCondition.values[map['condition']],
      createdTime: DateTime.fromMillisecondsSinceEpoch(map['created_time']),
      expiryTime: map['expiry_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expiry_time'])
          : null,
      status: AlertStatus.values[map['status']],
      note: map['note'],
      triggeredTime: map['triggered_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['triggered_time'])
          : null,
    );
  }
}