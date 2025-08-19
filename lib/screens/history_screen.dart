import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../utils/platform_helper.dart';
import '../providers/history_provider.dart';
import '../models/trade_history.dart';
import '../models/order.dart';
import 'history_screen_ios.dart';
import 'package:intl/intl.dart';

enum SortType {
  dateDesc,
  dateAsc,
  profitDesc,
  profitAsc,
  symbolAsc,
  symbolDesc,
  typeAsc,
  typeDesc,
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedPeriod = 'week';
  String _selectedSymbol = '全て';
  String _selectedType = '全て';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  SortType _sortType = SortType.dateDesc;
  
  final List<String> _symbols = ['全て', 'GBPJPY', 'BTCJPY', 'XAUUSD', 'EURUSD', 'USDJPY'];
  final List<String> _types = ['全て', '買い', '売り'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return const HistoryScreenIOS();
    }
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Android版と同じ上部フィルター
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 期間選択ボタン（1つの枠に縦線区切り）
                Container(
                  height: 32,
                  width: 240, // 横幅を制限
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0), // 検索バーと同じグレー背景
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      _buildSegmentButton('日', 'day', isFirst: true),
                      _buildVerticalDivider(),
                      _buildSegmentButton('週', 'week'),
                      _buildVerticalDivider(),
                      _buildSegmentButton('月', 'month'),
                      _buildVerticalDivider(),
                      _buildSegmentButton('カスタム', 'custom', isLast: true),
                    ],
                  ),
                ),
                const SizedBox(height: 8), // 間隔を狭く（16px → 8px）
                // 検索シンボル入力
                Container(
                  height: 36, // 高さを低く（44px → 36px）
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(6), // 角丸を小さく（22px → 6px）
                  ),
                  child: TextField(
                    textAlignVertical: TextAlignVertical.center, // テキストを垂直中央配置
                    decoration: const InputDecoration(
                      hintText: '検索シンボルを入力',
                      hintStyle: TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 17, // フォントをほんの少し大きく（16px → 17px）
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Color(0xFF999999),
                        size: 24, // アイコンをほんの少し大きく（22px → 24px）
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 40, // アイコンとテキストの間隔を狭く
                        minHeight: 36, // 高さを明示的に指定
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(right: 8, bottom: 2), // 垂直位置を調整（上寄りを解消）
                      isDense: true, // 密度を調整
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedSymbol = value.isEmpty ? '全て' : value.toUpperCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // 履歴リスト
          Expanded(
            child: Consumer<HistoryProvider>(
              builder: (context, provider, child) {
                final history = _getFilteredHistory(provider);
                
                if (history.isEmpty) {
                  return Container(
                    color: Colors.red, // 背景を赤にして確認
                    child: const Center(
                      child: Text(
                        'たこ焼き 🐙🔥 Android版テスト',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: history.length + 1, // +1 for statistics section
                  separatorBuilder: (context, index) {
                    return Container(
                      height: 0.5,
                      color: const Color(0xFFE0E0E0),
                    );
                  },
                  itemBuilder: (context, index) {
                    if (index == history.length) {
                      // 最後に統計情報を表示
                      return _buildStatisticsSection(provider);
                    }
                    final item = history[index];
                    return _buildAndroidHistoryItem(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(TradeHistory history) {
    final isBalanceOrCredit = history.type == OrderType.balance || history.type == OrderType.credit;
    
    return GestureDetector(
      onTap: () => _showHistoryDetails(history),
      child: Container(
        padding: const EdgeInsets.only(left: 14, right: 14, top: 1, bottom: 1),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 上段：シンボル、タイプ、ロット数、決済時刻
          Row(
            children: [
              // シンボル
              Text(
                isBalanceOrCredit 
                    ? (history.type == OrderType.balance ? 'Balance' : 'Credit')
                    : _getSymbolDisplay(history.symbol),
                style: TextStyle(
                  color: isBalanceOrCredit ? Colors.black : const Color(0xFF525252),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // タイプ（Balance/Creditの場合は表示しない）
              if (!isBalanceOrCredit) ...[
                const SizedBox(width: 4),
                Text(
                  history.typeText,
                  style: TextStyle(
                    color: history.type == OrderType.buy 
                        ? const Color(0xFF007aff) 
                        : const Color(0xFFe21d1d),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                // ロット数
                Text(
                  history.lots.toStringAsFixed(2),
                  style: TextStyle(
                    color: history.type == OrderType.buy 
                        ? const Color(0xFF007aff) 
                        : const Color(0xFFe21d1d),
                    fontSize: 16,
                  ),
                ),
              ],
              
              const Spacer(),
              
              // 決済時刻
              Text(
                history.formattedCloseTime,
                style: const TextStyle(
                  color: Color(0xFF95979b),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          
          // 下段：価格範囲と損益
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 1),
            child: Row(
              children: [
                // 価格範囲
                if (!isBalanceOrCredit)
                  Expanded(
                    child: Text(
                      '${_formatPriceWithSpaces(history.openPrice, history.symbol)} → '
                      '${_formatPriceWithSpaces(history.closePrice, history.symbol)}',
                      style: const TextStyle(
                        color: Color(0xFF95979b),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                
                // 損益
                Text(
                  _formatProfitWithSpaces(history.profit),
                  style: TextStyle(
                    color: history.profit >= 0 
                        ? const Color(0xFF007aff) 
                        : const Color(0xFFe21d1d),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // 区切り線（Android版と同じ）
          Container(
            width: double.infinity,
            height: 0.5,
            color: const Color(0xFFE0E0E0),
          ),
        ],
      ),
      ),
    );
  }

  String _formatPriceWithSpaces(double price, String symbol) {
    // BTCJPYは整数表示（小数点なし）
    if (symbol == 'BTCJPY') {
      final integerFormatted = price.toInt().toString();
      final reversed = integerFormatted.split('').reversed.toList();
      final chunks = <String>[];
      
      for (int i = 0; i < reversed.length; i += 3) {
        final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
        chunks.add(reversed.sublist(i, end).reversed.join());
      }
      
      return chunks.reversed.join(' ');
    }
    
    // その他の通貨ペアは小数点2桁で表示
    final formatted = price.toStringAsFixed(2);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '00';
    
    final reversed = integerPart.split('').reversed.toList();
    final chunks = <String>[];
    
    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      chunks.add(reversed.sublist(i, end).reversed.join());
    }
    
    return '${chunks.reversed.join(' ')}.$decimalPart';
  }

  String _formatProfitWithSpaces(double profit) {
    final absProfit = profit.abs();
    final integerPart = absProfit.toInt().toString();
    
    final reversed = integerPart.split('').reversed.toList();
    final chunks = <String>[];
    
    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      chunks.add(reversed.sublist(i, end).reversed.join());
    }
    
    final formattedNumber = '${chunks.reversed.join(' ')}.00';
    
    // Android版と同じ：マイナスの場合のみ-符号、プラスの場合は符号なし
    return profit < 0 ? '-$formattedNumber' : formattedNumber;
  }
  
  String _getSymbolDisplay(String symbol) {
    switch (symbol) {
      case 'XAUUSD':
        return 'GOLD,';
      default:
        return '$symbol,';
    }
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      onDeleted: onDeleted,
      deleteIcon: const Icon(Icons.close, size: 16),
      backgroundColor: const Color(0xFF007aff).withOpacity(0.1),
      deleteIconColor: const Color(0xFF007aff),
      labelStyle: const TextStyle(color: Color(0xFF007aff)),
    );
  }

  List<TradeHistory> _getFilteredHistory(HistoryProvider provider) {
    var history = provider.getFilteredHistory(_selectedPeriod);
    
    // 通貨ペアフィルター
    if (_selectedSymbol != '全て') {
      history = history.where((h) => h.symbol == _selectedSymbol).toList();
    }
    
    // タイプフィルター
    if (_selectedType != '全て') {
      final orderType = _selectedType == '買い' ? OrderType.buy : OrderType.sell;
      history = history.where((h) => h.type == orderType).toList();
    }
    
    // カスタム期間フィルター
    if (_selectedPeriod == 'custom') {
      if (_customStartDate != null) {
        history = history.where((h) => 
          h.closeTimeAsDateTime.isAfter(_customStartDate!)
        ).toList();
      }
      if (_customEndDate != null) {
        history = history.where((h) => 
          h.closeTimeAsDateTime.isBefore(_customEndDate!.add(const Duration(days: 1)))
        ).toList();
      }
    }
    
    // ソート機能
    switch (_sortType) {
      case SortType.dateDesc:
        history.sort((a, b) => b.closeTime.compareTo(a.closeTime));
        break;
      case SortType.dateAsc:
        history.sort((a, b) => a.closeTime.compareTo(b.closeTime));
        break;
      case SortType.profitDesc:
        history.sort((a, b) => b.profit.compareTo(a.profit));
        break;
      case SortType.profitAsc:
        history.sort((a, b) => a.profit.compareTo(b.profit));
        break;
      case SortType.symbolAsc:
        history.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
      case SortType.symbolDesc:
        history.sort((a, b) => b.symbol.compareTo(a.symbol));
        break;
      case SortType.typeAsc:
        history.sort((a, b) => a.typeText.compareTo(b.typeText));
        break;
      case SortType.typeDesc:
        history.sort((a, b) => b.typeText.compareTo(a.typeText));
        break;
    }
    
    return history;
  }

  void _showFilterMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'フィルター',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // 通貨ペア選択
            const Text('通貨ペア', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _symbols.map((symbol) {
                return FilterChip(
                  label: Text(symbol),
                  selected: _selectedSymbol == symbol,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSymbol = symbol;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // 取引タイプ選択
            const Text('取引タイプ', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _types.map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: _selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedSymbol = '全て';
                        _selectedType = '全て';
                        _selectedPeriod = 'week';
                        _customStartDate = null;
                        _customEndDate = null;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('リセット'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007aff),
                    ),
                    child: const Text('適用', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPeriodOption('day', '日'),
            _buildPeriodOption('week', '週'),
            _buildPeriodOption('month', '月'),
            _buildPeriodOption('three_months', '3ヶ月'),
            _buildPeriodOption('custom', 'カスタム'),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodOption(String value, String label) {
    return ListTile(
      leading: Icon(
        Icons.calendar_today,
        color: _selectedPeriod == value ? const Color(0xFF007aff) : Colors.grey,
      ),
      title: Text(label),
      selected: _selectedPeriod == value,
      onTap: () async {
        if (value == 'custom') {
          Navigator.pop(context);
          await _showDateRangePicker();
        } else {
          setState(() {
            _selectedPeriod = value;
            _customStartDate = null;
            _customEndDate = null;
          });
          Navigator.pop(context);
        }
      },
    );
  }
  
  Future<void> _showDateRangePicker() async {
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );
    
    if (dateRange != null) {
      setState(() {
        _selectedPeriod = 'custom';
        _customStartDate = dateRange.start;
        _customEndDate = dateRange.end;
      });
    }
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
              'ソート',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildSortOption('日付 (新しい順)', SortType.dateDesc, Icons.access_time),
            _buildSortOption('日付 (古い順)', SortType.dateAsc, Icons.access_time),
            _buildSortOption('損益 (高い順)', SortType.profitDesc, Icons.trending_up),
            _buildSortOption('損益 (低い順)', SortType.profitAsc, Icons.trending_down),
            _buildSortOption('通貨ペア (A-Z)', SortType.symbolAsc, Icons.sort_by_alpha),
            _buildSortOption('通貨ペア (Z-A)', SortType.symbolDesc, Icons.sort_by_alpha),
            _buildSortOption('取引タイプ (A-Z)', SortType.typeAsc, Icons.category),
            _buildSortOption('取引タイプ (Z-A)', SortType.typeDesc, Icons.category),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSortOption(String title, SortType sortType, IconData icon) {
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
  
  void _showHistoryDetails(TradeHistory history) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // ヘッダー
            Row(
              children: [
                Text(
                  history.symbol,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: history.type == OrderType.buy 
                        ? Colors.blue.shade50 
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    history.type == OrderType.buy ? 'BUY' : 'SELL',
                    style: TextStyle(
                      color: history.type == OrderType.buy 
                          ? Colors.blue 
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            // 取引詳細
            _buildDetailRow('チケット番号', history.ticket),
            _buildDetailRow('ロット数', '${history.lots.toStringAsFixed(2)} lot'),
            _buildDetailRow('オープン価格', _formatPriceWithSpaces(history.openPrice, history.symbol)),
            _buildDetailRow('クローズ価格', _formatPriceWithSpaces(history.closePrice, history.symbol)),
            
            if (history.stopLoss != null)
              _buildDetailRow('ストップロス', _formatPriceWithSpaces(history.stopLoss!, history.symbol)),
            
            if (history.takeProfit != null)
              _buildDetailRow('テイクプロフィット', _formatPriceWithSpaces(history.takeProfit!, history.symbol)),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            
            // 時間情報
            _buildDetailRow('オープン時刻', DateFormat('yyyy/MM/dd HH:mm:ss').format(history.openTimeAsDateTime)),
            if (history.closeTime > 0)
              _buildDetailRow('クローズ時刻', DateFormat('yyyy/MM/dd HH:mm:ss').format(history.closeTimeAsDateTime)),
            
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            
            // 損益情報
            _buildDetailRow('手数料', '¥${history.commission.toStringAsFixed(0)}'),
            _buildDetailRow('スワップ', '¥${history.swap.toStringAsFixed(0)}'),
            
            const SizedBox(height: 20),
            
            // 最終損益
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: history.profit >= 0 
                    ? Colors.green.shade50 
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '損益',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${history.profit >= 0 ? '+' : ''}¥${_formatProfitWithSpaces(history.profit)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: history.profit >= 0 
                          ? Colors.green 
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Android版と同じ履歴アイテムを構築
  Widget _buildAndroidHistoryItem(TradeHistory item) {
    final isProfit = item.profit >= 0;
    final profitColor = isProfit ? const Color(0xFF007aff) : const Color(0xFFe21d1d);
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 上部：シンボル、タイプ、ロット数、時間
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance/Deposit行
                    if (item.symbol == 'BALANCE')
                      const Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      )
                    else
                      Text(
                        '${item.symbol}, ${item.type == OrderType.buy ? 'buy' : 'sell'} ${item.lots.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF525252),
                        ),
                      ),
                    const SizedBox(height: 4),
                    // 価格範囲またはDeposit
                    if (item.symbol != 'BALANCE')
                      Text(
                        '${_formatAndroidPrice(item.openPrice, item.symbol)} → ${_formatAndroidPrice(item.closePrice, item.symbol)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF95979b),
                        ),
                      )
                    else
                      const Text(
                        'Deposit',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF007aff),
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 時間
                  Text(
                    _formatAndroidDateTime(item.closeTime),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF95979b),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 損益
                  Text(
                    _formatAndroidProfit(item.profit),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: profitColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAndroidPrice(double price, String symbol) {
    if (symbol == 'BTCJPY') {
      return _formatAmountWithSpaces(price);
    } else {
      return price.toStringAsFixed(2);
    }
  }

  String _formatAndroidProfit(double profit) {
    return _formatAmountWithSpaces(profit);
  }

  String _formatAndroidDateTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy.MM.dd HH:mm:ss').format(dateTime);
  }

  // セグメント化されたボタンを構築（Android版と同じ）
  Widget _buildSegmentButton(String text, String period, {bool isFirst = false, bool isLast = false}) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
            if (period == 'custom') {
              _showDateRangePicker();
            }
          });
        },
        child: Container(
          height: 30, // 枠の高さに合わせて調整
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent, // 選択時のみ白背景
            borderRadius: BorderRadius.circular(4), // 全体を角丸に（四角形ではなく）
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.black : const Color(0xFF999999), // 選択時は黒、未選択時はグレー
                fontSize: 12, // フォントサイズを小さく
                fontWeight: FontWeight.bold, // 太文字に変更
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 縦線の区切り
  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 18, // 高さも小さく調整
      color: const Color(0xFFD0D0D0),
    );
  }

  // 統計情報セクションを構築
  Widget _buildStatisticsSection(HistoryProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          _buildStatRow('損益:', provider.totalProfit),
          _buildStatRow('クレジット:', 0.0),
          _buildStatRow('証拠金:', 100000.0),
          _buildStatRow('出金:', 0.0),
          _buildStatRow('残高:', 101616.0), // Android版と同じ値
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
          Text(
            _formatAmountWithSpaces(value),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmountWithSpaces(double amount) {
    final formatted = amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]} ',
    );
    return formatted;
  }

}