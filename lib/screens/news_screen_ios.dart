import 'package:flutter/cupertino.dart';
import 'news_screen.dart';

class NewsScreenIOS extends StatefulWidget {
  const NewsScreenIOS({Key? key}) : super(key: key);

  @override
  State<NewsScreenIOS> createState() => _NewsScreenIOSState();
}

class _NewsScreenIOSState extends State<NewsScreenIOS> {
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
        return CupertinoColors.destructiveRed;
      case 'Medium':
        return CupertinoColors.systemOrange;
      case 'Low':
        return CupertinoColors.systemGreen;
      default:
        return CupertinoColors.systemGrey;
    }
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('ニュース'),
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
                _loadDemoNews();
              },
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final news = filteredNews[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
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
                                  color: _getImpactColor(news.impact),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  news.impact.toUpperCase(),
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.systemGrey5,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  news.category,
                                  style: const TextStyle(
                                    color: CupertinoColors.systemGrey,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                news.time,
                                style: const TextStyle(
                                  color: CupertinoColors.systemGrey2,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            news.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: CupertinoColors.systemGrey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: filteredNews.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}