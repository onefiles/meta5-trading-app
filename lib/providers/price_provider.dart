import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../utils/platform_helper.dart';

class PriceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  StreamSubscription? _priceSubscription;
  Function(String, double)? onPriceUpdate;
  
  Map<String, Map<String, double>> _prices = {
    'GBPJPY': {'bid': 195.123, 'ask': 195.126},
    'BTCJPY': {'bid': 7500000, 'ask': 7500500},
    'XAUUSD': {'bid': 2650.50, 'ask': 2650.75},
    'EURUSD': {'bid': 1.0850, 'ask': 1.0852},
    'USDJPY': {'bid': 148.25, 'ask': 148.27},
  };
  
  Map<String, Map<String, double>> get prices => _prices;
  
  void setPriceUpdateCallback(Function(String, double)? callback) {
    onPriceUpdate = callback;
  }
  
  void startPriceUpdates() {
    _apiService.startPriceUpdates();
    
    _priceSubscription = _apiService.priceStream.listen(
      (newPrices) {
        // Web版でのログ出力を制限
        if (!PlatformHelper.isWeb || kDebugMode) {
          print('PriceProvider: Received new prices: ${newPrices.keys}');
        }
        
        // 価格が変更された通貨ペアをチェック
        for (final symbol in newPrices.keys) {
          final oldPrice = _prices[symbol]?['bid'];
          final newPrice = newPrices[symbol]?['bid'];
          
          if (!PlatformHelper.isWeb || kDebugMode) {
            print('PriceProvider: $symbol - Old: $oldPrice, New: $newPrice');
          }
          
          if (oldPrice != null && newPrice != null && oldPrice != newPrice) {
            // アラートチェックのコールバックを呼び出し
            onPriceUpdate?.call(symbol, newPrice);
          }
        }
        
        _prices = newPrices;
        if (!PlatformHelper.isWeb || kDebugMode) {
          print('PriceProvider: Updated prices - GBPJPY: ${_prices['GBPJPY']}, BTCJPY: ${_prices['BTCJPY']}');
        }
        notifyListeners();
      },
      onError: (error) {
        if (!PlatformHelper.isWeb || kDebugMode) {
          print('Price stream error: $error');
        }
      },
    );
  }
  
  void stopPriceUpdates() {
    _apiService.stopPriceUpdates();
    _priceSubscription?.cancel();
    _priceSubscription = null;
  }
  
  Map<String, double> getCurrentPrice(String symbol) {
    return _prices[symbol] ?? {'bid': 0.0, 'ask': 0.0};
  }
  
  double getBid(String symbol) {
    return _prices[symbol]?['bid'] ?? 0.0;
  }
  
  double getAsk(String symbol) {
    return _prices[symbol]?['ask'] ?? 0.0;
  }
  
  @override
  void dispose() {
    stopPriceUpdates();
    _apiService.dispose();
    super.dispose();
  }
}