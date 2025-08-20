# Meta5 Trading App - プロジェクト情報

## 基本情報
- **プロジェクトパス**: C:\Users\user\Desktop\Meta5\flutter_meta5
- **GitHub**: https://github.com/onefiles/meta5-trading-app
- **デプロイURL**: https://delicate-vacherin-cd3cde.netlify.app
- **Netlify Site ID**: delicate-vacherin-cd3cde

## 自動デプロイ
- **CI/CD**: GitHub Actions (.github/workflows/deploy.yml)
- **Flutter Version**: 3.16.0 (固定)
- **デプロイコマンド**: `git add . && git commit -m "Update" && git push`
- **ステータス**: 正常動作確認済み（2025/08/19）

## 技術スタック
- **Framework**: Flutter (Web/iOS/Android対応)
- **状態管理**: Provider
- **プラットフォーム判定**: Web環境では常にAndroid版UI使用

## 開発コマンド
```bash
# 開発サーバー起動
flutter run -d chrome

# デプロイ（自動）
git add . && git commit -m "Update" && git push
```

## 再開時の手順
1. VSCodeで C:\Users\user\Desktop\Meta5\flutter_meta5 を開く
2. 新しいClaude Codeチャットを開始
3. 「CLAUDE.mdの内容を確認して開発を続ける」と伝える