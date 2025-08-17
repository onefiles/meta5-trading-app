import 'package:flutter/material.dart';
import 'dart:async';
import '../models/price_alert.dart';
import '../services/database_service.dart';
import '../services/notification_service.dart';

class AlertProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final NotificationService _notificationService = NotificationService();
  final List<PriceAlert> _alerts = [];
  final Map<String, double> _previousPrices = {};

  List<PriceAlert> get alerts => _alerts;
  List<PriceAlert> get activeAlerts => _alerts.where((a) => a.status == AlertStatus.active).toList();
  List<PriceAlert> get triggeredAlerts => _alerts.where((a) => a.status == AlertStatus.triggered).toList();

  AlertProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await loadAlerts();
    await _notificationService.initialize();
  }

  Future<void> loadAlerts() async {
    try {
      _alerts.clear();
      _alerts.addAll(await _dbService.getAllAlerts());
      
      // 期限切れのアラートを無効化
      for (final alert in _alerts) {
        if (alert.isExpired && alert.status == AlertStatus.active) {
          alert.status = AlertStatus.expired;
          await _dbService.updateAlert(alert);
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading alerts: $e');
    }
  }

  Future<void> addAlert(PriceAlert alert) async {
    try {
      await _dbService.insertAlert(alert);
      _alerts.add(alert);
      notifyListeners();
    } catch (e) {
      print('Error adding alert: $e');
    }
  }

  Future<void> updateAlert(PriceAlert alert) async {
    try {
      await _dbService.updateAlert(alert);
      final index = _alerts.indexWhere((a) => a.id == alert.id);
      if (index != -1) {
        _alerts[index] = alert;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating alert: $e');
    }
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      await _dbService.deleteAlert(alertId);
      _alerts.removeWhere((a) => a.id == alertId);
      notifyListeners();
    } catch (e) {
      print('Error deleting alert: $e');
    }
  }

  void checkAlertsForPrice(String symbol, double currentPrice) {
    final previousPrice = _previousPrices[symbol];
    final symbolAlerts = _alerts.where((a) => 
      a.symbol == symbol && a.status == AlertStatus.active
    ).toList();

    for (final alert in symbolAlerts) {
      if (alert.shouldTrigger(currentPrice, previousPrice)) {
        _triggerAlert(alert, currentPrice);
      }
    }

    _previousPrices[symbol] = currentPrice;
  }

  Future<void> _triggerAlert(PriceAlert alert, double currentPrice) async {
    alert.trigger();
    await updateAlert(alert);
    
    // 通知を表示
    await _notificationService.showAlert(
      symbol: alert.symbol,
      targetPrice: alert.targetPrice,
      currentPrice: currentPrice,
      condition: alert.condition,
      note: alert.note,
    );
  }

  Future<void> enableAlert(String alertId) async {
    final alert = _alerts.firstWhere((a) => a.id == alertId);
    final updatedAlert = alert.copyWith(status: AlertStatus.active);
    await updateAlert(updatedAlert);
  }

  Future<void> disableAlert(String alertId) async {
    final alert = _alerts.firstWhere((a) => a.id == alertId);
    final updatedAlert = alert.copyWith(status: AlertStatus.disabled);
    await updateAlert(updatedAlert);
  }

  List<PriceAlert> getAlertsForSymbol(String symbol) {
    return _alerts.where((a) => a.symbol == symbol).toList();
  }

  int get activeAlertCount => activeAlerts.length;
  int get triggeredAlertCount => triggeredAlerts.length;

  Future<void> clearTriggeredAlerts() async {
    final triggered = triggeredAlerts;
    for (final alert in triggered) {
      await deleteAlert(alert.id);
    }
  }

  Future<void> clearExpiredAlerts() async {
    final expired = _alerts.where((a) => a.status == AlertStatus.expired).toList();
    for (final alert in expired) {
      await deleteAlert(alert.id);
    }
  }
}