import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../utils/platform_helper.dart';
import '../services/api_service.dart';
import '../providers/price_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedUpdateSpeed = '通常';
  bool _enableNotifications = true;
  bool _enableVibration = true;
  bool _enableSound = true;
  String _language = '日本語';
  String _theme = 'ライト';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedUpdateSpeed = prefs.getString('update_speed') ?? '通常';
      _enableNotifications = prefs.getBool('enable_notifications') ?? true;
      _enableVibration = prefs.getBool('enable_vibration') ?? true;
      _enableSound = prefs.getBool('enable_sound') ?? true;
      _language = prefs.getString('language') ?? '日本語';
      _theme = prefs.getString('theme') ?? 'ライト';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('update_speed', _selectedUpdateSpeed);
    await prefs.setBool('enable_notifications', _enableNotifications);
    await prefs.setBool('enable_vibration', _enableVibration);
    await prefs.setBool('enable_sound', _enableSound);
    await prefs.setString('language', _language);
    await prefs.setString('theme', _theme);
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
          '設定',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          _buildSection('価格更新', [
            _buildUpdateSpeedSetting(),
            _buildManualUpdateButton(),
          ]),
          
          _buildSection('通知設定', [
            _buildSwitchTile(
              '通知を有効化',
              '価格アラートなどの通知を受け取る',
              _enableNotifications,
              (value) {
                setState(() {
                  _enableNotifications = value;
                });
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              'バイブレーション',
              '通知時にバイブレーションする',
              _enableVibration,
              (value) {
                setState(() {
                  _enableVibration = value;
                });
                _saveSettings();
              },
            ),
            _buildSwitchTile(
              'サウンド',
              '通知時に音を再生する',
              _enableSound,
              (value) {
                setState(() {
                  _enableSound = value;
                });
                _saveSettings();
              },
            ),
          ]),
          
          _buildSection('表示設定', [
            _buildDropdownTile(
              '言語',
              _language,
              ['日本語', 'English'],
              (value) {
                setState(() {
                  _language = value!;
                });
                _saveSettings();
              },
            ),
            _buildDropdownTile(
              'テーマ',
              _theme,
              ['ライト', 'ダーク'],
              (value) {
                setState(() {
                  _theme = value!;
                });
                _saveSettings();
              },
            ),
          ]),
          
          _buildSection('アプリ情報', [
            _buildInfoTile('バージョン', '1.0.0'),
            _buildInfoTile('ビルド番号', '1'),
            _buildActionTile('利用規約', () => _showTerms()),
            _buildActionTile('プライバシーポリシー', () => _showPrivacyPolicy()),
          ]),
        ],
      ),
    );
  }

  Widget _buildIOSLayout() {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('設定'),
      ),
      child: ListView(
        children: [
          _buildSection('価格更新', [
            _buildUpdateSpeedSetting(),
            _buildManualUpdateButton(),
          ]),
          // 他のセクションも同様に実装
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateSpeedSetting() {
    return ListTile(
      title: const Text('更新速度'),
      subtitle: Text('現在: $_selectedUpdateSpeed'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: _showUpdateSpeedDialog,
    );
  }

  Widget _buildManualUpdateButton() {
    return ListTile(
      title: const Text('手動更新'),
      subtitle: const Text('価格を今すぐ更新'),
      trailing: const Icon(Icons.refresh),
      onTap: () {
        ApiService().manualUpdate();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('価格を更新しました'),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF007aff),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return ListTile(
      title: Text(title),
      subtitle: Text(value),
      trailing: DropdownButton<String>(
        value: value,
        underline: Container(),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildActionTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showUpdateSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更新速度設定'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ApiService.updateIntervals.keys.map((speed) {
            return RadioListTile<String>(
              title: Text(speed),
              subtitle: Text(_getSpeedDescription(speed)),
              value: speed,
              groupValue: _selectedUpdateSpeed,
              onChanged: (value) {
                setState(() {
                  _selectedUpdateSpeed = value!;
                });
                // APIサービスに反映
                ApiService().setUpdateSpeed(_selectedUpdateSpeed);
                _saveSettings();
                Navigator.pop(context);
              },
            );
          }).toList(),
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

  String _getSpeedDescription(String speed) {
    switch (speed) {
      case '高速':
        return '0.5秒間隔（バッテリー消費大）';
      case '通常':
        return '1秒間隔（推奨）';
      case '低速':
        return '2秒間隔（バッテリー節約）';
      case '手動':
        return '自動更新なし';
      default:
        return '';
    }
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('利用規約'),
        content: const SingleChildScrollView(
          child: Text(
            'Meta5 取引アプリ利用規約\n\n'
            '1. 本アプリはデモ用途です\n'
            '2. 実際の取引は行われません\n'
            '3. 価格データはシミュレーションです\n'
            '4. 投資判断は自己責任で行ってください\n\n'
            '詳細は公式サイトをご確認ください。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('プライバシーポリシー'),
        content: const SingleChildScrollView(
          child: Text(
            'プライバシーポリシー\n\n'
            '1. 個人情報の取り扱い\n'
            '本アプリは個人情報を収集しません。\n\n'
            '2. データの保存\n'
            '取引データはローカルに保存されます。\n\n'
            '3. 第三者への提供\n'
            'データを第三者に提供することはありません。\n\n'
            '詳細は公式サイトをご確認ください。',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }
}