import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider extends ChangeNotifier {
  // フォント種類の定義
  static const List<String> fontFamilies = [
    'sans-serif',
    'sans-serif-medium', 
    'sans-serif-condensed',
    'Roboto Condensed',
  ];
  
  static const List<int> fontSizes = [12, 14, 16, 18, 20];
  static const List<int> fontWeights = [400, 500, 700, 900];
  
  // ポジション方向の設定
  String _positionFontFamily = 'Roboto Condensed';
  int _positionFontSize = 14;
  int _positionFontWeight = 700;
  bool _positionIsBold = true;
  
  // 価格データの設定
  String _priceFontFamily = 'Roboto Condensed';
  int _priceFontSize = 16;
  int _priceFontWeight = 700;
  bool _priceIsBold = true;
  
  // 損益の設定
  String _profitFontFamily = 'Roboto Condensed';
  int _profitFontSize = 14;
  int _profitFontWeight = 700;
  bool _profitIsBold = true;
  
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
  
  FontProvider() {
    _loadSettings();
  }
  
  // 設定の読み込み
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 既存データの移行処理（, sans-serifを削除）
      String cleanFontFamily(String? family) {
        if (family == null) return 'Roboto Condensed';
        return family.replaceAll(', sans-serif', '');
      }
      
      _positionFontFamily = cleanFontFamily(prefs.getString('position_font_family'));
      _positionFontSize = prefs.getInt('position_font_size') ?? 14;
      _positionFontWeight = prefs.getInt('position_font_weight') ?? 700;
      _positionIsBold = prefs.getBool('position_is_bold') ?? true;
      
      _priceFontFamily = cleanFontFamily(prefs.getString('price_font_family'));
      _priceFontSize = prefs.getInt('price_font_size') ?? 16;
      _priceFontWeight = prefs.getInt('price_font_weight') ?? 700;
      _priceIsBold = prefs.getBool('price_is_bold') ?? true;
      
      _profitFontFamily = cleanFontFamily(prefs.getString('profit_font_family'));
      _profitFontSize = prefs.getInt('profit_font_size') ?? 14;
      _profitFontWeight = prefs.getInt('profit_font_weight') ?? 700;
      _profitIsBold = prefs.getBool('profit_is_bold') ?? true;
      
      notifyListeners();
    } catch (e) {
      print('Error loading font settings: $e');
    }
  }
  
  // ポジション方向の設定更新
  Future<void> updatePositionFont({
    String? fontFamily,
    int? fontSize,
    int? fontWeight,
    bool? isBold,
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
    
    notifyListeners();
  }
  
  // 価格データの設定更新
  Future<void> updatePriceFont({
    String? fontFamily,
    int? fontSize,
    int? fontWeight,
    bool? isBold,
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
    
    notifyListeners();
  }
  
  // 損益の設定更新
  Future<void> updateProfitFont({
    String? fontFamily,
    int? fontSize,
    int? fontWeight,
    bool? isBold,
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
    
    notifyListeners();
  }
  
  // フォント設定のリセット
  Future<void> resetFontSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // デフォルト値に戻す
    _positionFontFamily = 'Roboto Condensed';
    _positionFontSize = 14;
    _positionFontWeight = 700;
    _positionIsBold = true;
    
    _priceFontFamily = 'Roboto Condensed';
    _priceFontSize = 16;
    _priceFontWeight = 700;
    _priceIsBold = true;
    
    _profitFontFamily = 'Roboto Condensed';
    _profitFontSize = 14;
    _profitFontWeight = 700;
    _profitIsBold = true;
    
    // SharedPreferencesからフォント設定を削除
    await prefs.remove('position_font_family');
    await prefs.remove('position_font_size');
    await prefs.remove('position_font_weight');
    await prefs.remove('position_is_bold');
    
    await prefs.remove('price_font_family');
    await prefs.remove('price_font_size');
    await prefs.remove('price_font_weight');
    await prefs.remove('price_is_bold');
    
    await prefs.remove('profit_font_family');
    await prefs.remove('profit_font_size');
    await prefs.remove('profit_font_weight');
    await prefs.remove('profit_is_bold');
    
    notifyListeners();
  }
  
  // フォント名をマッピング（Web版対応）
  String _mapFontFamily(String fontFamily) {
    print('DEBUG: _mapFontFamily input: $fontFamily');
    final result = switch (fontFamily) {
      'sans-serif' => 'Roboto Light',
      'sans-serif-medium' => 'Roboto Medium', 
      'sans-serif-condensed' => 'Roboto Condensed',
      'Roboto Condensed' => 'Roboto Condensed',
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
      color: color ?? Colors.black,
    );
  }
  
  TextStyle getPriceTextStyle({Color? color}) {
    return TextStyle(
      fontFamily: _priceFontFamily,
      fontSize: _priceFontSize.toDouble(),
      fontWeight: _priceIsBold ? FontWeight.values[_getFontWeightIndex(_priceFontWeight)] : FontWeight.normal,
      color: color ?? Colors.black,
    );
  }
  
  TextStyle getProfitTextStyle({Color? color}) {
    return TextStyle(
      fontFamily: _profitFontFamily,
      fontSize: _profitFontSize.toDouble(),
      fontWeight: _profitIsBold ? FontWeight.values[_getFontWeightIndex(_profitFontWeight)] : FontWeight.normal,
      color: color ?? Colors.black,
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
}