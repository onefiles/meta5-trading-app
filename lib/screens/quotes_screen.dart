import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/platform_helper.dart';
import 'dart:math' show Random;
import 'package:provider/provider.dart';
import 'quotes_screen_ios.dart';
import '../providers/price_provider.dart';
import 'order_screen.dart';
import 'chart_screen.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({Key? key}) : super(key: key);

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  final List<String> availableSymbols = [
    'GBPJPY', 'BTCJPY', 'XAUUSD', 'EURUSD', 'USDJPY',
    'EURJPY', 'AUDJPY', 'NZDJPY', 'CADJPY', 'CHFJPY',
  ];
  
  List<String> selectedSymbols = ['GBPJPY', 'BTCJPY', 'XAUUSD', 'EURUSD', 'USDJPY'];
  
  void _showSymbolSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '通貨ペア選択',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: availableSymbols.length,
                itemBuilder: (context, index) {
                  final symbol = availableSymbols[index];
                  final isSelected = selectedSymbols.contains(symbol);
                  
                  return CheckboxListTile(
                    title: Text(symbol),
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          if (!selectedSymbols.contains(symbol)) {
                            selectedSymbols.add(symbol);
                          }
                        } else {
                          selectedSymbols.remove(symbol);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('完了'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return const QuotesScreenIOS();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('気配値'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showSymbolSelector,
          ),
        ],
      ),
      body: QuotesScreenAndroid(selectedSymbols: selectedSymbols),
    );
  }
}

class QuotesScreenAndroid extends StatelessWidget {
  final List<String> selectedSymbols;
  
  const QuotesScreenAndroid({Key? key, required this.selectedSymbols}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer<PriceProvider>(
      builder: (context, priceProvider, child) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: selectedSymbols.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final symbol = selectedSymbols[index];
            final prices = priceProvider.getCurrentPrice(symbol);
            final spread = (prices['ask'] ?? 0.0) - (prices['bid'] ?? 0.0);
            final changePercent = _calculateChangePercent(prices['bid'] ?? 0.0);
            
            return GestureDetector(
              onTap: () => _showQuoteDetails(context, symbol, prices),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              symbol,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getSymbolName(symbol),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: changePercent >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: changePercent >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'スプレッド: ${_formatSpread(spread, symbol)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Bid (売値)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(prices['bid'] ?? 0.0, symbol),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Ask (買値)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(prices['ask'] ?? 0.0, symbol),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  String _getSymbolName(String symbol) {
    final names = {
      'GBPJPY': '英ポンド/円',
      'BTCJPY': 'ビットコイン/円',
      'XAUUSD': '金/米ドル',
      'EURUSD': 'ユーロ/米ドル',
      'USDJPY': '米ドル/円',
      'EURJPY': 'ユーロ/円',
      'AUDJPY': '豪ドル/円',
      'NZDJPY': 'NZドル/円',
      'CADJPY': 'カナダドル/円',
      'CHFJPY': 'スイスフラン/円',
    };
    return names[symbol] ?? symbol;
  }
  
  double _calculateChangePercent(double currentPrice) {
    // デモ用の変動率（実際は前日終値と比較）
    return (Random().nextDouble() - 0.5) * 2.5;
  }
  
  String _formatPrice(double price, String symbol) {
    if (symbol == 'BTCJPY') {
      final integerPart = price.toInt().toString();
      final reversed = integerPart.split('').reversed.toList();
      final chunks = <String>[];
      
      for (int i = 0; i < reversed.length; i += 3) {
        final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
        chunks.add(reversed.sublist(i, end).reversed.join());
      }
      
      return chunks.reversed.join(' ');
    } else if (symbol == 'GBPJPY') {
      return price.toStringAsFixed(3);
    } else {
      return price.toStringAsFixed(2);
    }
  }
  
  String _formatSpread(double spread, String symbol) {
    if (symbol == 'BTCJPY') {
      return spread.toInt().toString();
    } else if (symbol == 'GBPJPY') {
      return spread.toStringAsFixed(3);
    } else {
      return spread.toStringAsFixed(2);
    }
  }
  
  void _showQuoteDetails(BuildContext context, String symbol, Map<String, double> prices) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              symbol,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Bid'),
                    Text(
                      _formatPrice(prices['bid'] ?? 0.0, symbol),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Ask'),
                    Text(
                      _formatPrice(prices['ask'] ?? 0.0, symbol),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderScreen(symbol: symbol),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('注文', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChartScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('チャート', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}