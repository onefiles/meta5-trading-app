# ビルド手順 - Meta5 Flutter版

## 前提条件
1. Flutter SDKのインストール
2. Android Studio または VS Codeのインストール
3. Gitのインストール

## Flutter環境セットアップ

### 1. Flutter SDKのインストール
```bash
# Flutterのダウンロード
# https://flutter.dev/docs/get-started/install/windows

# 環境変数の設定
setx PATH "%PATH%;C:\flutter\bin"

# インストール確認
flutter doctor
```

### 2. プロジェクトの初期化
```bash
cd C:\Users\user\Desktop\Meta5\flutter_meta5
flutter pub get
```

## Androidビルド

### デバッグ版
```bash
# APKビルド
flutter build apk --debug

# 実機にインストール（USB接続必要）
flutter install
```

### リリース版
```bash
# APKビルド
flutter build apk --release

# APKファイルの場所
# build\app\outputs\flutter-apk\app-release.apk
```

## iOSビルド（Mac不要の方法）

### 方法1: Codemagic（推奨）
1. https://codemagic.io にアクセス
2. GitHubにプロジェクトをアップロード
3. Codemagicと連携
4. ビルド設定：
   - Flutter version: stable
   - Xcode version: latest
   - Build for: iOS
5. ビルド実行
6. IPAファイルをダウンロード

### 方法2: GitHub Actions
```yaml
# .github/workflows/ios-build.yml
name: iOS Build

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.x'
    
    - run: flutter pub get
    
    - run: flutter build ios --release --no-codesign
    
    - uses: actions/upload-artifact@v2
      with:
        name: ios-build
        path: build/ios/iphoneos/
```

### 方法3: Flutter Web版（即座にテスト可能）
```bash
# Web版をビルド
flutter build web

# ローカルサーバーで実行
flutter run -d chrome
```

## 実機へのインストール

### Android
1. 開発者オプションを有効化
2. USBデバッグを有効化
3. PCに接続
4. `flutter install`を実行

### iOS（App Store経由なし）
1. **TestFlight不使用の方法**:
   - Apple Developer Programは不要
   - Xcodeの無料アカウントで7日間有効
   
2. **AltStore経由**:
   - https://altstore.io/
   - IPAファイルをサイドロード可能
   
3. **Cydia Impactor代替**:
   - Sideloadly使用
   - IPAファイルを直接インストール

## トラブルシューティング

### Flutter doctorでエラーが出る場合
```bash
# Android toolchainの問題
flutter doctor --android-licenses

# VS Code拡張機能のインストール
code --install-extension Dart-Code.flutter
```

### iOSビルドエラー
- Podfileの問題: `cd ios && pod install`
- 証明書の問題: 自動署名を使用

### パフォーマンス最適化
```bash
# リリースモードで実行
flutter run --release

# プロファイルモードで分析
flutter run --profile
```

## アプリの起動

### 開発モード
```bash
flutter run
```

### 複数デバイスで実行
```bash
flutter run -d all
```

### 特定のデバイスを選択
```bash
# デバイス一覧
flutter devices

# デバイスIDを指定
flutter run -d <device-id>
```

## ビルド成果物

- Android APK: `build\app\outputs\flutter-apk\`
- iOS IPA: Codemagicからダウンロード
- Web: `build\web\`

## 注意事項
- iOSの実機テストにはApple IDが必要（無料）
- App Storeへの公開にはApple Developer Program（年間$99）が必要
- Google Playへの公開にはGoogle Play Console（初回$25）が必要