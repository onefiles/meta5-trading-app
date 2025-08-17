import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/price_alert.dart';

class NotificationService {
  static NotificationService? _instance;
  BuildContext? _context;

  NotificationService._internal();

  factory NotificationService() {
    return _instance ??= NotificationService._internal();
  }

  Future<void> initialize() async {
    // 通知サービスの初期化（実際のアプリでは flutter_local_notifications などを使用）
    print('Notification service initialized');
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> showAlert({
    required String symbol,
    required double targetPrice,
    required double currentPrice,
    required AlertCondition condition,
    String? note,
  }) async {
    // バイブレーション
    await HapticFeedback.vibrate();

    // サウンド（実際のアプリでは音声ファイルを再生）
    await SystemSound.play(SystemSoundType.alert);

    // アプリ内通知（スナックバー）
    if (_context != null) {
      final messenger = ScaffoldMessenger.of(_context!);
      final message = _buildAlertMessage(symbol, targetPrice, currentPrice, condition, note);
      
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: '確認',
            textColor: Colors.white,
            onPressed: () {
              messenger.hideCurrentSnackBar();
            },
          ),
        ),
      );
    }

    print('🚨 価格アラート発動: $symbol @ $currentPrice (目標: $targetPrice)');
  }

  String _buildAlertMessage(
    String symbol,
    double targetPrice,
    double currentPrice,
    AlertCondition condition,
    String? note,
  ) {
    final conditionText = condition == AlertCondition.above
        ? '以上'
        : condition == AlertCondition.below
        ? '以下'
        : condition == AlertCondition.crossesAbove
        ? '上抜け'
        : '下抜け';

    String message = '$symbol が ${_formatPrice(targetPrice)} $conditionText に到達しました';
    message += '\n現在価格: ${_formatPrice(currentPrice)}';
    
    if (note != null && note.isNotEmpty) {
      message += '\nメモ: $note';
    }

    return message;
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(2);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    // 実際のアプリでは flutter_local_notifications を使用してプッシュ通知を送信
    print('Notification: $title - $body');
    
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(body),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> cancelAllNotifications() async {
    // 実際のアプリでは全ての通知をキャンセル
    print('All notifications cancelled');
  }

  Future<void> cancelNotification(int id) async {
    // 実際のアプリでは特定の通知をキャンセル
    print('Notification $id cancelled');
  }
}