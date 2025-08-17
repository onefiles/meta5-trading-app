import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/order.dart';
import '../models/trade_history.dart';
import '../models/price_alert.dart';

class DatabaseService {
  static Database? _database;
  static const String dbName = 'meta5_trading.db';
  static const int dbVersion = 1;

  // テーブル名
  static const String ordersTable = 'orders';
  static const String tradeHistoryTable = 'trade_history';
  static const String alertsTable = 'price_alerts';

  // シングルトンパターン
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), dbName);
    
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // オーダーテーブル作成
    await db.execute('''
      CREATE TABLE $ordersTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket TEXT UNIQUE NOT NULL,
        symbol TEXT NOT NULL,
        type INTEGER NOT NULL,
        lots REAL NOT NULL,
        open_price REAL NOT NULL,
        current_price REAL NOT NULL,
        stop_loss REAL,
        take_profit REAL,
        commission REAL DEFAULT 0.0,
        swap REAL DEFAULT 0.0,
        profit REAL DEFAULT 0.0,
        open_time INTEGER NOT NULL,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // 取引履歴テーブル作成
    await db.execute('''
      CREATE TABLE $tradeHistoryTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ticket TEXT UNIQUE NOT NULL,
        symbol TEXT NOT NULL,
        type INTEGER NOT NULL,
        lots REAL NOT NULL,
        open_price REAL NOT NULL,
        close_price REAL,
        stop_loss REAL,
        take_profit REAL,
        commission REAL DEFAULT 0.0,
        swap REAL DEFAULT 0.0,
        profit REAL DEFAULT 0.0,
        open_time INTEGER NOT NULL,
        close_time INTEGER,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // アラートテーブル作成
    await db.execute('''
      CREATE TABLE $alertsTable (
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL,
        target_price REAL NOT NULL,
        condition INTEGER NOT NULL,
        created_time INTEGER NOT NULL,
        expiry_time INTEGER,
        status INTEGER NOT NULL,
        note TEXT,
        triggered_time INTEGER
      )
    ''');

    // インデックス作成
    await db.execute('CREATE INDEX idx_orders_symbol ON $ordersTable(symbol)');
    await db.execute('CREATE INDEX idx_orders_open_time ON $ordersTable(open_time)');
    await db.execute('CREATE INDEX idx_history_symbol ON $tradeHistoryTable(symbol)');
    await db.execute('CREATE INDEX idx_history_close_time ON $tradeHistoryTable(close_time)');
    await db.execute('CREATE INDEX idx_alerts_symbol ON $alertsTable(symbol)');
    await db.execute('CREATE INDEX idx_alerts_status ON $alertsTable(status)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 将来のバージョンアップ対応
  }
  
  // オーダー関連メソッド
  Future<void> insertOrder(Order order) async {
    final db = await database;
    await db.insert(
      ordersTable,
      {
        'ticket': order.ticket,
        'symbol': order.symbol,
        'type': order.type.index,
        'lots': order.lots,
        'open_price': order.openPrice,
        'current_price': order.currentPrice,
        'stop_loss': order.stopLoss,
        'take_profit': order.takeProfit,
        'commission': order.commission,
        'swap': order.swap,
        'profit': order.profit,
        'open_time': order.openTime,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Order>> getAllOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      ordersTable,
      orderBy: 'open_time DESC',
    );

    return maps.map((map) => _orderFromMap(map)).toList();
  }

  Future<void> updateOrder(Order order) async {
    final db = await database;
    await db.update(
      ordersTable,
      {
        'current_price': order.currentPrice,
        'profit': order.profit,
        'swap': order.swap,
      },
      where: 'ticket = ?',
      whereArgs: [order.ticket],
    );
  }

  Future<void> deleteOrder(String ticket) async {
    final db = await database;
    await db.delete(
      ordersTable,
      where: 'ticket = ?',
      whereArgs: [ticket],
    );
  }

  // 取引履歴関連メソッド
  Future<void> insertTradeHistory(TradeHistory history) async {
    final db = await database;
    await db.insert(
      tradeHistoryTable,
      {
        'ticket': history.ticket,
        'symbol': history.symbol,
        'type': history.type.index,
        'lots': history.lots,
        'open_price': history.openPrice,
        'close_price': history.closePrice,
        'stop_loss': history.stopLoss,
        'take_profit': history.takeProfit,
        'commission': history.commission,
        'swap': history.swap,
        'profit': history.profit,
        'open_time': history.openTime,
        'close_time': history.closeTime,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TradeHistory>> getTradeHistory({
    DateTime? fromDate,
    DateTime? toDate,
    String? symbol,
    int? limit,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (fromDate != null) {
      whereClause += 'close_time >= ?';
      whereArgs.add(fromDate.millisecondsSinceEpoch);
    }
    
    if (toDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'close_time <= ?';
      whereArgs.add(toDate.millisecondsSinceEpoch);
    }
    
    if (symbol != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'symbol = ?';
      whereArgs.add(symbol);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      tradeHistoryTable,
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'close_time DESC',
      limit: limit,
    );

    return maps.map((map) => _tradeHistoryFromMap(map)).toList();
  }

  // オーダーをヒストリーに移動
  Future<void> moveOrderToHistory(Order order, double closePrice) async {
    final history = TradeHistory(
      ticket: order.ticket,
      symbol: order.symbol,
      type: order.type,
      lots: order.lots,
      openPrice: order.openPrice,
      closePrice: closePrice,
      stopLoss: order.stopLoss,
      takeProfit: order.takeProfit,
      commission: order.commission,
      swap: order.swap,
      profit: order.profit,
      openTime: order.openTime,
      closeTime: DateTime.now().millisecondsSinceEpoch,
    );

    // トランザクション内で実行
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        tradeHistoryTable,
        {
          'ticket': history.ticket,
          'symbol': history.symbol,
          'type': history.type.index,
          'lots': history.lots,
          'open_price': history.openPrice,
          'close_price': history.closePrice,
          'stop_loss': history.stopLoss,
          'take_profit': history.takeProfit,
          'commission': history.commission,
          'swap': history.swap,
          'profit': history.profit,
          'open_time': history.openTime,
          'close_time': history.closeTime,
        },
      );

      await txn.delete(
        ordersTable,
        where: 'ticket = ?',
        whereArgs: [order.ticket],
      );
    });
  }

  // ヘルパーメソッド
  Order _orderFromMap(Map<String, dynamic> map) {
    return Order(
      id: map['ticket'],
      symbol: map['symbol'],
      type: OrderType.values[map['type']],
      lots: map['lots'],
      openPrice: map['open_price'],
      currentPrice: map['current_price'],
      stopLoss: map['stop_loss'],
      takeProfit: map['take_profit'],
      commission: map['commission'] ?? 0.0,
      swap: map['swap'] ?? 0.0,
      openTime: map['open_time'],
    );
  }

  TradeHistory _tradeHistoryFromMap(Map<String, dynamic> map) {
    return TradeHistory(
      ticket: map['ticket'],
      symbol: map['symbol'],
      type: OrderType.values[map['type']],
      lots: map['lots'],
      openPrice: map['open_price'],
      closePrice: map['close_price'],
      stopLoss: map['stop_loss'],
      takeProfit: map['take_profit'],
      commission: map['commission'] ?? 0.0,
      swap: map['swap'] ?? 0.0,
      profit: map['profit'] ?? 0.0,
      openTime: map['open_time'],
      closeTime: map['close_time'],
    );
  }

  // アラート関連メソッド
  Future<void> insertAlert(PriceAlert alert) async {
    final db = await database;
    await db.insert(
      alertsTable,
      alert.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PriceAlert>> getAllAlerts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      alertsTable,
      orderBy: 'created_time DESC',
    );
    return maps.map((map) => PriceAlert.fromMap(map)).toList();
  }

  Future<void> updateAlert(PriceAlert alert) async {
    final db = await database;
    await db.update(
      alertsTable,
      alert.toMap(),
      where: 'id = ?',
      whereArgs: [alert.id],
    );
  }

  Future<void> deleteAlert(String alertId) async {
    final db = await database;
    await db.delete(
      alertsTable,
      where: 'id = ?',
      whereArgs: [alertId],
    );
  }

  Future<List<PriceAlert>> getAlertsForSymbol(String symbol) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      alertsTable,
      where: 'symbol = ?',
      whereArgs: [symbol],
      orderBy: 'created_time DESC',
    );
    return maps.map((map) => PriceAlert.fromMap(map)).toList();
  }

  Future<List<PriceAlert>> getActiveAlerts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      alertsTable,
      where: 'status = ?',
      whereArgs: [AlertStatus.active.index],
      orderBy: 'created_time DESC',
    );
    return maps.map((map) => PriceAlert.fromMap(map)).toList();
  }

  // データベースクリア（テスト用）
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(ordersTable);
    await db.delete(tradeHistoryTable);
    await db.delete(alertsTable);
  }

  // データベースクローズ
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}