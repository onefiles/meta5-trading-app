import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider extends ChangeNotifier {
  // フォント種類の定義
  static const List<String> fontFamilies = [
    'sans-serif',
    'sans-serif-medium', 
    'sans-serif-condensed',
    'monospace',
  ];
  
  static const List<int> fontSizes = [12, 14, 16, 18, 20];
  static const List<int> fontWeights = [400, 500, 700, 900];
  
  // ポジション方向の設定
  String _positionFontFamily = 'Roboto Condensed';
  int _positionFontSize = 14;
  int _positionFontWeight = 700;
  bool _positionIsBold = true;
  
  // 価格データの設定
  String _priceFontFamily = 'Roboto Medium';
  int _priceFontSize = 16;
  int _priceFontWeight = 700;
  bool _priceIsBold = true;
  
  // 損益の設定
  String _profitFontFamily = 'Roboto Condensed';
  int _profitFontSize = 14;
  int _profitFontWeight = 700;
  bool _profitIsBold = true;
  
  // 通貨ペアの設定
  String _symbolFontFamily = 'Roboto Condensed';
  int _symbolFontSize = 16;
  int _symbolFontWeight = 700;
  bool _symbolIsBold = true;
  
  // 取引時間の設定
  String _timeFontFamily = 'Roboto Light';
  int _timeFontSize = 12;
  int _timeFontWeight = 400;
  bool _timeIsBold = false;
  
  // カラー設定
  String _positionColor = '#000000';
  String _priceColor = '#95979b';
  String _profitColor = '#1777e7';
  String _symbolColor = '#000000';
  String _timeColor = '#666666';
  
  // ゲッター
  String get positionFontFamily => _positionFontFamily;
  int get positionFontSize => _positionFontSize;
  int get positionFontWeight => _positionFontWeight;
  bool get positionIsBold => _positionIsBold;
  
  String get priceFontFamily => _priceFontFamily;
  int get priceFontSize => _priceFontSize;
  int get priceFontWeight => _priceFontWeight;
  bool get priceIsBold => _priceIsBold;
  
  String get profitFontFamily => _profitFontFamily;
  int get profitFontSize => _profitFontSize;
  int get profitFontWeight => _profitFontWeight;
  bool get profitIsBold => _profitIsBold;
  
  String get symbolFontFamily => _symbolFontFamily;
  int get symbolFontSize => _symbolFontSize;
  int get symbolFontWeight => _symbolFontWeight;
  bool get symbolIsBold => _symbolIsBold;
  
  String get timeFontFamily => _timeFontFamily;
  int get timeFontSize => _timeFontSize;
  int get timeFontWeight => _timeFontWeight;
  bool get timeIsBold => _timeIsBold;
  
  String get positionColor => _positionColor;
  String get priceColor => _priceColor;
  String get profitColor => _profitColor;
  String get symbolColor => _symbolColor;
  String get timeColor => _timeColor;
  
  FontProvider() {
    _loadSettings();
  }
  
  // 設定の読み込み
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 既存データの移行処理（, sans-serifを削除）
      String cleanFontFamily(String? family, String defaultFamily) {
        if (family == null) return defaultFamily;
        return family.replaceAll(', sans-serif', '');
      }
      
      _positionFontFamily = cleanFontFamily(prefs.getString('position_font_family'), 'Roboto Condensed');
      _positionFontSize = prefs.getInt('position_font_size') ?? 14;
      _positionFontWeight = prefs.getInt('position_font_weight') ?? 700;
      _positionIsBold = prefs.getBool('position_is_bold') ?? true;
      
      _priceFontFamily = cleanFontFamily(prefs.getString('price_font_family'), 'Roboto Medium');
      _priceFontSize = prefs.getInt('price_font_size') ?? 16;
      _priceFontWeight = prefs.getInt('price_font_weight') ?? 700;
      _priceIsBold = prefs.getBool('price_is_bold') ?? true;
      
      _profitFontFamily = cleanFontFamily(prefs.getString('profit_font_family'), 'Roboto Condensed');
      _profitFontSize = prefs.getInt('profit_font_size') ?? 14;
      _profitFontWeight = prefs.getInt('profit_font_weight') ?? 700;
      _profitIsBold = prefs.getBool('profit_is_bold') ?? true;
      
      _symbolFontFamily = cleanFontFamily(prefs.getString('symbol_font_family'), 'Roboto Condensed');
      _symbolFontSize = prefs.getInt('symbol_font_size') ?? 16;
      _symbolFontWeight = prefs.getInt('symbol_font_weight') ?? 700;
      _symbolIsBold = prefs.getBool('symbol_is_bold') ?? true;
      
      _timeFontFamily = cleanFontFamily(prefs.getString('time_font_family'), 'Roboto Light');
      _timeFontSize = prefs.getInt('time_font_size') ?? 12;
      _timeFontWeight = prefs.getInt('time_font_weight') ?? 400;
      _timeIsBold = prefs.getBool('time_is_bold') ?? false;
      
      // カラー設定の読み込み
      _positionColor = prefs.getString('position_color') ?? '#000000';
      _priceColor = prefs.getString('price_color') ?? '#95979b';
      _profitColor = prefs.getString('profit_color') ?? '#1777e7';
      _symbolColor = prefs.getString('symbol_color') ?? '#000000';
      _timeColor = prefs.getString('time_color') ?? '#666666';
      
      notifyListeners();
    } catch (e) {
      print('Error loading font settings: $e');
    }
  }
  
  // フォント設定のリセット（テスト用）
  Future<void> resetFontSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 全設定をクリア
    
    // デフォルト値に戻す
    _positionFontFamily = 'Roboto Condensed';
    _priceFontFamily = 'Roboto Medium';
    _profitFontFamily = 'Roboto Condensed';
    _symbolFontFamily = 'Roboto Condensed';
    _timeFontFamily = 'Roboto Light';
    
    notifyListeners();
  }
  
  // ポジション方向の設定更新
  Future<void> updatePositionFont({
    String? fontFamily,
    int? fontSize,
    int? fontWeight,
    bool? isBold,
    String? color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (fontFamily != null) {
      _positionFontFamily = _mapFontFamily(fontFamily);
      await prefs.setString('position_font_family', _positionFontFamily);
      print('DEBUG: Updated position font family to: $_positionFontFamily');
    }
    if (fontSize != null) {
      _positionFontSize = fontSize;
      await prefs.setInt('position_font_size', fontSize);
    }
    if (fontWeight != null) {
      _positionFontWeight = fontWeight;
      await prefs.setInt('position_font_weight', fontWeight);
    }
    if (isBold != null) {
      _positionIsBold = isBold;
      await prefs.setBool('position_is_bold', isBold);
    }
    if (color != null && _isValidHexColor(color)) {
      _positionColor = color;
      await prefs.setString('position_color', color);
    }
    
    notifyListeners();
  }
  
  // 価格データの設定更新
  Future<void> updatePriceFont({
    String? fontFamily,
    int? fontSize,
    int? fontWeight,
    bool? isBold,
    String? color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (fontFamily != null) {
      _priceFontFamily = _mapFontFamily(fontFamily);
      await prefs.setString('price_font_family', _priceFontFamily);
    }
    if (fontSize != null) {
      _priceFontSize = fontSize;
      await prefs.setInt('price_font_size', fontSize);
    }
    if (fontWeight != null) {
      _priceFontWeight = fontWeight;
      await prefs.setInt('price_font_weight', fontWeight);
    }
    if (isBold != null) {
      _priceIsBold = isBold;
      await prefs.setBool('price_is_bold', isBold);
    }
    if (color != null && _isValidHexColor(color)) {
      _priceColor = color;
      await prefs.setString('price_color', color);
    }
    
    notifyListeners();
  }
  
  // 損益の設定更新
  Future<void> updateProfitFont({
    String? fontFamily,
    int? fontSize,
    int? fontWeight,
    bool? isBold,
    String? color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (fontFamily != null) {
      _profitFontFamily = _mapFontFamily(fontFamily);
      await prefs.setString('profit_font_family', _profitFontFamily);
    }
    if (fontSize != null) {
      _profitFontSize = fontSize;
      await prefs.setInt('profit_font_size', fontSize);
    }
    if (fontWeight != null) {
      _profitFontWeight = fontWeight;
      await prefs.setInt('profit_font_weight', fontWeight);
    }
    if (isBold != null) {
      _profitIsBold = isBold;
      await prefs.setBool('profit_is_bold', isBold);
    }
    if (color != null && _isValidHexColor(color)) {
      _profitColor = color;
      await prefs.setString('profit_color', color);
    }
    
    notifyListeners();
  }
  
  // 通貨ペアの設定更新
  Future<void> updateSymbolFont({
    String? fontFamily,
    int? fontSize,
    int? fontWeight,
    bool? isBold,
    String? color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (fontFamily != null) {
      _symbolFontFamily = _mapFontFamily(fontFamily);
      await prefs.setString('symbol_font_family', _symbolFontFamily);
    }
    if (fontSize != null) {
      _symbolFontSize = fontSize;
      await prefs.setInt('symbol_font_size', fontSize);
    }
    if (fontWeight != null) {
      _symbolFontWeight = fontWeight;
      await prefs.setInt('symbol_font_weight', fontWeight);
    }
    if (isBold != null) {
      _symbolIsBold = isBold;
      await prefs.setBool('symbol_is_bold', isBold);
    }
    if (color != null && _isValidHexColor(color)) {
      _symbolColor = color;
      await prefs.setString('symbol_color', color);
    }
    
    notifyListeners();
  }
  
  // 取引時間の設定更新
  Future<void> updateTimeFont({
    String? fontFamily,
    int? fontSize,
    int? fontWeight,
    bool? isBold,
    String? color,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (fontFamily != null) {
      _timeFontFamily = _mapFontFamily(fontFamily);
      await prefs.setString('time_font_family', _timeFontFamily);
    }
    if (fontSize != null) {
      _timeFontSize = fontSize;
      await prefs.setInt('time_font_size', fontSize);
    }
    if (fontWeight != null) {
      _timeFontWeight = fontWeight;
      await prefs.setInt('time_font_weight', fontWeight);
    }
    if (isBold != null) {
      _timeIsBold = isBold;
      await prefs.setBool('time_is_bold', isBold);
    }
    if (color != null && _isValidHexColor(color)) {
      _timeColor = color;
      await prefs.setString('time_color', color);
    }
    
    notifyListeners();
  }
  
  // フォント名をマッピング（Web版対応）
  String _mapFontFamily(String fontFamily) {
    print('DEBUG: _mapFontFamily input: $fontFamily');
    final result = switch (fontFamily) {
      'sans-serif' => 'Roboto Light',
      'sans-serif-medium' => 'Roboto Medium', 
      'sans-serif-condensed' => 'Roboto Condensed',
      'monospace' => 'Roboto Mono',
      _ => 'Roboto Condensed',
    };
    print('DEBUG: _mapFontFamily output: $result');
    return result;
  }
  
  // TextStyleを生成するヘルパーメソッド
  TextStyle getPositionTextStyle({Color? color}) {
    print('FontProvider: Position font - Family: $_positionFontFamily, Size: $_positionFontSize, Weight: $_positionFontWeight, Bold: $_positionIsBold');
    return TextStyle(
      fontFamily: _positionFontFamily,
      fontSize: _positionFontSize.toDouble(),
      fontWeight: _positionIsBold ? FontWeight.values[_getFontWeightIndex(_positionFontWeight)] : FontWeight.normal,
      color: color ?? _hexToColor(_positionColor),
    );
  }
  
  TextStyle getPriceTextStyle({Color? color}) {
    return TextStyle(
      fontFamily: _priceFontFamily,
      fontSize: _priceFontSize.toDouble(),
      fontWeight: _priceIsBold ? FontWeight.values[_getFontWeightIndex(_priceFontWeight)] : FontWeight.normal,
      color: color ?? _hexToColor(_priceColor),
    );
  }
  
  TextStyle getProfitTextStyle({Color? color}) {
    return TextStyle(
      fontFamily: _profitFontFamily,
      fontSize: _profitFontSize.toDouble(),
      fontWeight: _profitIsBold ? FontWeight.values[_getFontWeightIndex(_profitFontWeight)] : FontWeight.normal,
      color: color ?? _hexToColor(_profitColor),
    );
  }
  
  TextStyle getSymbolTextStyle({Color? color}) {
    return TextStyle(
      fontFamily: _symbolFontFamily,
      fontSize: _symbolFontSize.toDouble(),
      fontWeight: _symbolIsBold ? FontWeight.values[_getFontWeightIndex(_symbolFontWeight)] : FontWeight.normal,
      color: color ?? _hexToColor(_symbolColor),
    );
  }
  
  TextStyle getTimeTextStyle({Color? color}) {
    return TextStyle(
      fontFamily: _timeFontFamily,
      fontSize: _timeFontSize.toDouble(),
      fontWeight: _timeIsBold ? FontWeight.values[_getFontWeightIndex(_timeFontWeight)] : FontWeight.normal,
      color: color ?? _hexToColor(_timeColor),
    );
  }
  
  // FontWeightのインデックスを取得
  int _getFontWeightIndex(int weight) {
    switch (weight) {
      case 400:
        return 3; // FontWeight.w400
      case 500:
        return 4; // FontWeight.w500
      case 700:
        return 6; // FontWeight.w700
      case 900:
        return 8; // FontWeight.w900
      default:
        return 6; // FontWeight.w700 (default)
    }
  }
  
  // HEXカラーコードをColorオブジェクトに変換
  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.black; // フォールバック
    }
  }
  
  // HEXカラーコードのバリデーション
  bool _isValidHexColor(String hexString) {
    final hexRegex = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    return hexRegex.hasMatch(hexString);
  }
}