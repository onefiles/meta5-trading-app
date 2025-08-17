@echo off
echo アセットファイルを設定中...

:: Web対応を追加
C:\flutter\bin\flutter create . --platforms=web,android,ios

:: フォントファイルをコピー
copy C:\Users\user\Desktop\Meta5\font\*.ttf assets\fonts\

:: アイコンファイルをコピー（存在する場合）
if exist "C:\Users\user\Desktop\Meta5\*.png" (
    copy C:\Users\user\Desktop\Meta5\*.png assets\icons\
)

:: 下のバーアイコンをコピー
if exist "C:\Users\user\Desktop\Meta5\下のバー\*.png" (
    copy "C:\Users\user\Desktop\Meta5\下のバー\*.png" assets\icons\
)

:: 取引画面アイコンをコピー
if exist "C:\Users\user\Desktop\Meta5\取引画面\*.png" (
    copy "C:\Users\user\Desktop\Meta5\取引画面\*.png" assets\icons\
)

echo.
echo セットアップ完了！
echo 次のコマンドでアプリを起動できます：
echo C:\flutter\bin\flutter run -d chrome
pause