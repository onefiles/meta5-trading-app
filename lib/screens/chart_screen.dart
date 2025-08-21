import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/platform_helper.dart';
import '../providers/order_provider.dart';
import '../providers/history_provider.dart';
import '../models/trade_history.dart';
import '../models/order.dart';
import '../services/profit_calculator.dart';
import 'chart_screen_ios.dart';
import 'font_settings_screen.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return const ChartScreenIOS();
    }
    
    return const AccountManagementScreen();
  }
}

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({Key? key}) : super(key: key);

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  double currentCredit = 200000.0;
  String currentUpdateSpeed = '通常';
  double get currentBalance => context.read<OrderProvider>().balance;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentCredit = prefs.getDouble('credit') ?? 200000.0;
      currentUpdateSpeed = prefs.getString('update_speed') ?? '通常';
    });
  }

  Future<void> _saveCredit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('credit', currentCredit);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'アカウント管理',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 現在の状況
            _buildCurrentStatusCard(),
            const SizedBox(height: 16),
            
            // 入金・出金ボタン
            _buildDepositWithdrawSection(),
            const SizedBox(height: 16),
            
            // クレジット・残高調整
            _buildCreditBalanceSection(),
            const SizedBox(height: 16),
            
            // フォント設定
            _buildFontSection(),
            const SizedBox(height: 16),
            
            // 設定・リセット
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'フォント設定',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FontSettingsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('フォント設定'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '現在の状況',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('残高:', style: TextStyle(fontSize: 16)),
                Consumer<OrderProvider>(
                  builder: (context, provider, child) => Text(
                    '¥${_formatAmount(provider.balance)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('クレジット:', style: TextStyle(fontSize: 16)),
                Text(
                  '¥${_formatAmount(currentCredit)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007aff),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositWithdrawSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '入金・出金',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showDepositDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('入金'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showWithdrawDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('出金'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditBalanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'クレジット・残高調整',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showCreditDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007aff),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('クレジット設定'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showBalanceAdjustDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('残高調整'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '設定・リセット',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showUpdateSpeedDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('更新速度: $currentUpdateSpeed'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showResetDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('リセット'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    // Android版と同じスペース区切りフォーマットを使用
    return ProfitCalculator.formatAmount(amount);
  }

  void _showDepositDialog() {
    _showAmountDialogWithDescription('入金', (amount, description) async {
      await context.read<OrderProvider>().addToBalance(amount);
      _addBalanceHistoryWithDescription(amount, 'Balance', description);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¥${_formatAmount(amount)}を入金しました')),
      );
    });
  }

  void _showWithdrawDialog() {
    _showAmountDialogWithDescription('出金', (amount, description) async {
      final currentBalance = context.read<OrderProvider>().balance;
      if (amount > currentBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('残高が不足しています')),
        );
        return;
      }
      
      final oldCredit = currentCredit;
      await context.read<OrderProvider>().addToBalance(-amount);
      
      // Android版と同じ：出金時にクレジットも消失
      if (oldCredit > 0) {
        await context.read<OrderProvider>().updateCredit(0.0);
        setState(() {
          currentCredit = 0;
        });
        _addBalanceHistoryWithDescription(-oldCredit, 'Balance', 'Credit cleared'); // クレジット消失分も履歴に記録
      }
      _addBalanceHistoryWithDescription(-amount, 'Balance', description);
      
      final message = oldCredit > 0
          ? '¥${_formatAmount(amount)}を出金し、クレジット¥${_formatAmount(oldCredit)}が消失しました'
          : '¥${_formatAmount(amount)}を出金しました';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  void _showCreditDialog() {
    _showAmountDialogWithDescription('クレジット設定', (amount, description) async {
      // OrderProviderでクレジットを更新（全画面に即座反映）
      await context.read<OrderProvider>().updateCredit(amount);
      setState(() {
        currentCredit = amount;
      });
      _addCreditHistoryWithDescription(amount, description);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('クレジットを¥${_formatAmount(amount)}に設定しました')),
      );
    });
  }

  void _showBalanceAdjustDialog() {
    _showAmountDialog('残高調整', (amount) async {
      await context.read<OrderProvider>().updateBalance(amount);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('残高を¥${_formatAmount(amount)}に調整しました')),
      );
    });
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('リセット確認'),
        content: const Text('残高とクレジットを0円にリセットしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              // OrderProviderでリセット（全画面に即座反映）
              await context.read<OrderProvider>().resetAccount();
              setState(() {
                currentCredit = 0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('残高とクレジットをリセットしました')),
              );
            },
            child: const Text('リセット', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUpdateSpeedDialog() {
    // Android版と同じ5段階の詳細設定
    final speedOptions = {
      '超高速 (50ms)': 50,
      '高速 (100ms)': 100,
      '通常 (200ms)': 200,
      '低速 (500ms)': 500,
      '超低速 (1000ms)': 1000,
    };
    
    // 現在の設定を取得
    String currentSpeedName = '通常 (200ms)';
    speedOptions.forEach((name, ms) {
      if (name.contains(currentUpdateSpeed)) {
        currentSpeedName = name;
      }
    });
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新速度設定'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: speedOptions.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.key),
                value: entry.key,
                groupValue: currentSpeedName,
                onChanged: (value) async {
                  final selectedMs = speedOptions[value!]!;
                  final speedName = value.split(' ')[0]; // '高速'のみを抽出
                  
                  setState(() {
                    currentUpdateSpeed = speedName;
                  });
                  
                  // SharedPreferencesに保存
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('update_speed', speedName);
                  await prefs.setInt('update_speed_ms', selectedMs);
                  
                  // API Serviceに速度変更を通知（Android版と同じ）
                  // TODO: ApiServiceに速度変更を通知するメソッドを追加
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('更新速度を${selectedMs}msに変更しました')),
                  );
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _showAmountDialog(String title, Function(double) onConfirm) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '金額',
            hintText: '金額を入力してください',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                onConfirm(amount);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('正しい金額を入力してください')),
                );
              }
            },
            child: const Text('実行'),
          ),
        ],
      ),
    );
  }

  void _showAmountDialogWithDescription(String title, Function(double, String) onConfirm) {
    final amountController = TextEditingController();
    
    // 第1段階：金額入力
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '金額',
            hintText: '金額を入力してください',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                // 第2段階：メッセージ入力
                _showDescriptionDialog(title, amount, onConfirm);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('正しい金額を入力してください')),
                );
              }
            },
            child: const Text('次へ'),
          ),
        ],
      ),
    );
  }

  void _showDescriptionDialog(String title, double amount, Function(double, String) onConfirm) {
    final descriptionController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$title - メッセージ入力'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('金額: ¥${_formatAmount(amount)}'),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'メッセージ（任意）',
                hintText: '例: Deposit: 8520111',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final description = descriptionController.text.isEmpty 
                  ? '$title: ${amount.toInt()}'
                  : descriptionController.text;
              onConfirm(amount, description);
              Navigator.pop(context);
            },
            child: const Text('実行'),
          ),
        ],
      ),
    );
  }

  void _addBalanceHistory(double amount, String symbol) {
    // Android版と同じ：入金・出金履歴を記録
    final history = TradeHistory(
      symbol: symbol,
      type: OrderType.balance,
      lots: 0.0,
      openPrice: 0.0,
      closePrice: 0.0,
      profit: amount,
      openTime: DateTime.now().millisecondsSinceEpoch,
      closeTime: DateTime.now().millisecondsSinceEpoch,
    );
    
    print('Adding balance history: $amount for $symbol');
    context.read<HistoryProvider>().addHistory(history);
  }

  void _addCreditHistory(double amount) {
    // Android版と同じ：クレジット履歴を記録
    final history = TradeHistory(
      symbol: 'Credit',
      type: OrderType.credit,
      lots: 0.0,
      openPrice: 0.0,
      closePrice: 0.0,
      profit: amount,
      openTime: DateTime.now().millisecondsSinceEpoch,
      closeTime: DateTime.now().millisecondsSinceEpoch,
    );
    
    print('Adding credit history: $amount');
    context.read<HistoryProvider>().addHistory(history);
  }

  void _addBalanceHistoryWithDescription(double amount, String symbol, String description) {
    // カスタムメッセージ付きの入金・出金履歴を記録
    final history = TradeHistory(
      symbol: symbol,
      type: OrderType.balance,
      lots: 0.0,
      openPrice: 0.0,
      closePrice: 0.0,
      profit: amount,
      openTime: DateTime.now().millisecondsSinceEpoch,
      closeTime: DateTime.now().millisecondsSinceEpoch,
      description: description,
    );
    
    print('Adding balance history with description: $amount for $symbol - $description');
    context.read<HistoryProvider>().addHistory(history);
  }

  void _addCreditHistoryWithDescription(double amount, String description) {
    // カスタムメッセージ付きのクレジット履歴を記録
    final history = TradeHistory(
      symbol: 'Credit',
      type: OrderType.credit,
      lots: 0.0,
      openPrice: 0.0,
      closePrice: 0.0,
      profit: amount,
      openTime: DateTime.now().millisecondsSinceEpoch,
      closeTime: DateTime.now().millisecondsSinceEpoch,
      description: description,
    );
    
    print('Adding credit history with description: $amount - $description');
    context.read<HistoryProvider>().addHistory(history);
  }
}