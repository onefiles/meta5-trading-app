import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/platform_helper.dart';
import 'quotes_screen.dart';
import 'chart_screen.dart';
import 'trade_screen.dart';
import 'history_screen.dart';
import 'news_screen.dart';
import 'messages_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Android版と同じ：デフォルトは気配値画面

  final List<Widget> _screens = [
    const QuotesScreen(),
    const ChartScreen(),
    const TradeScreen(),
    const HistoryScreen(),
    const NewsScreen(),
    const MessagesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isIOS = PlatformHelper.isIOS;
    
    if (isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/ic_menu_quotes_gray.png',
                width: 32,
                height: 32,
              ),
              activeIcon: Image.asset(
                'assets/icons/ic_menu_quotes_blue.png',
                width: 32,
                height: 32,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/ic_menu_chart_gray.png',
                width: 32,
                height: 32,
              ),
              activeIcon: Image.asset(
                'assets/icons/ic_menu_chart_blue.png',
                width: 32,
                height: 32,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/ic_menu_trade_gray.png',
                width: 32,
                height: 32,
              ),
              activeIcon: Image.asset(
                'assets/icons/ic_menu_trade_blue.png',
                width: 32,
                height: 32,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/ic_menu_history_gray.png',
                width: 32,
                height: 32,
              ),
              activeIcon: Image.asset(
                'assets/icons/ic_menu_history_blue.png',
                width: 32,
                height: 32,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/ic_menu_news_gray.png',
                width: 32,
                height: 32,
              ),
              activeIcon: Image.asset(
                'assets/icons/ic_menu_news_blue.png',
                width: 32,
                height: 32,
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icons/ic_menu_messages_gray.png',
                width: 32,
                height: 32,
              ),
              activeIcon: Image.asset(
                'assets/icons/ic_menu_messages_blue.png',
                width: 32,
                height: 32,
              ),
              label: '',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          return CupertinoTabView(
            builder: (context) {
              return _screens[index];
            },
          );
        },
      );
    } else {
      return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
          height: 50,
          color: const Color(0xFFF8F8F8),
          child: Row(
            children: List.generate(6, (index) {
              final isSelected = _selectedIndex == index;
              final iconPaths = [
                ['assets/icons/ic_menu_quotes_gray.png', 'assets/icons/ic_menu_quotes_blue.png'],
                ['assets/icons/ic_menu_chart_gray.png', 'assets/icons/ic_menu_chart_blue.png'],
                ['assets/icons/ic_menu_trade_gray.png', 'assets/icons/ic_menu_trade_blue.png'],
                ['assets/icons/ic_menu_history_gray.png', 'assets/icons/ic_menu_history_blue.png'],
                ['assets/icons/ic_menu_news_gray.png', 'assets/icons/ic_menu_news_blue.png'],
                ['assets/icons/ic_menu_messages_gray.png', 'assets/icons/ic_menu_messages_blue.png'],
              ];
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    height: 50,
                    color: Colors.transparent,
                    child: Center(
                      child: Image.asset(
                        isSelected ? iconPaths[index][1] : iconPaths[index][0],
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.error,
                            size: 32,
                            color: Colors.red,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    }
  }
}