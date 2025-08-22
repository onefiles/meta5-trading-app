import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';
import '../utils/platform_helper.dart';

class FontSettingsScreen extends StatelessWidget {
  const FontSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f0f0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'フォント設定',
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
      body: Consumer<FontProvider>(
        builder: (context, fontProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ポジション方向設定
                _buildFontSettingCard(
                  title: 'ポジション方向',
                  subtitle: 'sell 0.01, buy 0.50等',
                  currentFontFamily: fontProvider.positionFontFamily,
                  currentFontSize: fontProvider.positionFontSize,
                  currentFontWeight: fontProvider.positionFontWeight,
                  currentIsBold: fontProvider.positionIsBold,
                  currentColor: fontProvider.positionColor,
                  onFontFamilyChanged: (value) => fontProvider.updatePositionFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updatePositionFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updatePositionFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updatePositionFont(isBold: value),
                  onColorChanged: (value) => fontProvider.updatePositionFont(color: value),
                  previewText: 'sell 0.01',
                  fontProvider: fontProvider,
                  fontType: 'position',
                ),
                const SizedBox(height: 16),
                
                // 価格データ設定
                _buildFontSettingCard(
                  title: '価格データ',
                  subtitle: '195.50 → 196.20等',
                  currentFontFamily: fontProvider.priceFontFamily,
                  currentFontSize: fontProvider.priceFontSize,
                  currentFontWeight: fontProvider.priceFontWeight,
                  currentIsBold: fontProvider.priceIsBold,
                  currentColor: fontProvider.priceColor,
                  onFontFamilyChanged: (value) => fontProvider.updatePriceFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updatePriceFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updatePriceFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updatePriceFont(isBold: value),
                  onColorChanged: (value) => fontProvider.updatePriceFont(color: value),
                  previewText: '195.50 → 196.20',
                  fontProvider: fontProvider,
                  fontType: 'price',
                ),
                const SizedBox(height: 16),
                
                // 損益設定
                _buildFontSettingCard(
                  title: '損益表示',
                  subtitle: '利益・損失の表示',
                  currentFontFamily: fontProvider.profitFontFamily,
                  currentFontSize: fontProvider.profitFontSize,
                  currentFontWeight: fontProvider.profitFontWeight,
                  currentIsBold: fontProvider.profitIsBold,
                  currentColor: fontProvider.profitColor,
                  onFontFamilyChanged: (value) => fontProvider.updateProfitFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updateProfitFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updateProfitFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updateProfitFont(isBold: value),
                  onColorChanged: (value) => fontProvider.updateProfitFont(color: value),
                  previewText: '+5,420.00',
                  fontProvider: fontProvider,
                  fontType: 'profit',
                ),
                const SizedBox(height: 16),
                
                // 通貨ペア設定
                _buildFontSettingCard(
                  title: '通貨ペア',
                  subtitle: 'GBPJPY, USDJPY等',
                  currentFontFamily: fontProvider.symbolFontFamily,
                  currentFontSize: fontProvider.symbolFontSize,
                  currentFontWeight: fontProvider.symbolFontWeight,
                  currentIsBold: fontProvider.symbolIsBold,
                  currentColor: fontProvider.symbolColor,
                  onFontFamilyChanged: (value) => fontProvider.updateSymbolFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updateSymbolFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updateSymbolFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updateSymbolFont(isBold: value),
                  onColorChanged: (value) => fontProvider.updateSymbolFont(color: value),
                  previewText: 'GBPJPY',
                  fontProvider: fontProvider,
                  fontType: 'symbol',
                ),
                const SizedBox(height: 16),
                
                // 取引時間設定
                _buildFontSettingCard(
                  title: '取引時間',
                  subtitle: '2025.08.21 14:47:38等',
                  currentFontFamily: fontProvider.timeFontFamily,
                  currentFontSize: fontProvider.timeFontSize,
                  currentFontWeight: fontProvider.timeFontWeight,
                  currentIsBold: fontProvider.timeIsBold,
                  currentColor: fontProvider.timeColor,
                  onFontFamilyChanged: (value) => fontProvider.updateTimeFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updateTimeFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updateTimeFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updateTimeFont(isBold: value),
                  onColorChanged: (value) => fontProvider.updateTimeFont(color: value),
                  previewText: '2025.08.21 14:47:38',
                  fontProvider: fontProvider,
                  fontType: 'time',
                ),
                const SizedBox(height: 16),
                
                // 取引履歴の通貨ペア設定
                _buildFontSettingCard(
                  title: '取引履歴の通貨ペア',
                  subtitle: '履歴画面のGBPJPY, USDJPY等',
                  currentFontFamily: fontProvider.historySymbolFontFamily,
                  currentFontSize: fontProvider.historySymbolFontSize,
                  currentFontWeight: fontProvider.historySymbolFontWeight,
                  currentIsBold: fontProvider.historySymbolIsBold,
                  currentColor: fontProvider.historySymbolColor,
                  onFontFamilyChanged: (value) => fontProvider.updateHistorySymbolFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updateHistorySymbolFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updateHistorySymbolFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updateHistorySymbolFont(isBold: value),
                  onColorChanged: (value) => fontProvider.updateHistorySymbolFont(color: value),
                  previewText: 'GBPJPY',
                  fontProvider: fontProvider,
                  fontType: 'historySymbol',
                ),
                const SizedBox(height: 16),
                
                // Balance/Credit表示設定
                _buildFontSettingCard(
                  title: 'Balance/Credit表示',
                  subtitle: '履歴画面のBalance, Credit',
                  currentFontFamily: fontProvider.balanceCreditFontFamily,
                  currentFontSize: fontProvider.balanceCreditFontSize,
                  currentFontWeight: fontProvider.balanceCreditFontWeight,
                  currentIsBold: fontProvider.balanceCreditIsBold,
                  currentColor: fontProvider.balanceCreditColor,
                  onFontFamilyChanged: (value) => fontProvider.updateBalanceCreditFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updateBalanceCreditFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updateBalanceCreditFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updateBalanceCreditFont(isBold: value),
                  onColorChanged: (value) => fontProvider.updateBalanceCreditFont(color: value),
                  previewText: 'Balance',
                  fontProvider: fontProvider,
                  fontType: 'balanceCredit',
                ),
                const SizedBox(height: 32),
                
                // リセットボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showResetDialog(context, fontProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'フォント設定をリセット',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFontSettingCard({
    required String title,
    required String subtitle,
    required String currentFontFamily,
    required int currentFontSize,
    required int currentFontWeight,
    required bool currentIsBold,
    String? currentColor,
    required Function(String) onFontFamilyChanged,
    required Function(int) onFontSizeChanged,
    required Function(int) onFontWeightChanged,
    required Function(bool) onBoldChanged,
    Function(String)? onColorChanged,
    required String previewText,
    required FontProvider fontProvider,
    required String fontType,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // タイトル
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 16),
            
            // プレビュー
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  previewText,
                  style: _getPreviewTextStyle(fontProvider, fontType, null),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // フォントサイズ選択
            const Text('フォントサイズ:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: FontProvider.fontSizes.map((size) {
                final isSelected = size == currentFontSize;
                return ChoiceChip(
                  label: Text('${size}sp'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) onFontSizeChanged(size);
                  },
                  selectedColor: const Color(0xFF007aff),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // フォント種類選択
            const Text('フォント種類:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FontProvider.fontFamilies.map((family) {
                final isSelected = _getFamilyKey(currentFontFamily) == family;
                return ChoiceChip(
                  label: Text(_getFamilyDisplayName(family)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) onFontFamilyChanged(family);
                  },
                  selectedColor: const Color(0xFF007aff),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Bold設定
            Row(
              children: [
                const Text('太字:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 16),
                Switch(
                  value: currentIsBold,
                  onChanged: onBoldChanged,
                  activeColor: const Color(0xFF007aff),
                ),
              ],
            ),
            
            // Bold数値選択（Boldが有効な場合のみ）
            if (currentIsBold) ...[
              const SizedBox(height: 8),
              const Text('太字の強さ:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: FontProvider.fontWeights.map((weight) {
                  final isSelected = weight == currentFontWeight;
                  return ChoiceChip(
                    label: Text(weight.toString()),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) onFontWeightChanged(weight);
                    },
                    selectedColor: const Color(0xFF007aff),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList(),
              ),
            ],
            
            // カラー設定
            if (onColorChanged != null && currentColor != null) ...[
              const SizedBox(height: 16),
              const Text('フォントカラー:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: currentColor),
                      decoration: InputDecoration(
                        hintText: '例: #FF9900',
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(10),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _hexToColor(currentColor),
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[#a-fA-F0-9]')),
                        LengthLimitingTextInputFormatter(7),
                      ],
                      onChanged: (value) {
                        if (_isValidHexColor(value)) {
                          onColorChanged(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle _getPreviewTextStyle(FontProvider fontProvider, String fontType, Color? color) {
    switch (fontType) {
      case 'position':
        return fontProvider.getPositionTextStyle(color: color);
      case 'price':
        return fontProvider.getPriceTextStyle(color: color);
      case 'profit':
        return fontProvider.getProfitTextStyle(color: color);
      case 'symbol':
        return fontProvider.getSymbolTextStyle(color: color);
      case 'time':
        return fontProvider.getTimeTextStyle(color: color);
      case 'historySymbol':
        return fontProvider.getHistorySymbolTextStyle(color: color);
      case 'balanceCredit':
        return fontProvider.getBalanceCreditTextStyle(color: color);
      default:
        return TextStyle(color: color ?? Colors.black);
    }
  }

  String _getFamilyKey(String fullFontFamily) {
    print('DEBUG: _getFamilyKey input: $fullFontFamily');
    
    // 正確にマッピング（, sans-serifを削除済みの新形式対応）
    if (fullFontFamily == 'Roboto Condensed') return 'sans-serif-condensed';
    if (fullFontFamily == 'Roboto Light') return 'sans-serif';
    if (fullFontFamily == 'Roboto Medium') return 'sans-serif-medium';
    if (fullFontFamily == 'Roboto Mono') return 'monospace';
    
    // フォールバック（旧データとの互換性）
    if (fullFontFamily == 'Roboto Condensed, sans-serif') return 'sans-serif-condensed';
    if (fullFontFamily == 'Roboto Light, sans-serif') return 'sans-serif';
    if (fullFontFamily == 'Roboto Medium, sans-serif') return 'sans-serif-medium';
    if (fullFontFamily.contains('Roboto Condensed')) return 'sans-serif-condensed';
    if (fullFontFamily.contains('Roboto Light')) return 'sans-serif';
    if (fullFontFamily.contains('Roboto Medium')) return 'sans-serif-medium';
    if (fullFontFamily.contains('Roboto Mono')) return 'monospace';
    
    // デフォルト
    return 'sans-serif-condensed';
  }

  String _getFamilyDisplayName(String family) {
    switch (family) {
      case 'sans-serif':
        return 'Light';
      case 'sans-serif-medium':
        return 'Medium';
      case 'sans-serif-condensed':
        return 'Condensed';
      case 'monospace':
        return 'Monospace';
      default:
        return family;
    }
  }

  void _showResetDialog(BuildContext context, FontProvider fontProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('フォント設定リセット'),
        content: const Text('全てのフォント設定を初期値に戻しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              await fontProvider.resetFontSettings();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('フォント設定をリセットしました')),
              );
            },
            child: const Text('リセット', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // HEXカラーコードをColorオブジェクトに変換
  Color _hexToColor(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.black;
    }
  }
  
  // HEXカラーコードのバリデーション
  bool _isValidHexColor(String hexString) {
    final hexRegex = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
    return hexRegex.hasMatch(hexString);
  }
}