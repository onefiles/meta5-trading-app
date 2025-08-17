import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/platform_helper.dart';
import 'messages_screen_ios.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return const MessagesScreenIOS();
    }
    
    return const MessagesScreenAndroid();
  }
}

class MessageItem {
  final String title;
  final String content;
  final DateTime time;
  final String type; // system, trading, alert
  final bool isRead;
  
  MessageItem({
    required this.title,
    required this.content,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class MessagesScreenAndroid extends StatefulWidget {
  const MessagesScreenAndroid({Key? key}) : super(key: key);

  @override
  State<MessagesScreenAndroid> createState() => _MessagesScreenAndroidState();
}

class _MessagesScreenAndroidState extends State<MessagesScreenAndroid> {
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
        return Colors.blue;
      case 'alert':
        return Colors.orange;
      case 'system':
        return Colors.green;
      default:
        return Colors.grey;
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

  @override
  Widget build(BuildContext context) {
    final unreadCount = messages.where((m) => !m.isRead).length;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('メッセージ'),
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (String filter) {
              setState(() {
                selectedFilter = filter;
              });
            },
            itemBuilder: (BuildContext context) {
              return filters.map((String filter) {
                return PopupMenuItem<String>(
                  value: filter,
                  child: Row(
                    children: [
                      Icon(
                        selectedFilter == filter ? Icons.check : Icons.radio_button_unchecked,
                        color: selectedFilter == filter ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(filter),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF007aff),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedFilter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadDemoMessages();
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredMessages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final message = filteredMessages[index];
            return GestureDetector(
              onTap: () => _markAsRead(messages.indexOf(message)),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: message.isRead ? Colors.white : const Color(0xFFF8F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: message.isRead ? Colors.grey.shade200 : const Color(0xFF007aff).withOpacity(0.3),
                    width: message.isRead ? 1 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
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
                              color: Colors.white,
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
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(message.time),
                          style: TextStyle(
                            color: Colors.grey.shade500,
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
                        fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}