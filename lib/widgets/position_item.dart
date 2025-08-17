import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:vibration/vibration.dart';  // Webビルドで問題を起こすため無効化
import '../models/order.dart';
import '../services/profit_calculator.dart';

class PositionItem extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  
  const PositionItem({
    Key? key,
    required this.order,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isProfit = order.profit >= 0;
    final typeColor = order.type == OrderType.buy 
        ? const Color(0xFF007aff) 
        : const Color(0xFFe21d1d);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        onLongPress: () async {
          // Android版と同じ振動フィードバック（100ms）
          // Web版では HapticFeedback を使用
          HapticFeedback.lightImpact();
          onLongPress();
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 上段：シンボル、タイプ、ロット数
              Row(
                children: [
                  Text(
                    '${order.symbolDisplay},',
                    style: const TextStyle(
                      color: Color(0xFF525252),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    order.typeText,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    order.lots.toStringAsFixed(2),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  // 損益表示
                  Text(
                    ProfitCalculator.formatProfit(order.profit),
                    style: TextStyle(
                      color: isProfit ? const Color(0xFF007aff) : const Color(0xFFe21d1d),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // 下段：価格範囲
              Text(
                '${ProfitCalculator.formatPrice(order.openPrice, order.symbol)} → ${ProfitCalculator.formatPrice(order.currentPrice, order.symbol)}',
                style: const TextStyle(
                  color: Color(0xFF95979b),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ProfitCalculatorで統一されたため、このメソッドは不要
  // String _formatPrice(double price, String symbol) { ... }
  
  // ProfitCalculatorで統一されたため、このメソッドは不要
  // String _formatProfit(double profit) { ... }
}