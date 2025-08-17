import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/price_provider.dart';

class QuotesScreenIOS extends StatefulWidget {
  const QuotesScreenIOS({Key? key}) : super(key: key);

  @override
  State<QuotesScreenIOS> createState() => _QuotesScreenIOSState();
}

class _QuotesScreenIOSState extends State<QuotesScreenIOS> {
  final List<String> symbols = ['GBPJPY', 'BTCJPY', 'XAUUSD', 'EURUSD', 'USDJPY'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PriceProvider>().startPriceUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('気配値'),
      ),
      child: SafeArea(
        child: Consumer<PriceProvider>(
          builder: (context, priceProvider, child) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: symbols.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final symbol = symbols[index];
                final prices = priceProvider.getCurrentPrice(symbol);
                final spread = (prices['ask'] ?? 0.0) - (prices['bid'] ?? 0.0);
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.systemGrey.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            symbol,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemGrey5,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'スプレッド: ${_formatSpread(spread, symbol)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: CupertinoColors.destructiveRed.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: CupertinoColors.destructiveRed.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Bid (売値)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatPrice(prices['bid'] ?? 0.0, symbol),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.destructiveRed,
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
                                color: CupertinoColors.activeBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: CupertinoColors.activeBlue.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Ask (買値)',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: CupertinoColors.systemGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatPrice(prices['ask'] ?? 0.0, symbol),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: CupertinoColors.activeBlue,
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
                );
              },
            );
          },
        ),
      ),
    );
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
}