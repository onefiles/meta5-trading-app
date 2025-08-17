import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../widgets/position_item_ios.dart';
import 'order_screen_ios.dart';

class TradeScreenIOS extends StatefulWidget {
  const TradeScreenIOS({Key? key}) : super(key: key);

  @override
  State<TradeScreenIOS> createState() => _TradeScreenIOSState();
}

class _TradeScreenIOSState extends State<TradeScreenIOS> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().startPriceUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('取引'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _openOrderScreen,
          child: const Icon(CupertinoIcons.add_circled),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Consumer<OrderProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      _buildMarginTile('残高', provider.balance),
                      _buildDivider(),
                      _buildMarginTile('有効証拠金', provider.equity),
                      _buildDivider(),
                      _buildMarginTile('余剰証拠金', provider.freeMargin),
                      _buildDivider(),
                      _buildMarginTile('必要証拠金', provider.requiredMargin),
                      _buildDivider(),
                      _buildMarginLevelTile('証拠金維持率', provider.marginLevel),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<OrderProvider>(
                builder: (context, provider, child) {
                  if (provider.orders.isEmpty) {
                    return const Center(
                      child: Text(
                        'ポジションがありません',
                        style: TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: provider.orders.length,
                    itemBuilder: (context, index) {
                      final order = provider.orders[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Slidable(
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) => _closePosition(order),
                                backgroundColor: CupertinoColors.destructiveRed,
                                foregroundColor: CupertinoColors.white,
                                icon: CupertinoIcons.xmark_circle_fill,
                                label: '決済',
                              ),
                            ],
                          ),
                          child: PositionItemIOS(
                            order: order,
                            onTap: () => _showPositionDetails(order),
                            onLongPress: () => _quickClosePosition(order),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarginTile(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 16,
            ),
          ),
          Text(
            _formatPrice(value),
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginLevelTile(String label, double value) {
    final color = value >= 100.0 
        ? CupertinoColors.activeBlue 
        : CupertinoColors.destructiveRed;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: CupertinoColors.label,
              fontSize: 16,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)}%',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: CupertinoColors.separator,
    );
  }

  String _formatPrice(double price) {
    final integerPart = price.toInt().toString();
    final reversed = integerPart.split('').reversed.toList();
    final chunks = <String>[];
    
    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      chunks.add(reversed.sublist(i, end).reversed.join());
    }
    
    return '${chunks.reversed.join(' ')}.00';
  }

  void _openOrderScreen() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const OrderScreenIOS(symbol: 'GBPJPY'),
      ),
    );
  }

  void _showPositionDetails(Order order) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('ポジション詳細'),
        content: Text('${order.symbol}\n損益: ${order.profit.toStringAsFixed(2)}'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _closePosition(Order order) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('ポジション決済'),
        content: Text('${order.symbol}を決済しますか？\n損益: ${order.profit.toStringAsFixed(2)}'),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('キャンセル'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('決済'),
            onPressed: () {
              context.read<OrderProvider>().removeOrder(order);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _quickClosePosition(Order order) {
    context.read<OrderProvider>().removeOrder(order);
  }
}