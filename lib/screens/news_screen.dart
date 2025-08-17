import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/platform_helper.dart';
import 'news_screen_ios.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformHelper.isIOS) {
      return const NewsScreenIOS();
    }
    
    return const NewsScreenAndroid();
  }
}

class NewsItem {
  final String title;
  final String description;
  final String time;
  final String category;
  final String impact; // High, Medium, Low
  
  NewsItem({
    required this.title,
    required this.description,
    required this.time,
    required this.category,
    required this.impact,
  });
}

class NewsScreenAndroid extends StatefulWidget {
  const NewsScreenAndroid({Key? key}) : super(key: key);

  @override
  State<NewsScreenAndroid> createState() => _NewsScreenAndroidState();
}

class _NewsScreenAndroidState extends State<NewsScreenAndroid> {
  List<NewsItem> newsItems = [];
  bool isLoading = false;
  String selectedFilter = '全て';
  
  final List<String> filters = ['全て', '高インパクト', '中インパクト', '低インパクト'];

  @override
  void initState() {
    super.initState();
    _loadDemoNews();
  }

  void _loadDemoNews() {
    setState(() {
      newsItems = [
        NewsItem(
          title: 'FOMC金利政策発表',
          description: 'FRBが政策金利を維持すると発表。ドル相場に影響。',
          time: '2時間前',
          category: '中央銀行',
          impact: 'High',
        ),
        NewsItem(
          title: '日本GDP成長率発表',
          description: '第2四半期GDP成長率が発表され、市場予想を上回る結果。',
          time: '4時間前',
          category: '経済指標',
          impact: 'Medium',
        ),
        NewsItem(
          title: '金価格が高値更新',
          description: '地政学的緊張の高まりを受け、金価格が史上最高値を更新。',
          time: '6時間前',
          category: 'コモディティ',
          impact: 'High',
        ),
        NewsItem(
          title: 'ユーロ圏インフレ率',
          description: 'ユーロ圏のインフレ率が予想を下回り、ECBの金利政策に影響か。',
          time: '8時間前',
          category: '経済指標',
          impact: 'Medium',
        ),
        NewsItem(
          title: '原油価格の動向',
          description: 'OPEC+の減産延長を受け、原油価格が上昇。エネルギー関連通貨に注目。',
          time: '12時間前',
          category: 'コモディティ',
          impact: 'Low',
        ),
      ];
    });
  }

  List<NewsItem> get filteredNews {
    if (selectedFilter == '全て') return newsItems;
    
    final impactMap = {
      '高インパクト': 'High',
      '中インパクト': 'Medium',
      '低インパクト': 'Low',
    };
    
    return newsItems.where((item) => item.impact == impactMap[selectedFilter]).toList();
  }

  Color _getImpactColor(String impact) {
    switch (impact) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('ニュース'),
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
          _loadDemoNews();
        },
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filteredNews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final news = filteredNews[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getImpactColor(news.impact),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          news.impact.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          news.category,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        news.time,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}