import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChartScreenIOS extends StatefulWidget {
  const ChartScreenIOS({Key? key}) : super(key: key);

  @override
  State<ChartScreenIOS> createState() => _ChartScreenIOSState();
}

class _ChartScreenIOSState extends State<ChartScreenIOS> {
  late WebViewController controller;
  String selectedSymbol = 'GBPJPY';
  String selectedTimeframe = '1H';
  bool isLoading = true;
  
  final List<String> symbols = ['GBPJPY', 'BTCJPY', 'XAUUSD', 'EURUSD', 'USDJPY'];
  final List<String> timeframes = ['1M', '5M', '15M', '30M', '1H', '4H', '1D'];

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_getChartUrl()));
  }

  String _getChartUrl() {
    return 'https://www.tradingview.com/chart/?symbol=FX_IDC:$selectedSymbol&interval=$selectedTimeframe&hide_side_toolbar=1&hide_top_toolbar=1&theme=light';
  }

  void _updateChart() {
    setState(() {
      isLoading = true;
    });
    controller.loadRequest(Uri.parse(_getChartUrl()));
  }

  void _showSymbolPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('通貨ペア選択'),
        actions: symbols.map((symbol) {
          return CupertinoActionSheetAction(
            onPressed: () {
              setState(() {
                selectedSymbol = symbol;
              });
              _updateChart();
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedSymbol == symbol)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue),
                const SizedBox(width: 8),
                Text(symbol),
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
        middle: const Text('チャート'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showSymbolPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              selectedSymbol,
              style: const TextStyle(
                color: CupertinoColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 時間足選択
            Container(
              height: 50,
              color: CupertinoColors.systemGroupedBackground,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: timeframes.length,
                itemBuilder: (context, index) {
                  final timeframe = timeframes[index];
                  final isSelected = timeframe == selectedTimeframe;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTimeframe = timeframe;
                      });
                      _updateChart();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? CupertinoColors.activeBlue : CupertinoColors.systemGrey4,
                        ),
                      ),
                      child: Text(
                        timeframe,
                        style: TextStyle(
                          color: isSelected ? CupertinoColors.white : CupertinoColors.label,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // チャートWebView
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: controller),
                  if (isLoading)
                    const Center(
                      child: CupertinoActivityIndicator(
                        radius: 20,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}