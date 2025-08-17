import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../utils/platform_helper.dart';
import '../providers/alert_provider.dart';
import '../models/price_alert.dart';
import '../models/order.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AlertProvider>().loadAlerts();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return _buildIOSLayout();
    }
    return _buildAndroidLayout();
  }

  Widget _buildAndroidLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '価格アラート',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<AlertProvider>(
            builder: (context, provider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                onSelected: (value) {
                  switch (value) {
                    case 'clear_triggered':
                      _showClearTriggeredDialog();
                      break;
                    case 'clear_expired':
                      _showClearExpiredDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear_triggered',
                    child: Text('発動済みアラートを削除 (${provider.triggeredAlertCount})'),
                  ),
                  const PopupMenuItem(
                    value: 'clear_expired',
                    child: Text('期限切れアラートを削除'),
                  ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Consumer<AlertProvider>(
              builder: (context, provider, child) => Tab(
                text: 'アクティブ (${provider.activeAlertCount})',
              ),
            ),
            Consumer<AlertProvider>(
              builder: (context, provider, child) => Tab(
                text: '発動済み (${provider.triggeredAlertCount})',
              ),
            ),
            const Tab(text: '全て'),
          ],
          labelColor: const Color(0xFF007aff),
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAlertList(AlertStatus.active),
          _buildAlertList(AlertStatus.triggered),
          _buildAlertList(null), // 全て
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateAlertDialog,
        backgroundColor: const Color(0xFF007aff),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildIOSLayout() {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('価格アラート'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _showCreateAlertDialog,
        ),
      ),
      child: Column(
        children: [
          CupertinoSegmentedControl<int>(
            children: const {
              0: Text('アクティブ'),
              1: Text('発動済み'),
              2: Text('全て'),
            },
            onValueChanged: (value) {
              _tabController.animateTo(value);
            },
            groupValue: _tabController.index,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAlertList(AlertStatus.active),
                _buildAlertList(AlertStatus.triggered),
                _buildAlertList(null),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertList(AlertStatus? filterStatus) {
    return Consumer<AlertProvider>(
      builder: (context, provider, child) {
        List<PriceAlert> alerts;
        if (filterStatus == null) {
          alerts = provider.alerts;
        } else {
          alerts = provider.alerts.where((a) => a.status == filterStatus).toList();
        }

        if (alerts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  filterStatus == AlertStatus.active
                      ? 'アクティブなアラートがありません'
                      : filterStatus == AlertStatus.triggered
                          ? '発動済みアラートがありません'
                          : 'アラートがありません',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                if (filterStatus == AlertStatus.active) ...[
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showCreateAlertDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('アラートを作成'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007aff),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            return _buildAlertItem(alert);
          },
        );
      },
    );
  }

  Widget _buildAlertItem(PriceAlert alert) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: alert.status == AlertStatus.triggered
              ? Colors.orange.shade300
              : alert.status == AlertStatus.active
                  ? Colors.green.shade300
                  : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 上段：シンボル、価格、条件
          Row(
            children: [
              Text(
                alert.symbol,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getConditionColor(alert.condition).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  alert.conditionText,
                  style: TextStyle(
                    color: _getConditionColor(alert.condition),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              _buildStatusBadge(alert.status),
            ],
          ),

          const SizedBox(height: 8),

          // 価格表示
          Row(
            children: [
              const Text('目標価格: ', style: TextStyle(color: Colors.grey)),
              Text(
                _formatPrice(alert.targetPrice, alert.symbol),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (alert.note != null && alert.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.note, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.note!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // 下段：作成日時とアクション
          Row(
            children: [
              Text(
                '作成: ${DateFormat('MM/dd HH:mm').format(alert.createdTime)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              if (alert.triggeredTime != null) ...[
                const SizedBox(width: 16),
                Text(
                  '発動: ${DateFormat('MM/dd HH:mm').format(alert.triggeredTime!)}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(),
              if (alert.status == AlertStatus.active) ...[
                IconButton(
                  onPressed: () => _toggleAlert(alert),
                  icon: const Icon(Icons.pause, size: 20),
                  color: Colors.orange,
                ),
              ] else if (alert.status == AlertStatus.disabled) ...[
                IconButton(
                  onPressed: () => _toggleAlert(alert),
                  icon: const Icon(Icons.play_arrow, size: 20),
                  color: Colors.green,
                ),
              ],
              IconButton(
                onPressed: () => _deleteAlert(alert),
                icon: const Icon(Icons.delete, size: 20),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(AlertStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case AlertStatus.active:
        color = Colors.green;
        text = 'アクティブ';
        break;
      case AlertStatus.triggered:
        color = Colors.orange;
        text = '発動済み';
        break;
      case AlertStatus.expired:
        color = Colors.grey;
        text = '期限切れ';
        break;
      case AlertStatus.disabled:
        color = Colors.red;
        text = '無効';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getConditionColor(AlertCondition condition) {
    switch (condition) {
      case AlertCondition.above:
      case AlertCondition.crossesAbove:
        return Colors.green;
      case AlertCondition.below:
      case AlertCondition.crossesBelow:
        return Colors.red;
    }
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
      
      return chunks.reversed.join(',');
    } else if (symbol == 'GBPJPY') {
      return price.toStringAsFixed(3);
    } else {
      return price.toStringAsFixed(2);
    }
  }

  void _showCreateAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateAlertDialog(),
    );
  }

  void _toggleAlert(PriceAlert alert) async {
    if (alert.status == AlertStatus.active) {
      await context.read<AlertProvider>().disableAlert(alert.id);
    } else {
      await context.read<AlertProvider>().enableAlert(alert.id);
    }
  }

  void _deleteAlert(PriceAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('アラート削除'),
        content: Text('${alert.symbol} のアラートを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<AlertProvider>().deleteAlert(alert.id);
              Navigator.pop(context);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearTriggeredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('発動済みアラート削除'),
        content: const Text('全ての発動済みアラートを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<AlertProvider>().clearTriggeredAlerts();
              Navigator.pop(context);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showClearExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('期限切れアラート削除'),
        content: const Text('全ての期限切れアラートを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              context.read<AlertProvider>().clearExpiredAlerts();
              Navigator.pop(context);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class CreateAlertDialog extends StatefulWidget {
  const CreateAlertDialog({Key? key}) : super(key: key);

  @override
  State<CreateAlertDialog> createState() => _CreateAlertDialogState();
}

class _CreateAlertDialogState extends State<CreateAlertDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedSymbol = 'GBPJPY';
  AlertCondition _selectedCondition = AlertCondition.above;
  DateTime? _expiryDate;

  final List<String> _symbols = ['GBPJPY', 'BTCJPY', 'XAUUSD', 'EURUSD', 'USDJPY'];

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新しいアラート'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 通貨ペア選択
              DropdownButtonFormField<String>(
                value: _selectedSymbol,
                decoration: const InputDecoration(
                  labelText: '通貨ペア',
                  border: OutlineInputBorder(),
                ),
                items: _symbols.map((symbol) {
                  return DropdownMenuItem(
                    value: symbol,
                    child: Text(symbol),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSymbol = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // 目標価格
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '目標価格',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '価格を入力してください';
                  }
                  if (double.tryParse(value) == null) {
                    return '有効な数値を入力してください';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // 条件選択
              DropdownButtonFormField<AlertCondition>(
                value: _selectedCondition,
                decoration: const InputDecoration(
                  labelText: '条件',
                  border: OutlineInputBorder(),
                ),
                items: AlertCondition.values.map((condition) {
                  String text;
                  switch (condition) {
                    case AlertCondition.above:
                      text = '以上';
                      break;
                    case AlertCondition.below:
                      text = '以下';
                      break;
                    case AlertCondition.crossesAbove:
                      text = '上抜け';
                      break;
                    case AlertCondition.crossesBelow:
                      text = '下抜け';
                      break;
                  }
                  return DropdownMenuItem(
                    value: condition,
                    child: Text(text),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // メモ（オプション）
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'メモ（オプション）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              
              const SizedBox(height: 16),
              
              // 期限設定（オプション）
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _expiryDate == null
                          ? '期限なし'
                          : '期限: ${DateFormat('yyyy/MM/dd').format(_expiryDate!)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: _selectExpiryDate,
                    child: Text(_expiryDate == null ? '期限設定' : '変更'),
                  ),
                  if (_expiryDate != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _expiryDate = null;
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _createAlert,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007aff),
          ),
          child: const Text('作成', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  void _createAlert() {
    if (_formKey.currentState!.validate()) {
      final alert = PriceAlert(
        symbol: _selectedSymbol,
        targetPrice: double.parse(_priceController.text),
        condition: _selectedCondition,
        expiryTime: _expiryDate,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      context.read<AlertProvider>().addAlert(alert);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_selectedSymbol} のアラートを作成しました'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}