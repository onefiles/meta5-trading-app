import 'package:flutter/material.dart';
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
                  onFontFamilyChanged: (value) => fontProvider.updatePositionFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updatePositionFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updatePositionFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updatePositionFont(isBold: value),
                  previewText: 'sell 0.01',
                  previewColor: const Color(0xFFc74932),
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
                  onFontFamilyChanged: (value) => fontProvider.updatePriceFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updatePriceFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updatePriceFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updatePriceFont(isBold: value),
                  previewText: '195.50 → 196.20',
                  previewColor: const Color(0xFF95979b),
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
                  onFontFamilyChanged: (value) => fontProvider.updateProfitFont(fontFamily: value),
                  onFontSizeChanged: (value) => fontProvider.updateProfitFont(fontSize: value),
                  onFontWeightChanged: (value) => fontProvider.updateProfitFont(fontWeight: value),
                  onBoldChanged: (value) => fontProvider.updateProfitFont(isBold: value),
                  previewText: '+5,420.00',
                  previewColor: const Color(0xFF1777e7),
                  fontProvider: fontProvider,
                  fontType: 'profit',
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
    required Function(String) onFontFamilyChanged,
    required Function(int) onFontSizeChanged,
    required Function(int) onFontWeightChanged,
    required Function(bool) onBoldChanged,
    required String previewText,
    required Color previewColor,
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
                  style: _getPreviewTextStyle(fontProvider, fontType, previewColor),
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
          ],
        ),
      ),
    );
  }

  TextStyle _getPreviewTextStyle(FontProvider fontProvider, String fontType, Color color) {
    switch (fontType) {
      case 'position':
        return fontProvider.getPositionTextStyle(color: color);
      case 'price':
        return fontProvider.getPriceTextStyle(color: color);
      case 'profit':
        return fontProvider.getProfitTextStyle(color: color);
      default:
        return TextStyle(color: color);
    }
  }

  String _getFamilyKey(String fullFontFamily) {
    print('DEBUG: _getFamilyKey input: $fullFontFamily');
    
    // 正確にマッピング
    if (fullFontFamily == 'Roboto Condensed, sans-serif') return 'Roboto Condensed';
    if (fullFontFamily == 'Roboto Light, sans-serif') return 'sans-serif';
    if (fullFontFamily == 'Roboto Medium, sans-serif') return 'sans-serif-medium';
    
    // フォールバック（既存データとの互換性）
    if (fullFontFamily.contains('Roboto Condensed')) return 'Roboto Condensed';
    if (fullFontFamily.contains('Roboto Light')) return 'sans-serif';
    if (fullFontFamily.contains('Roboto Medium')) return 'sans-serif-medium';
    if (fullFontFamily.contains('Roboto') && !fullFontFamily.contains('Condensed') && !fullFontFamily.contains('Light') && !fullFontFamily.contains('Medium')) return 'sans-serif';
    
    // デフォルト
    return 'sans-serif-condensed';
  }

  String _getFamilyDisplayName(String family) {
    switch (family) {
      case 'sans-serif':
        return 'Sans-serif';
      case 'sans-serif-medium':
        return 'Medium';
      case 'sans-serif-condensed':
        return 'Condensed';
      case 'Roboto Condensed':
        return 'Roboto Condensed';
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
}