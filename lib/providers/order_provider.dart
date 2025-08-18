import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/trade_history.dart';
import '../services/database_service.dart';
import '../services/price_service.dart';
import '../services/profit_calculator.dart';
import 'price_provider.dart';
import 'history_provider.dart';

class OrderProvider extends ChangeNotifier {
  final List<Order> _orders = [];
  final List<TradeHistory> _history = [];
  final DatabaseService _db = DatabaseService();
  final PriceService _priceService = PriceService();
  PriceProvider? _priceProvider;
  HistoryProvider? _historyProvider;
  
  double _balance = 1000000.0; // 初期残高100万円
  double _credit = 200000.0; // クレジット額（Android版と同じ）
  Timer? _priceUpdateTimer;

  List<Order> get orders => _orders;
  List<TradeHistory> get history => _history;
  double get balance => _balance;
  double get credit => _credit;

  double get equity {
    final totalProfit = _orders.fold(0.0, (sum, order) => sum + order.profit);
    return ProfitCalculator.calculateEquity(
      balance: _balance + _credit, // Android版と同じ：残高+クレジット
      totalProfit: totalProfit,
    );
  }

  double get requiredMargin {
    return _orders.fold(0.0, (sum, order) {
      return sum + ProfitCalculator.calculateRequiredMargin(
        symbol: order.symbol,
        lots: order.lots,
        price: order.openPrice,
      );
    });
  }

  double get freeMargin => equity - requiredMargin;

  double get marginLevel {
    return ProfitCalculator.calculateMarginLevel(
      equity: equity,
      requiredMargin: requiredMargin,
    );
  }

  OrderProvider() {
    _initializeProvider();
  }
  
  void setPriceProvider(PriceProvider priceProvider) {
    _priceProvider = priceProvider;
  }
  
  void setHistoryProvider(HistoryProvider? historyProvider) {
    _historyProvider = historyProvider;
  }
  
  Future<void> _initializeProvider() async {
    await _loadAccountData(); // SharedPreferencesからアカウントデータを読み込み
    await _loadOrdersFromDatabase();
    await _loadHistory();
    _loadTestData();
  }
  
  // SharedPreferencesからアカウントデータを読み込み（Android版と同じ）
  Future<void> _loadAccountData() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getDouble('balance') ?? 1000000.0;
    _credit = prefs.getDouble('credit') ?? 200000.0;
    
    print('OrderProvider: Account data loaded - Balance: $_balance, Credit: $_credit');
    notifyListeners(); // UIに即座に反映
  }

  // 実際のMT4価格を取得
  Map<String, Map<String, double>> get _currentPrices {
    if (_priceProvider != null) {
      return _priceProvider!.prices;
    }
    // フォールバック価格
    return {
      'GBPJPY': {'bid': 195.123, 'ask': 195.126},
      'BTCJPY': {'bid': 7500000, 'ask': 7500500},
      'XAUUSD': {'bid': 2650.50, 'ask': 2650.75},
      'EURUSD': {'bid': 1.0850, 'ask': 1.0852},
      'USDJPY': {'bid': 148.25, 'ask': 148.27},
    };
  }
  
  void _loadTestData() {
    // データベースが空の場合のみテストデータを追加
    if (_orders.isEmpty) {
      final order1 = Order(
        ticket: DateTime.now().millisecondsSinceEpoch.toString(),
        symbol: 'GBPJPY',
        type: OrderType.buy,
        lots: 0.50,
        openPrice: 195.123,
        currentPrice: 195.126,
        openTime: DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch,
      );
      
      final order2 = Order(
        ticket: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        symbol: 'BTCJPY',
        type: OrderType.sell,
        lots: 0.10,
        openPrice: 7500000,
        currentPrice: 7500000,
        openTime: DateTime.now().subtract(const Duration(minutes: 30)).millisecondsSinceEpoch,
      );
      
      // データベースに保存
      addOrder(order1);
      addOrder(order2);
    }
  }

  Future<void> _loadHistory() async {
    try {
      _history.clear();
      _history.addAll(await _db.getTradeHistory());
      notifyListeners();
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  void startPriceUpdates() {
    _priceUpdateTimer?.cancel();
    _priceUpdateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _updatePrices();
    });
  }

  void stopPriceUpdates() {
    _priceUpdateTimer?.cancel();
  }

  void _updatePrices() {
    bool hasUpdates = false;
    
    // 各注文の現在価格と損益を更新（実際のMT4価格を使用）
    for (int i = 0; i < _orders.length; i++) {
      final order = _orders[i];
      final currentPrice = _getCurrentPrice(order.symbol, order.type);
      
      final newProfit = ProfitCalculator.calculateProfit(
        symbol: order.symbol,
        orderType: order.type,
        lots: order.lots,
        openPrice: order.openPrice,
        currentPrice: currentPrice,
      );
      
      if ((currentPrice - order.currentPrice).abs() > 0.001 || 
          (newProfit - order.profit).abs() > 0.01) {
        final updatedOrder = Order(
          ticket: order.ticket,
          symbol: order.symbol,
          type: order.type,
          lots: order.lots,
          openPrice: order.openPrice,
          currentPrice: currentPrice,
          stopLoss: order.stopLoss,
          takeProfit: order.takeProfit,
          commission: order.commission,
          swap: order.swap,
          profit: newProfit,
          openTime: order.openTime,
        );
        
        _orders[i] = updatedOrder;
        
        // データベースを更新（非同期で実行）
        _db.updateOrder(updatedOrder).catchError((e) {
          print('Error updating order in database: $e');
        });
        
        hasUpdates = true;
      }
    }
    
    if (hasUpdates) {
      notifyListeners();
    }
  }
  
  double _getCurrentPrice(String symbol, OrderType orderType) {
    final prices = _currentPrices[symbol];
    if (prices == null) return 0.0;
    
    // 買いポジションは現在のBid価格で決済、売りポジションはAsk価格で決済
    return orderType == OrderType.buy ? prices['bid']! : prices['ask']!;
  }
  
  void _updateOrderProfits() {
    for (int i = 0; i < _orders.length; i++) {
      final order = _orders[i];
      final profit = ProfitCalculator.calculateProfit(
        symbol: order.symbol,
        orderType: order.type,
        lots: order.lots,
        openPrice: order.openPrice,
        currentPrice: order.currentPrice,
      );
      
      _orders[i] = Order(
        ticket: order.ticket,
        symbol: order.symbol,
        type: order.type,
        lots: order.lots,
        openPrice: order.openPrice,
        currentPrice: order.currentPrice,
        stopLoss: order.stopLoss,
        takeProfit: order.takeProfit,
        commission: order.commission,
        swap: order.swap,
        profit: profit,
        openTime: order.openTime,
      );
    }
  }

  Future<void> addOrder(Order order) async {
    try {
      print('OrderProvider: Adding order - Symbol: ${order.symbol}, Type: ${order.type}, Lots: ${order.lots}, Price: ${order.openPrice}');
      
      // Android版と同じ：注文をアクティブリストに追加
      _orders.add(order);
      
      print('OrderProvider: Order added successfully. Total orders: ${_orders.length}');
      
      // 即座にUIを更新
      notifyListeners();
      
      // 価格更新を開始（まだ開始していない場合）
      if (_priceUpdateTimer == null) {
        startPriceUpdates();
      }
      
      print('OrderProvider: Order addition completed');
    } catch (e) {
      print('Error adding order: $e');
    }
  }
  
  Future<void> _loadOrdersFromDatabase() async {
    try {
      // Web環境ではsqfliteが動作しないため、コメントアウト
      // _orders.clear();
      // _orders.addAll(await _db.getAllOrders());
      _updateOrderProfits();
      notifyListeners();
    } catch (e) {
      print('Error loading orders from database: $e');
    }
  }

  void removeOrder(Order order) async {
    try {
      // 残高を更新
      _balance += order.profit;
      
      // SharedPreferencesに残高を保存
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('balance', _balance);
      
      // メモリ上の履歴に追加（Web環境対応）
      final historyItem = TradeHistory(
        ticket: order.ticket,
        symbol: order.symbol,
        type: order.type,
        lots: order.lots,
        openPrice: order.openPrice,
        closePrice: order.currentPrice,
        openTime: order.openTime,
        closeTime: DateTime.now().millisecondsSinceEpoch,
        profit: order.profit,
        commission: order.commission,
        swap: order.swap,
      );
      
      _history.insert(0, historyItem); // 最新の履歴を先頭に追加
      
      // HistoryProviderにも追加（履歴画面で表示されるように）
      if (_historyProvider != null) {
        _historyProvider!.addHistory(historyItem);
      }
      
      // オーダーをリストから削除
      _orders.removeWhere((o) => o.ticket == order.ticket);
      
      // 即座にUIを更新
      notifyListeners();
      
      // データベースへの保存は非同期で試みる（エラーは無視）
      _db.moveOrderToHistory(order, order.currentPrice).catchError((e) {
        print('Database save failed (Web environment): $e');
      });
      
      print('Order closed: ${order.symbol} - Profit: ${order.profit.toStringAsFixed(2)}');
    } catch (e) {
      print('Error removing order: $e');
    }
  }

  // 残高操作メソッド（Android版と同じロジック）
  Future<void> updateBalance(double newBalance) async {
    _balance = newBalance;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', _balance);
    notifyListeners();
  }

  Future<void> addToBalance(double amount) async {
    _balance += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', _balance);
    notifyListeners();
  }
  
  // クレジット操作メソッド（新規追加）
  Future<void> updateCredit(double newCredit) async {
    _credit = newCredit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('credit', _credit);
    notifyListeners();
    print('Credit updated to: $_credit');
  }

  Future<void> resetAccount() async {
    print('OrderProvider: Resetting account');
    
    // Android版と同じ：残高とクレジットを0に設定
    _balance = 0.0;
    _credit = 0.0;
    
    // SharedPreferencesに保存
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', _balance);
    await prefs.setDouble('credit', _credit);
    
    print('OrderProvider: Account reset - Balance: $_balance, Credit: $_credit');
    
    // 即座にUIを更新
    notifyListeners();
  }

  // クレジット値を取得（他の画面からも呼び出し可能）
  Future<double> getCurrentCredit() async {
    final prefs = await SharedPreferences.getInstance();
    _credit = prefs.getDouble('credit') ?? 200000.0;
    return _credit;
  }
  
  // 残高値を取得（他の画面からも呼び出し可能）
  Future<double> getCurrentBalance() async {
    final prefs = await SharedPreferences.getInstance();
    _balance = prefs.getDouble('balance') ?? 1000000.0;
    return _balance;
  }

  @override
  void dispose() {
    stopPriceUpdates();
    super.dispose();
  }
}