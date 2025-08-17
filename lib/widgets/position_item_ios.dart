import 'package:flutter/cupertino.dart';
import '../models/order.dart';

class PositionItemIOS extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PositionItemIOS({
    Key? key,
    required this.order,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profitColor = order.profit >= 0 
        ? CupertinoColors.systemGreen 
        : CupertinoColors.systemRed;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: order.type == OrderType.buy 
                            ? CupertinoColors.activeBlue 
                            : CupertinoColors.systemRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        order.type == OrderType.buy ? 'BUY' : 'SELL',
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '#${order.ticket}',
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ロット数',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      order.lots.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'オープン価格',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatPrice(order.openPrice, order.symbol),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '現在価格',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatPrice(order.currentPrice, order.symbol),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '損益',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${order.profit >= 0 ? '+' : ''}${_formatProfit(order.profit)}',
                      style: TextStyle(
                        color: profitColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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

  String _formatProfit(double profit) {
    final integerPart = profit.abs().toInt().toString();
    final reversed = integerPart.split('').reversed.toList();
    final chunks = <String>[];
    
    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      chunks.add(reversed.sublist(i, end).reversed.join());
    }
    
    return chunks.reversed.join(' ');
  }
}