import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/profit_calculator.dart';

// Android版のPositionCanvasViewを完全再現
class PositionCanvasView extends StatelessWidget {
  final Order order;
  final VoidCallback? onClose;
  
  const PositionCanvasView({
    Key? key,
    required this.order,
    this.onClose,
  }) : super(key: key);

  // Android版のコンスタント（MT4仕様に合わせた色）
  static const int _symbolColor = 0xFF000000; // 黒
  static const int _sellColor = 0xFFe21d1d; // 赤
  static const int _buyColor = 0xFF007aff; // 青
  static const int _volumeColor = 0xFF525252; // グレー
  static const int _profitPositive = 0xFF007aff; // 青
  static const int _profitNegative = 0xFFe21d1d; // 赤
  static const int _priceRangeColor = 0xFF95979b; // ライトグレー
  static const int _backgroundColor = 0xFFFFFFFF; // 白

  @override
  Widget build(BuildContext context) {
    // Android版と同じサイズとレイアウトで描画
    return Container(
      height: 48, // Android版と同じ高さ
      color: Color(_backgroundColor),
      child: CustomPaint(
        painter: PositionCanvasPainter(order: order),
        size: const Size(double.infinity, 48),
      ),
    );
  }
}

// Android版のCustomPaintと同じ描画ロジック
class PositionCanvasPainter extends CustomPainter {
  final Order order;
  
  PositionCanvasPainter({required this.order});
  
  // Android版のコンスタント
  static const int _symbolColor = 0xFF000000;
  static const int _sellColor = 0xFFe21d1d;
  static const int _buyColor = 0xFF007aff;
  static const int _volumeColor = 0xFF525252;
  static const int _profitPositive = 0xFF007aff;
  static const int _profitNegative = 0xFFe21d1d;
  static const int _priceRangeColor = 0xFF95979b;
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;
    
    // Android版のレイアウト定数
    const double leftMargin = 14.0;
    const double topMargin = 6.0;
    const double bottomTextDistance = 10.0;
    const double bottomTextX = 14.0;
    
    // フォントサイズ設定
    const double fontSize = 16.0;
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Y座標ベースライン計算
    const double baselineY = topMargin + fontSize;
    
    // 1. 通貨ペア名（左上）
    final symbolDisplay = order.symbol == 'XAUUSD' ? 'GOLD,' : '${order.symbol},';
    final symbolWidth = _drawText(
      canvas, 
      textPainter, 
      symbolDisplay, 
      leftMargin, 
      baselineY, 
      fontSize, 
      FontWeight.bold, 
      Color(_symbolColor)
    );
    
    // 2. 売買方向+ロット数（中央上）
    final typeText = order.type == OrderType.buy ? 'buy' : 'sell';
    final typeColor = order.type == OrderType.buy ? Color(_buyColor) : Color(_sellColor);
    final lotsText = order.lots.toStringAsFixed(2);
    
    final tradeInfoX = leftMargin + symbolWidth + 8;
    final typeWidth = _drawText(
      canvas, 
      textPainter, 
      typeText, 
      tradeInfoX, 
      baselineY, 
      fontSize, 
      FontWeight.bold, 
      typeColor
    );
    
    final lotsX = tradeInfoX + typeWidth + 4;
    _drawText(
      canvas, 
      textPainter, 
      lotsText, 
      lotsX, 
      baselineY, 
      fontSize, 
      FontWeight.normal, 
      typeColor
    );
    
    // 3. 損益（右上）
    final profitText = ProfitCalculator.formatProfit(order.profit);
    final profitColor = order.profit >= 0 ? Color(_profitPositive) : Color(_profitNegative);
    final profitX = size.width - 120; // 右寄せ
    _drawText(
      canvas, 
      textPainter, 
      profitText, 
      profitX, 
      baselineY, 
      fontSize, 
      FontWeight.bold, 
      profitColor
    );
    
    // 4. 価格範囲（左下）
    final priceRangeText = '${ProfitCalculator.formatPrice(order.openPrice, order.symbol)} → ${ProfitCalculator.formatPrice(order.currentPrice, order.symbol)}';
    final priceRangeY = size.height - bottomTextDistance;
    _drawText(
      canvas, 
      textPainter, 
      priceRangeText, 
      bottomTextX, 
      priceRangeY, 
      12.0, // 小さめのフォント
      FontWeight.normal, 
      Color(_priceRangeColor)
    );
  }
  
  // Android版のテキスト描画メソッドを再現
  double _drawText(
    Canvas canvas,
    TextPainter textPainter,
    String text,
    double x,
    double y,
    double fontSize,
    FontWeight fontWeight,
    Color color,
  ) {
    textPainter.text = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
    
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y - textPainter.height));
    
    return textPainter.width;
  }
  
  @override
  bool shouldRepaint(covariant PositionCanvasPainter oldDelegate) {
    return oldDelegate.order != order;
  }
}