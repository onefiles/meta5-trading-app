import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../providers/price_provider.dart';
import '../models/order.dart';

class OrderScreenIOS extends StatefulWidget {
  final String symbol;

  const OrderScreenIOS({
    Key? key,
    required this.symbol,
  }) : super(key: key);

  @override
  State<OrderScreenIOS> createState() => _OrderScreenIOSState();
}

class _OrderScreenIOSState extends State<OrderScreenIOS> {
  double _lots = 0.01;
  OrderType _orderType = OrderType.buy;
  final TextEditingController _lotsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _lotsController.text = _lots.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _lotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('新規注文 - ${widget.symbol}'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 価格表示セクション
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Consumer<PriceProvider>(
                  builder: (context, priceProvider, child) {
                    final prices = priceProvider.getCurrentPrice(widget.symbol);
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Bid',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(prices['bid'] ?? 0.0),
                                  style: const TextStyle(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Ask',
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatPrice(prices['ask'] ?? 0.0),
                                  style: const TextStyle(
                                    color: CupertinoColors.activeBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // 売買選択
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CupertinoSlidingSegmentedControl<OrderType>(
                  groupValue: _orderType,
                  onValueChanged: (OrderType? value) {
                    if (value != null) {
                      setState(() {
                        _orderType = value;
                      });
                    }
                  },
                  children: const {
                    OrderType.buy: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'BUY',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    OrderType.sell: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'SELL',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ロット数入力
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ロット数',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _lotsController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: CupertinoColors.systemGrey4,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      onChanged: (value) {
                        final lots = double.tryParse(value);
                        if (lots != null && lots > 0) {
                          setState(() {
                            _lots = lots;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildLotButton(0.01),
                        const SizedBox(width: 8),
                        _buildLotButton(0.1),
                        const SizedBox(width: 8),
                        _buildLotButton(1.0),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // 注文実行ボタン
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: _orderType == OrderType.buy 
                      ? CupertinoColors.activeBlue 
                      : CupertinoColors.destructiveRed,
                  onPressed: _executeOrder,
                  child: Text(
                    _orderType == OrderType.buy ? 'BUY ${widget.symbol}' : 'SELL ${widget.symbol}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLotButton(double lots) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _lots = lots;
          _lotsController.text = lots.toStringAsFixed(2);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _lots == lots 
              ? CupertinoColors.activeBlue 
              : CupertinoColors.systemGrey5,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          lots.toStringAsFixed(2),
          style: TextStyle(
            color: _lots == lots 
                ? CupertinoColors.white 
                : CupertinoColors.label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
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
      
      return chunks.reversed.join(' ');
    } else if (widget.symbol == 'GBPJPY') {
      return price.toStringAsFixed(3);
    } else {
      return price.toStringAsFixed(2);
    }
  }

  void _executeOrder() {
    final priceProvider = context.read<PriceProvider>();
    final orderProvider = context.read<OrderProvider>();
    final prices = priceProvider.getCurrentPrice(widget.symbol);
    
    final currentPrice = _orderType == OrderType.buy 
        ? (prices['ask'] ?? 0.0) 
        : (prices['bid'] ?? 0.0);

    final order = Order(
      ticket: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: widget.symbol,
      type: _orderType,
      lots: _lots,
      openPrice: currentPrice,
      currentPrice: currentPrice,
      openTime: DateTime.now().millisecondsSinceEpoch,
    );

    orderProvider.addOrder(order);
    
    // 成功ダイアログを表示
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('注文完了'),
        content: Text('${widget.symbol}の${_orderType == OrderType.buy ? '買い' : '売り'}注文が実行されました'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              Navigator.pop(context); // ダイアログを閉じる
              Navigator.pop(context); // 注文画面を閉じる
            },
          ),
        ],
      ),
    );
  }
}