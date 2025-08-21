import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// import 'package:vibration/vibration.dart';  // Webビルドで問題を起こすため無効化
import '../models/order.dart';
import '../services/profit_calculator.dart';
import '../providers/font_provider.dart';

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
    
    // Android版と同じ: Cardを使わず、区切り線のみのフラットなデザイン
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          onLongPress: () async {
            // Android版と同じ振動フィードバック（100ms）
            // Web版では HapticFeedback を使用
            HapticFeedback.lightImpact();
            onLongPress();
          },
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 上段：シンボル、タイプ、ロット数
                Consumer<FontProvider>(
                  builder: (context, fontProvider, child) => Row(
                    children: [
                      Text(
                        '${order.symbolDisplay},',
                        style: fontProvider.getSymbolTextStyle(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      const SizedBox(width: 4),
                      Text(
                        order.typeText,
                        style: fontProvider.getPositionTextStyle(
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        order.lots.toStringAsFixed(2),
                        style: fontProvider.getPositionTextStyle(
                          color: typeColor,
                        ),
                      ),
                      const Spacer(),
                      // 損益表示
                      Text(
                        ProfitCalculator.formatProfit(order.profit),
                        style: fontProvider.getProfitTextStyle(
                          color: isProfit ? const Color(0xFF007aff) : const Color(0xFFe21d1d),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // 下段：価格範囲
                Consumer<FontProvider>(
                  builder: (context, fontProvider, child) => Text(
                    '${ProfitCalculator.formatPrice(order.openPrice, order.symbol)} → ${ProfitCalculator.formatPrice(order.currentPrice, order.symbol)}',
                    style: fontProvider.getPriceTextStyle(),
                  ),
                ),
              ],
            ),
          ),
        ),
        // 区切り線（Android版と同じ）
        Container(
          height: 0.5,
          color: const Color(0xFFE0E0E0),
        ),
      ],
    );
  }
  
  // ProfitCalculatorで統一されたため、このメソッドは不要
  // String _formatPrice(double price, String symbol) { ... }
  
  // ProfitCalculatorで統一されたため、このメソッドは不要
  // String _formatProfit(double profit) { ... }
}