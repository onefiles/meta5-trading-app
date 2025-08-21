import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/platform_helper.dart';

class ApiService {
  static const String baseUrl = 'https://jpn225.jp/meta5/api';
  static const String apiKey = 'meta5-api-key-2024';
  
  // フォールバック用のデフォルト価格
  static const Map<String, Map<String, double>> defaultPrices = {
    'GBPJPY': {'bid': 195.123, 'ask': 195.126},
    'BTCJPY': {'bid': 7500000, 'ask': 7500500},
    'XAUUSD': {'bid': 2650.50, 'ask': 2650.75},
    'EURUSD': {'bid': 1.0850, 'ask': 1.0852},
    'USDJPY': {'bid': 148.25, 'ask': 148.27},
  };

  // シングルトンパターン
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Timer? _priceUpdateTimer;
  StreamController<Map<String, Map<String, double>>>? _priceStreamController;
  int _updateDelayMs = 100; // Android版と同じms単位
  Map<String, Map<String, double>> _lastPriceData = {};
  bool _isConnected = true;
  
  // 更新速度のオプション（Android版と同じ5段階）
  static const Map<String, int> updateSpeeds = {
    '超高速': 50,
    '高速': 100,
    '通常': 200,
    '低速': 500,
    '超低速': 1000,
  };

  Stream<Map<String, Map<String, double>>> get priceStream {
    _priceStreamController ??= StreamController<Map<String, Map<String, double>>>.broadcast();
    return _priceStreamController!.stream;
  }
  
  int get updateDelayMs => _updateDelayMs;
  bool get isConnected => _isConnected;
  
  void setUpdateSpeed(int delayMs) {
    _updateDelayMs = delayMs;
    if (_priceUpdateTimer != null) {
      // タイマーが動作中なら再起動
      startPriceUpdates();
    }
    print('Price update speed changed to ${delayMs}ms');
  }
  
  void setUpdateSpeedByName(String speedName) {
    final delayMs = updateSpeeds[speedName];
    if (delayMs != null) {
      setUpdateSpeed(delayMs);
    }
  }

  void startPriceUpdates() {
    _priceUpdateTimer?.cancel();
    
    // 初期価格として前回取得した価格またはデフォルト価格を送信
    if (_lastPriceData.isEmpty) {
      _lastPriceData = Map.from(defaultPrices);
    }
    _priceStreamController?.add(_lastPriceData);
    
    _priceUpdateTimer = Timer.periodic(Duration(milliseconds: _updateDelayMs), (timer) {
      _fetchLatestPrice();
    });
    
    print('Price updates started with ${_updateDelayMs}ms interval');
  }

  void stopPriceUpdates() {
    _priceUpdateTimer?.cancel();
    _priceUpdateTimer = null;
  }
  
  void manualUpdate() {
    // 手動で価格を更新
    _fetchLatestPrice();
  }
  
  // 現在の価格を取得（Android版のgetCurrentPriceと同等）
  Map<String, double>? getCurrentPrice(String symbol) {
    return _lastPriceData[symbol];
  }

  // 実際のAPI呼び出しで価格を取得（Android版と同じロジック）
  Future<void> _fetchLatestPrice() async {
    try {
      final uri = Uri.parse('$baseUrl/latest-price.php').replace(queryParameters: {
        'api_key': apiKey,
      });
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final newPriceData = <String, Map<String, double>>{};
          
          // Android版と同じデータ構造で処理
          for (final entry in jsonData['data'].entries) {
            final symbol = entry.key;
            final priceData = entry.value;
            
            if (priceData['error'] == null) {
              newPriceData[symbol] = {
                'bid': priceData['bid'].toDouble(),
                'ask': priceData['ask'].toDouble(),
              };
            }
          }
          
          if (newPriceData.isNotEmpty) {
            _lastPriceData = newPriceData;
            _isConnected = true;
            _priceStreamController?.add(newPriceData);
            print('Price updated successfully: ${newPriceData.keys}');
            print('GBPJPY: ${newPriceData['GBPJPY']}');
            print('BTCJPY: ${newPriceData['BTCJPY']}');
          }
        } else {
          throw Exception('API response error: invalid data');
        }
      } else {
        throw Exception('API response error: ${response.statusCode}');
      }
    } catch (e) {
      if (!PlatformHelper.isWeb || kDebugMode) {
        print('Price fetch error: $e');
      }
      _isConnected = false;
      
      // エラー時は古い価格データを表示継続（Android版と同じ挙動）
      if (_lastPriceData.isNotEmpty) {
        _priceStreamController?.add(_lastPriceData);
      } else {
        // 初回エラー時はデフォルト価格を使用
        _lastPriceData = Map.from(defaultPrices);
        _priceStreamController?.add(_lastPriceData);
      }
      
      // 1分後にリトライ（Android版と同じ）
      if (!PlatformHelper.isWeb || kDebugMode) {
        print('Retrying in 1 minute...');
      }
      Timer(const Duration(minutes: 1), () {
        if (_priceUpdateTimer?.isActive == true) {
          _fetchLatestPrice();
        }
      });
    }
  }

  Future<Map<String, dynamic>?> fetchPrices() async {
    try {
      final uri = Uri.parse('$baseUrl/latest-price.php').replace(queryParameters: {
        'api_key': apiKey,
      });
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchHistoricalData({
    required String symbol,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/history.php'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'symbol': symbol,
          'from': from.toIso8601String(),
          'to': to.toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('API Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }

  void dispose() {
    _priceUpdateTimer?.cancel();
    _priceStreamController?.close();
  }
}