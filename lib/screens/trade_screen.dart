import 'package:flutter/material.dart';
import '../utils/platform_helper.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/order_provider.dart';
import '../models/order.dart';
import '../widgets/position_item.dart';
import '../services/profit_calculator.dart';
import 'order_screen.dart';
import 'trade_screen_ios.dart';

enum PositionSortType {
  profitDesc,
  profitAsc,
  openTimeDesc,
  openTimeAsc,
  symbolAsc,
  symbolDesc,
  lotsDesc,
  lotsAsc,
}

class TradeScreen extends StatefulWidget {
  const TradeScreen({Key? key}) : super(key: key);

  @override
  State<TradeScreen> createState() => _TradeScreenState();
}

class _TradeScreenState extends State<TradeScreen> {
  PositionSortType _sortType = PositionSortType.openTimeDesc;
  
  @override
  void initState() {
    super.initState();
    // 価格更新を開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().startPriceUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return const TradeScreenIOS();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // トップバーセクション
          Container(
            height: 56,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                final totalProfit = provider.orders.fold(0.0, (sum, order) => sum + order.profit);
                return Row(
                  children: [
                    // 左側: ic_drag + トレード + 合計損益
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/ic_drag.png',
                            width: 18,
                            height: 13,
                            color: const Color(0xFF5d5151),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'トレード',
                                style: TextStyle(
                                  fontSize: totalProfit != 0.0 ? 12 : 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              if (totalProfit != 0.0)
                                Text(
                                  totalProfit >= 0
                                      ? '${_formatAmount(totalProfit.abs())} JPY'
                                      : '-${_formatAmount(totalProfit.abs())} JPY',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: totalProfit >= 0 ? const Color(0xFF007aff) : const Color(0xFFFF6B6B),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // 右側: ソートと新規注文アイコン
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _showSortMenu,
                          child: Image.asset(
                            'assets/icons/ic_menu_sort.png',
                            width: 24,
                            height: 24,
                            color: const Color(0xFF5d5151),
                          ),
                        ),
                        const SizedBox(width: 40),
                        GestureDetector(
                          onTap: _openOrderScreen,
                          child: Image.asset(
                            'assets/icons/ic_actionbar_new_order.png',
                            width: 24,
                            height: 24,
                            color: const Color(0xFF5d5151),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          // 証拠金情報セクション
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                final hasPositions = provider.orders.isNotEmpty;
                
                return Column(
                  children: [
                    _buildMarginRowWithDots('残高:', provider.balance, '.'),
                    const SizedBox(height: 8),
                    _buildMarginRowWithDots('クレジット:', provider.credit, '.'), // リアルタイム更新
                    const SizedBox(height: 8),
                    _buildMarginRowWithDots('有効証拠金:', provider.equity, '.'),
                    const SizedBox(height: 8),
                    _buildMarginRowWithDots('余剰証拠金:', provider.freeMargin, '·'),
                    if (hasPositions) ...[
                      const SizedBox(height: 8),
                      _buildMarginLevelRowWithDots('証拠金維持率(%):', provider.marginLevel, '.'),
                      const SizedBox(height: 8),
                      _buildMarginRowWithDots('証拠金:', provider.requiredMargin, '.'),
                    ],
                  ],
                );
              },
            ),
          ),
          // 区切り線
          Container(
            height: 0.5,
            margin: const EdgeInsets.only(top: 1),
            color: const Color(0xFFCCCCCC),
          ),
          // ポジションヘッダー
          Container(
            height: 26,
            color: const Color(0xFFF5F5F5),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: const Text(
              'ポジション',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // ポジションヘッダー下部区切り線
          Container(
            height: 0.5,
            color: const Color(0xFFCCCCCC),
          ),
          
          // ポジション一覧
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, provider, child) {
                if (provider.orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'ポジションがありません',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }
                
                final sortedOrders = _applySorting(List.from(provider.orders));
                
                return ListView.builder(
                  padding: EdgeInsets.zero,  // Android版と同じ: パディングなし
                  itemCount: sortedOrders.length,
                  itemBuilder: (context, index) {
                    final order = sortedOrders[index];
                    // Android版と同じ: 余計なPaddingを削除、Slidableも直接配置
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _closePosition(order),
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.close,
                            label: '決済',
                          ),
                        ],
                      ),
                      child: PositionItem(
                        order: order,
                        onTap: () => _showPositionDetails(order),
                        onLongPress: () => _quickClosePosition(order),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarginRowWithDots(String label, double value, String dotChar) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF444444),
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            _generateDots(dotChar),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFCCCCCC),
            ),
            overflow: TextOverflow.visible,
            maxLines: 1,
          ),
        ),
        Text(
          _formatAmount(value),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMarginLevelRowWithDots(String label, double value, String dotChar) {
    // 証拠金維持率の表示処理
    String displayText;
    Color color;
    
    if (value <= 0) {
      displayText = '0.00';  // ポジションがない場合
      color = Colors.black;
    } else if (value.isInfinite) {
      displayText = '0.00';  // Infinityの場合も'0.00'表示
      color = Colors.black;
    } else {
      displayText = value.toStringAsFixed(2);
      color = value >= 100.0 ? Colors.black : const Color(0xFFFF0000);
    }
    
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF444444),
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            _generateDots(dotChar),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFCCCCCC),
            ),
            overflow: TextOverflow.visible,
            maxLines: 1,
          ),
        ),
        Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    // Android版と同じスペース区切りフォーマットを使用
    return ProfitCalculator.formatAmount(amount);
  }
  
  String _generateDots(String dotChar) {
    // Android版と同じ精密なドット計算（実際の文字幅を測定）
    // 簡易版: 固定数のドットを返す
    // 実際のAndroid版では、画面幅やラベル幅に基づいて動的計算している
    if (dotChar == '·') {
      // 余剰証拠金用の中点ドット
      return '  · · · · · · · · · · · · · · · · · · · · · · · · ·';
    } else {
      // その他用のピリオドドット
      return '  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .';
    }
  }
  
  // このメソッドはOrderProviderで管理されるため不要
  // Future<double> _getCurrentCredit() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getDouble('credit') ?? 200000.0;
  // }

  void _openOrderScreen() {
    // デフォルトでGBPJPYを選択し、ユーザーがアプリ内でBTCJPY等に変更可能
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderScreen(symbol: 'GBPJPY'),
      ),
    );
  }
  

  void _showPositionDetails(Order order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ポジション ${order.symbol} - ${order.profit.toStringAsFixed(2)}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _closePosition(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ポジション決済'),
        content: Text(
          '${order.symbol} ${order.lots.toStringAsFixed(2)}ロットを決済しますか？\n\n'
          '損益: ${order.profit.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<OrderProvider>().removeOrder(order);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('ポジション決済完了\n損益: ${order.profit.toStringAsFixed(2)}'),
                ),
              );
            },
            child: const Text('決済', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _quickClosePosition(Order order) {
    context.read<OrderProvider>().removeOrder(order);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ポジション決済完了（長押し）\n損益: ${order.profit.toStringAsFixed(2)}'),
      ),
    );
  }
  
  List<Order> _applySorting(List<Order> orders) {
    switch (_sortType) {
      case PositionSortType.profitDesc:
        orders.sort((a, b) => b.profit.compareTo(a.profit));
        break;
      case PositionSortType.profitAsc:
        orders.sort((a, b) => a.profit.compareTo(b.profit));
        break;
      case PositionSortType.openTimeDesc:
        orders.sort((a, b) => b.openTime.compareTo(a.openTime));
        break;
      case PositionSortType.openTimeAsc:
        orders.sort((a, b) => a.openTime.compareTo(b.openTime));
        break;
      case PositionSortType.symbolAsc:
        orders.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
      case PositionSortType.symbolDesc:
        orders.sort((a, b) => b.symbol.compareTo(a.symbol));
        break;
      case PositionSortType.lotsDesc:
        orders.sort((a, b) => b.lots.compareTo(a.lots));
        break;
      case PositionSortType.lotsAsc:
        orders.sort((a, b) => a.lots.compareTo(b.lots));
        break;
    }
    return orders;
  }
  
  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ポジションソート',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildPositionSortOption('損益 (高い順)', PositionSortType.profitDesc, Icons.trending_up),
            _buildPositionSortOption('損益 (低い順)', PositionSortType.profitAsc, Icons.trending_down),
            _buildPositionSortOption('開始時刻 (新しい順)', PositionSortType.openTimeDesc, Icons.access_time),
            _buildPositionSortOption('開始時刻 (古い順)', PositionSortType.openTimeAsc, Icons.access_time),
            _buildPositionSortOption('通貨ペア (A-Z)', PositionSortType.symbolAsc, Icons.sort_by_alpha),
            _buildPositionSortOption('通貨ペア (Z-A)', PositionSortType.symbolDesc, Icons.sort_by_alpha),
            _buildPositionSortOption('ロット数 (大きい順)', PositionSortType.lotsDesc, Icons.scale),
            _buildPositionSortOption('ロット数 (小さい順)', PositionSortType.lotsAsc, Icons.scale),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPositionSortOption(String title, PositionSortType sortType, IconData icon) {
    final isSelected = _sortType == sortType;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? const Color(0xFF007aff) : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? const Color(0xFF007aff) : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(
        Icons.check,
        color: Color(0xFF007aff),
      ) : null,
      onTap: () {
        setState(() {
          _sortType = sortType;
        });
        Navigator.pop(context);
      },
    );
  }
}