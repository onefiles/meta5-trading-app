import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../models/trade_history.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';

class HistoryScreenIOS extends StatefulWidget {
  const HistoryScreenIOS({Key? key}) : super(key: key);

  @override
  State<HistoryScreenIOS> createState() => _HistoryScreenIOSState();
}

class _HistoryScreenIOSState extends State<HistoryScreenIOS> {
  String _selectedPeriod = 'week';
  String _selectedSymbol = '全て';
  String _selectedType = '全て';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _symbols = ['全て', 'GBPJPY', 'BTCJPY', 'XAUUSD', 'EURUSD', 'USDJPY'];
  final List<String> _types = ['全て', '買い', '売り'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadHistory();
    });
  }

  List<TradeHistory> _getFilteredHistory(HistoryProvider provider) {
    var history = provider.getFilteredHistory(_selectedPeriod);
    
    // 検索クエリフィルター
    if (_searchQuery.isNotEmpty) {
      history = history.where((h) => 
        h.symbol.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        h.symbolDisplayName.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
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
    
    return history;
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('フィルター'),
        message: Column(
          children: [
            const SizedBox(height: 16),
            
            // 通貨ペア選択
            const Text('通貨ペア', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CupertinoSegmentedControl<String>(
              children: Map.fromIterables(
                _symbols.take(3),
                _symbols.take(3).map((s) => Text(s)),
              ),
              onValueChanged: (value) {
                setState(() {
                  _selectedSymbol = value;
                });
              },
              groupValue: _symbols.take(3).contains(_selectedSymbol) ? _selectedSymbol : _symbols.first,
            ),
            
            const SizedBox(height: 16),
            
            // 取引タイプ選択
            const Text('取引タイプ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            CupertinoSegmentedControl<String>(
              children: Map.fromIterables(
                _types,
                _types.map((t) => Text(t)),
              ),
              onValueChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
              groupValue: _selectedType,
            ),
          ],
        ),
        actions: [
          CupertinoActionSheetAction(
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
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('完了'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showPeriodMenu() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('期間選択'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => _selectPeriod('day', '日'),
            child: const Text('日'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _selectPeriod('week', '週'),
            child: const Text('週'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _selectPeriod('month', '月'),
            child: const Text('月'),
          ),
          CupertinoActionSheetAction(
            onPressed: () => _selectPeriod('three_months', '3ヶ月'),
            child: const Text('3ヶ月'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _showDatePicker();
            },
            child: const Text('カスタム'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('キャンセル'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _selectPeriod(String value, String label) {
    setState(() {
      _selectedPeriod = value;
      _customStartDate = null;
      _customEndDate = null;
    });
    Navigator.pop(context);
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.white,
        child: Column(
          children: [
            Container(
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('キャンセル'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('完了'),
                    onPressed: () {
                      setState(() {
                        _selectedPeriod = 'custom';
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _customStartDate ?? DateTime.now().subtract(const Duration(days: 7)),
                onDateTimeChanged: (DateTime date) {
                  setState(() {
                    _customStartDate = date;
                    _customEndDate = date.add(const Duration(days: 7));
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Column(
          children: [
            // 期間選択タブ
            Container(
              color: CupertinoColors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPeriodTab('日', 'day'),
                  _buildPeriodTab('週', 'week'),
                  _buildPeriodTab('月', 'month'),
                  _buildPeriodTab('カスタム', 'custom'),
                ],
              ),
            ),
            
            // 検索ボックス
            Container(
              color: CupertinoColors.systemGroupedBackground,
              padding: const EdgeInsets.all(12),
              child: CupertinoTextField(
                controller: _searchController,
                placeholder: '検索シンボルを入力',
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    CupertinoIcons.search,
                    color: CupertinoColors.systemGrey,
                    size: 20,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                clearButtonMode: OverlayVisibilityMode.editing,
              ),
            ),
            
            // 履歴リスト
            Expanded(
              child: Consumer<HistoryProvider>(
                builder: (context, provider, child) {
                  final history = _getFilteredHistory(provider);
                  
                  if (history.isEmpty) {
                    return const Center(
                      child: Text(
                        'たこ焼き 🐙',
                        style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return _buildHistoryItem(item);
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

  Widget _buildPeriodTab(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () {
        if (value == 'custom') {
          _showDatePicker();
        } else {
          setState(() {
            _selectedPeriod = value;
            _customStartDate = null;
            _customEndDate = null;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CupertinoColors.systemGrey5 : CupertinoColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.label,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDeleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CupertinoColors.activeBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CupertinoColors.activeBlue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.activeBlue,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDeleted,
            child: const Icon(
              CupertinoIcons.xmark,
              size: 12,
              color: CupertinoColors.activeBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(TradeHistory history) {
    final isBalanceOrCredit = history.type == OrderType.balance || history.type == OrderType.credit;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
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
                    : '${history.symbolDisplayName},',
                style: TextStyle(
                  color: isBalanceOrCredit ? CupertinoColors.label : CupertinoColors.systemGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              
              // タイプ
              if (!isBalanceOrCredit)
                Text(
                  history.typeText,
                  style: TextStyle(
                    color: history.type == OrderType.buy 
                        ? CupertinoColors.activeBlue 
                        : CupertinoColors.destructiveRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 8),
              
              // ロット数
              if (!isBalanceOrCredit)
                Text(
                  history.lots.toStringAsFixed(2),
                  style: TextStyle(
                    color: history.type == OrderType.buy 
                        ? CupertinoColors.activeBlue 
                        : CupertinoColors.destructiveRed,
                    fontSize: 14,
                  ),
                ),
              
              const Spacer(),
              
              // 決済時刻
              Text(
                history.formattedCloseTime,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey2,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 下段：価格範囲と損益
          Row(
            children: [
              // 価格範囲
              if (!isBalanceOrCredit)
                Expanded(
                  child: Text(
                    '${_formatPriceWithSpaces(history.openPrice, history.symbol)} → '
                    '${_formatPriceWithSpaces(history.closePrice, history.symbol)}',
                    style: const TextStyle(
                      color: CupertinoColors.systemGrey2,
                      fontSize: 12,
                    ),
                  ),
                ),
              
              // 損益
              Text(
                _formatProfitWithSpaces(history.profit),
                style: TextStyle(
                  color: history.profit >= 0 
                      ? CupertinoColors.activeBlue 
                      : CupertinoColors.destructiveRed,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
    
    return profit < 0 ? '-$formattedNumber' : formattedNumber;
  }
}