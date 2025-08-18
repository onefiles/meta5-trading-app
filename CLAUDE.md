# Meta5 Trading App - プロジェクト情報

## 基本情報
- **プロジェクトパス**: C:\Users\user\Desktop\Meta5\flutter_meta5
- **GitHub**: https://github.com/onefiles/meta5-trading-app
- **デプロイURL**: https://delicate-vacherin-cd3cde.netlify.app
- **Netlify Site ID**: delicate-vacherin-cd3cde

## 技術スタック
- **Framework**: Flutter (Web/iOS/Android対応)
- **状態管理**: Provider
- **API**: https://jpn225.jp/meta5/api (実際のMT4価格データ)
- **デプロイ**: Netlify (PWA対応)
- **CI/CD**: GitHub Actions

## 主要機能
- リアルタイム価格表示（GBPJPY, BTCJPY, XAUUSD等）
- 注文機能（Buy/Sell）
- チャート表示
- 取引履歴
- 価格アラート
- iOS/Android UI自動切り替え
- その他主要機能追加してる可能性ある為全てのファイルを読み込む

## 開発コマンド
```bash
# 開発サーバー起動
flutter run -d chrome

# Webビルド
flutter build web

# デプロイ（自動）
git add . && git commit -m "Update" && git push
```

## 再開時の手順
1. VSCodeで C:\Users\user\Desktop\Meta5\flutter_meta5 を開く
2. 新しいClaude Codeチャットを開始
3. 「CLAUDE.mdの内容を確認して開発を続ける」と伝える

## 最近の更新
- 2024/12/18: Netlify新サイトでデプロイ成功
- 2024/12/18: GitHub Actions自動デプロイ復活
- 2024/12/18: iPhoneでPWAインストール確認

