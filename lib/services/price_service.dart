import 'dart:convert';
import 'package:http/http.dart' as http;

class PriceService {
  static const String baseUrl = 'https://jpn225.jp/meta5/api';
  static const String apiKey = 'meta5-api-key-2024';
  
  Future<Map<String, double>?> getLatestPrice(String symbol) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/latest-price.php?api_key=$apiKey&symbol=$symbol'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return {
            'bid': double.parse(data['data']['bid'].toString()),
            'ask': double.parse(data['data']['ask'].toString()),
          };
        }
      }
    } catch (e) {
      print('Error fetching price: $e');
    }
    
    // フォールバック値を返す
    return _getFallbackPrice(symbol);
  }
  
  Map<String, double> _getFallbackPrice(String symbol) {
    switch (symbol) {
      case 'GBPJPY':
        return {'bid': 195.123, 'ask': 195.456};
      case 'BTCJPY':
        return {'bid': 7450000, 'ask': 7500000};
      case 'XAUUSD':
        return {'bid': 3325.50, 'ask': 3325.80};
      case 'USDJPY':
        return {'bid': 150.123, 'ask': 150.456};
      default:
        return {'bid': 100.0, 'ask': 100.1};
    }
  }
  
  Future<bool> sendPrice(String symbol, double bid, double ask) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/price.php'),
        body: {
          'symbol': symbol,
          'bid': bid.toString(),
          'ask': ask.toString(),
          'api_key': apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
    } catch (e) {
      print('Error sending price: $e');
    }
    return false;
  }
}