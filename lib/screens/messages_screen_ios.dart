import 'package:flutter/cupertino.dart';
import 'messages_screen.dart';

class MessagesScreenIOS extends StatefulWidget {
  const MessagesScreenIOS({Key? key}) : super(key: key);

  @override
  State<MessagesScreenIOS> createState() => _MessagesScreenIOSState();
}

class _MessagesScreenIOSState extends State<MessagesScreenIOS> {
  List<MessageItem> messages = [];
  String selectedFilter = '全て';
  
  final List<String> filters = ['全て', 'システム', '取引', 'アラート'];

  @override
  void initState() {
    super.initState();
    _loadDemoMessages();
  }

  void _loadDemoMessages() {
    setState(() {
      messages = [
        MessageItem(
          title: 'ポジション決済完了',
          content: 'GBPJPY 0.5ロットの売りポジションが決済されました。\n損益: +15,432円',
          time: DateTime.now().subtract(const Duration(minutes: 30)),
          type: 'trading',
          isRead: false,
        ),
        MessageItem(
          title: 'マージンコール警告',
          content: '証拠金維持率が100%を下回りました。追加証拠金の入金またはポジションの決済をご検討ください。',
          time: DateTime.now().subtract(const Duration(hours: 2)),
          type: 'alert',
          isRead: false,
        ),
        MessageItem(
          title: 'システムメンテナンス通知',
          content: '本日23:00-24:00にシステムメンテナンスを実施いたします。\nその間、取引が一時停止される場合があります。',
          time: DateTime.now().subtract(const Duration(hours: 4)),
          type: 'system',
          isRead: true,
        ),
        MessageItem(
          title: '新規注文約定',
          content: 'BTCJPY 0.1ロットの買い注文が約定しました。\n約定価格: 7,500,000円',
          time: DateTime.now().subtract(const Duration(hours: 6)),
          type: 'trading',
          isRead: true,
        ),
        MessageItem(
          title: '重要な経済指標発表',
          content: '本日21:30に米国雇用統計が発表されます。\n市場のボラティリティが高まる可能性があります。',
          time: DateTime.now().subtract(const Duration(days: 1)),
          type: 'alert',
          isRead: true,
        ),
      ];
    });
  }

  List<MessageItem> get filteredMessages {
    if (selectedFilter == '全て') return messages;
    
    final typeMap = {
      'システム': 'system',
      '取引': 'trading',
      'アラート': 'alert',
    };
    
    return messages.where((item) => item.type == typeMap[selectedFilter]).toList();
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'trading':
        return CupertinoColors.activeBlue;
      case 'alert':
        return CupertinoColors.systemOrange;
      case 'system':
        return CupertinoColors.systemGreen;
      default:
        return CupertinoColors.systemGrey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'trading':
        return '取引';
      case 'alert':
        return 'アラート';
      case 'system':
        return 'システム';
      default:
        return '不明';
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}時間前';
    } else {
      return '${diff.inDays}日前';
    }
  }

  void _markAsRead(int index) {
    setState(() {
      messages[index] = MessageItem(
        title: messages[index].title,
        content: messages[index].content,
        time: messages[index].time,
        type: messages[index].type,
        isRead: true,
      );
    });
  }

  void _showFilterPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('フィルター選択'),
        actions: filters.map((filter) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                selectedFilter = filter;
              });
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedFilter == filter)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue),
                const SizedBox(width: 8),
                Text(filter),
              ],
            ),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('キャンセル'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = messages.where((m) => !m.isRead).length;
    
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('メッセージ'),
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: CupertinoColors.destructiveRed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showFilterPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              selectedFilter,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                _loadDemoMessages();
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final message = filteredMessages[index];
                    return GestureDetector(
                      onTap: () => _markAsRead(messages.indexOf(message)),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: message.isRead ? CupertinoColors.white : const Color(0xFFF8F9FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: message.isRead 
                                ? CupertinoColors.systemGrey4 
                                : CupertinoColors.activeBlue.withOpacity(0.3),
                            width: message.isRead ? 1 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CupertinoColors.systemGrey.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(message.type),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _getTypeLabel(message.type),
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (!message.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: CupertinoColors.destructiveRed,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTime(message.time),
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: message.isRead ? FontWeight.normal : FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message.content,
                              style: const TextStyle(
                                fontSize: 14,
                                color: CupertinoColors.systemGrey,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: filteredMessages.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}