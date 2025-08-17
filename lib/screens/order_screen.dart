import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../utils/platform_helper.dart';
import '../providers/order_provider.dart';
import '../providers/price_provider.dart';
import '../models/order.dart';

class OrderScreen extends StatefulWidget {
  final String symbol;
  
  const OrderScreen({Key? key, required this.symbol}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String selectedSymbol = 'GBPJPY';
  double lots = 1.00;
  double? stopLoss;
  double? takeProfit;
  bool enableStopLoss = false;
  bool enableTakeProfit = false;
  
  final List<String> availableSymbols = ['GBPJPY', 'BTCJPY', 'XAUUSD', 'EURUSD', 'USDJPY'];
  
  final TextEditingController _stopLossController = TextEditingController();
  final TextEditingController _takeProfitController = TextEditingController();
  final TextEditingController _lotsController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    selectedSymbol = widget.symbol;
    _lotsController.text = lots.toStringAsFixed(2);
  }
  
  @override
  void dispose() {
    _stopLossController.dispose();
    _takeProfitController.dispose();
    _lotsController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('新規注文 - ${widget.symbol}'),
          leading: CupertinoNavigationBarBackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        child: _buildOrderForm(),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('新規注文 - ${widget.symbol}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _buildOrderForm(),
    );
  }
  
  Widget _buildOrderForm() {
    return Consumer<PriceProvider>(
      builder: (context, priceProvider, child) {
        final prices = priceProvider.getCurrentPrice(selectedSymbol);
        final bidPrice = prices['bid'] ?? 0.0;
        final askPrice = prices['ask'] ?? 0.0;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 通貨ペア選択
              _buildSymbolSelectionCard(),
              
              const SizedBox(height: 16),
              
              // 価格表示
              _buildPriceDisplay(bidPrice, askPrice),
              
              const SizedBox(height: 16),
              
              // ロット数入力
              _buildLotsInput(),
              
              const SizedBox(height: 16),
              
              // ストップロス設定
              _buildStopLossCard(bidPrice, askPrice),
              
              const SizedBox(height: 16),
              
              // テイクプロフィット設定
              _buildTakeProfitCard(bidPrice, askPrice),
              
              const SizedBox(height: 32),
              
              // 注文概要
              _buildOrderSummary(),
              
              const SizedBox(height: 24),
              
              // Buy/Sellボタン
              _buildTradeButtons(bidPrice, askPrice),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildSymbolSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '通貨ペア選択',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              value: selectedSymbol,
              isExpanded: true,
              items: availableSymbols.map((symbol) {
                return DropdownMenuItem<String>(
                  value: symbol,
                  child: Row(
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getSymbolDescription(symbol),
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedSymbol = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPriceDisplay(double bidPrice, double askPrice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Bid (売値)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(bidPrice),
                    style: const TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: Column(
                children: [
                  const Text('Ask (買値)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    _formatPrice(askPrice),
                    style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLotsInput() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ロット数', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickLotButton('-0.1', () => _adjustLots(-0.1)),
                _buildQuickLotButton('-0.01', () => _adjustLots(-0.01)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextFormField(
                      controller: _lotsController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (value) {
                        final parsedValue = double.tryParse(value);
                        if (parsedValue != null && parsedValue >= 0.01 && parsedValue <= 10.0) {
                          setState(() {
                            lots = parsedValue;
                          });
                        }
                      },
                    ),
                  ),
                ),
                _buildQuickLotButton('+0.01', () => _adjustLots(0.01)),
                _buildQuickLotButton('+0.1', () => _adjustLots(0.1)),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickLotButton(String label, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade50,
          foregroundColor: Colors.blue,
          minimumSize: const Size(50, 36),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
  
  Widget _buildStopLossCard(double bidPrice, double askPrice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: enableStopLoss,
                  onChanged: (value) {
                    setState(() {
                      enableStopLoss = value;
                      if (!value) {
                        stopLoss = null;
                        _stopLossController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('ストップロス (SL)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            if (enableStopLoss) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _stopLossController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'SL価格',
                  hintText: '損切り価格を入力',
                  border: const OutlineInputBorder(),
                  suffixText: _getPriceUnit(),
                ),
                onChanged: (value) {
                  final parsedValue = double.tryParse(value);
                  if (parsedValue != null) {
                    setState(() {
                      stopLoss = parsedValue;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildTakeProfitCard(double bidPrice, double askPrice) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  value: enableTakeProfit,
                  onChanged: (value) {
                    setState(() {
                      enableTakeProfit = value;
                      if (!value) {
                        takeProfit = null;
                        _takeProfitController.clear();
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('テイクプロフィット (TP)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            if (enableTakeProfit) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _takeProfitController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'TP価格',
                  hintText: '利確価格を入力',
                  border: const OutlineInputBorder(),
                  suffixText: _getPriceUnit(),
                ),
                onChanged: (value) {
                  final parsedValue = double.tryParse(value);
                  if (parsedValue != null) {
                    setState(() {
                      takeProfit = parsedValue;
                    });
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildOrderSummary() {
    return Card(
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('注文概要', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSummaryRow('通貨ペア', widget.symbol),
            _buildSummaryRow('ロット数', '${lots.toStringAsFixed(2)} lot'),
            if (enableStopLoss && stopLoss != null)
              _buildSummaryRow('ストップロス', _formatPrice(stopLoss!)),
            if (enableTakeProfit && takeProfit != null)
              _buildSummaryRow('テイクプロフィット', _formatPrice(takeProfit!)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  
  Widget _buildTradeButtons(double bidPrice, double askPrice) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _placeOrder(OrderType.sell, bidPrice),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFe21d1d),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Column(
              children: [
                const Text('SELL', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_formatPrice(bidPrice), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _placeOrder(OrderType.buy, askPrice),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007aff),
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Column(
              children: [
                const Text('BUY', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(_formatPrice(askPrice), style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  void _adjustLots(double adjustment) {
    setState(() {
      lots = (lots + adjustment).clamp(0.01, 10.0);
      _lotsController.text = lots.toStringAsFixed(2);
    });
  }
  
  String _getSymbolDescription(String symbol) {
    switch (symbol) {
      case 'GBPJPY':
        return '英ポンド/円';
      case 'BTCJPY':
        return 'ビットコイン/円';
      case 'XAUUSD':
        return '金/米ドル';
      case 'EURUSD':
        return 'ユーロ/米ドル';
      case 'USDJPY':
        return '米ドル/円';
      default:
        return symbol;
    }
  }
  
  String _formatPrice(double price) {
    if (widget.symbol == 'BTCJPY') {
      final integerPart = price.toInt().toString();
      final reversed = integerPart.split('').reversed.toList();
      final chunks = <String>[];
      
      for (int i = 0; i < reversed.length; i += 3) {
        final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
        chunks.add(reversed.sublist(i, end).reversed.join());
      }
      
      return chunks.reversed.join(',');
    } else if (widget.symbol == 'GBPJPY') {
      return price.toStringAsFixed(3);
    } else {
      return price.toStringAsFixed(2);
    }
  }
  
  String _getPriceUnit() {
    if (widget.symbol == 'BTCJPY') {
      return '円';
    } else if (widget.symbol == 'XAUUSD') {
      return 'USD';
    } else if (widget.symbol.endsWith('JPY')) {
      return '円';
    } else {
      return '';
    }
  }
  
  void _placeOrder(OrderType type, double price) {
    // SL/TPの妥当性チェック
    if (enableStopLoss && stopLoss != null) {
      if (type == OrderType.buy && stopLoss! >= price) {
        _showError('買い注文の場合、ストップロスは現在価格より低く設定してください');
        return;
      }
      if (type == OrderType.sell && stopLoss! <= price) {
        _showError('売り注文の場合、ストップロスは現在価格より高く設定してください');
        return;
      }
    }
    
    if (enableTakeProfit && takeProfit != null) {
      if (type == OrderType.buy && takeProfit! <= price) {
        _showError('買い注文の場合、テイクプロフィットは現在価格より高く設定してください');
        return;
      }
      if (type == OrderType.sell && takeProfit! >= price) {
        _showError('売り注文の場合、テイクプロフィットは現在価格より低く設定してください');
        return;
      }
    }
    
    final order = Order(
      symbol: selectedSymbol,
      type: type,
      lots: lots,
      openPrice: price,
      currentPrice: price,
      stopLoss: enableStopLoss ? stopLoss : null,
      takeProfit: enableTakeProfit ? takeProfit : null,
    );
    
    context.read<OrderProvider>().addOrder(order);
    Navigator.pop(context);
    
    final message = '${type == OrderType.buy ? "買い" : "売り"}注文が実行されました\n'
        'ロット数: ${lots.toStringAsFixed(2)}\n'
        '価格: ${_formatPrice(price)}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  void _showError(String message) {
    if (PlatformHelper.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }
}