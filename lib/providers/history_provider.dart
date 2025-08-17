import 'package:flutter/material.dart';
import '../models/trade_history.dart';
import '../models/order.dart';
import '../services/database_service.dart';

class HistoryProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final List<TradeHistory> _history = [];
  
  List<TradeHistory> get history => _history;
  
  HistoryProvider() {
    _initializeProvider();
  }
  
  Future<void> _initializeProvider() async {
    await loadHistory();
    if (_history.isEmpty) {
      _loadTestData();
    }
  }
  
  void _loadTestData() {
    // テストデータをデータベースに保存
    final testHistory = [
      TradeHistory(
        ticket: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: 'GBPJPY',
        type: OrderType.buy,
        lots: 0.50,
        openPrice: 195.000,
        closePrice: 195.500,
        profit: 50000,
        openTime: DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
        closeTime: DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch,
      ),
      TradeHistory(
        ticket: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        symbol: 'BTCJPY',
        type: OrderType.sell,
        lots: 0.10,
        openPrice: 7500000,
        closePrice: 7450000,
        profit: 5000,
        openTime: DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        closeTime: DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch,
      ),
      TradeHistory(
        ticket: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        symbol: 'BALANCE',
        type: OrderType.balance,
        lots: 0,
        openPrice: 0,
        closePrice: 0,
        profit: 1000000,
        openTime: DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch,
        closeTime: DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch,
      ),
    ];
    
    for (final history in testHistory) {
      addHistory(history);
    }
  }
  
  Future<void> loadHistory() async {
    try {
      _history.clear();
      // Web環境ではSQLiteが動作しないため、メモリ管理のみ
      // _history.addAll(await _dbService.getTradeHistory());
      print('HistoryProvider: History initialized (Web environment)');
      notifyListeners();
    } catch (e) {
      print('Error loading history: $e');
    }
  }
  
  List<TradeHistory> getFilteredHistory(String period) {
    final now = DateTime.now();
    DateTime startDate;
    
    switch (period) {
      case 'day':
        startDate = now.subtract(const Duration(days: 1));
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'three_months':
        startDate = now.subtract(const Duration(days: 90));
        break;
      default:
        return _history;
    }
    
    return _history.where((h) => h.closeTimeAsDateTime.isAfter(startDate)).toList();
  }
  
  Future<void> addHistory(TradeHistory history) async {
    try {
      print('HistoryProvider: Adding history - Symbol: ${history.symbol}, Type: ${history.type}, Profit: ${history.profit}');
      
      // Web環境ではメモリのみで管理（SQLiteが動作しないため）
      // await _dbService.insertTradeHistory(history);
      
      _history.insert(0, history); // 新しい履歴を先頭に追加
      notifyListeners();
      
      print('HistoryProvider: History added successfully. Total histories: ${_history.length}');
    } catch (e) {
      print('Error adding history: $e');
    }
  }
  
  Future<void> deleteHistory(String ticket) async {
    try {
      // Web環境ではメモリ管理のみ
      // await _dbService.deleteOrder(ticket);
      _history.removeWhere((h) => h.ticket == ticket);
      notifyListeners();
      print('HistoryProvider: History deleted for ticket: $ticket');
    } catch (e) {
      print('Error deleting history: $e');
    }
  }
  
  // 特定期間の履歴を取得
  Future<void> loadHistoryByDateRange({
    DateTime? fromDate,
    DateTime? toDate,
    String? symbol,
  }) async {
    try {
      _history.clear();
      _history.addAll(await _dbService.getTradeHistory(
        fromDate: fromDate,
        toDate: toDate,
        symbol: symbol,
      ));
      notifyListeners();
    } catch (e) {
      print('Error loading filtered history: $e');
    }
  }
  
  // 総損益計算
  double get totalProfit {
    return _history.fold(0.0, (sum, h) => sum + h.profit);
  }
  
  // 勝率計算
  double get winRate {
    if (_history.isEmpty) return 0.0;
    final winCount = _history.where((h) => h.profit > 0).length;
    return (winCount / _history.length) * 100;
  }
  
  // 取引回数
  int get tradeCount => _history.length;
  
  // 最大損益
  double get maxProfit {
    if (_history.isEmpty) return 0.0;
    return _history.map((h) => h.profit).reduce((a, b) => a > b ? a : b);
  }
  
  // 最大损失
  double get maxLoss {
    if (_history.isEmpty) return 0.0;
    return _history.map((h) => h.profit).reduce((a, b) => a < b ? a : b);
  }
}