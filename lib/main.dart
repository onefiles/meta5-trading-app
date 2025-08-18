import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'utils/platform_helper.dart';
import 'package:provider/provider.dart';
import 'screens/main_screen.dart';
import 'providers/order_provider.dart';
import 'providers/price_provider.dart';
import 'providers/history_provider.dart';
import 'providers/alert_provider.dart';
import 'services/notification_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Android風のステータスバー設定
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const Meta5App());
}

class Meta5App extends StatelessWidget {
  const Meta5App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIOS = PlatformHelper.isIOS;
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => PriceProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => AlertProvider()),
      ],
      child: isIOS
          ? CupertinoApp(
              title: 'Meta5',
              debugShowCheckedModeBanner: false,
              theme: const CupertinoThemeData(
                primaryColor: CupertinoColors.activeBlue,
                scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
                textTheme: CupertinoTextThemeData(
                  primaryColor: CupertinoColors.label,
                ),
              ),
              home: const AppWrapper(),
            )
          : MaterialApp(
              title: 'Meta5',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                // Android風のMaterial Designテーマ
                primarySwatch: Colors.blue,
                scaffoldBackgroundColor: Colors.white,
                fontFamily: 'Roboto',
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: IconThemeData(color: Colors.black),
                  titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                  backgroundColor: Color(0xFFF8F8F8),
                  selectedItemColor: Color(0xFF007aff),
                  unselectedItemColor: Color(0xFF999999),
                  showUnselectedLabels: false,
                  showSelectedLabels: false,
                  type: BottomNavigationBarType.fixed,
                  elevation: 0,
                ),
              ),
              home: const AppWrapper(),
            ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  @override
  void initState() {
    super.initState();
    
    // プロバイダー間の接続を設定
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final priceProvider = context.read<PriceProvider>();
      final orderProvider = context.read<OrderProvider>();
      final alertProvider = context.read<AlertProvider>();
      final historyProvider = context.read<HistoryProvider>();
      
      // OrderProviderにPriceProviderとHistoryProviderを設定
      orderProvider.setPriceProvider(priceProvider);
      orderProvider.setHistoryProvider(historyProvider);
      
      // 価格更新時のアラートチェックを設定
      priceProvider.setPriceUpdateCallback((symbol, price) {
        alertProvider.checkAlertsForPrice(symbol, price);
      });
      
      // 価格更新を開始（Android版と同じように自動開始）
      priceProvider.startPriceUpdates();
      print('Price updates started automatically on app launch');
      
      // 通知サービスにコンテキストを設定
      final notificationService = NotificationService();
      notificationService.setContext(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainScreen();
  }
}