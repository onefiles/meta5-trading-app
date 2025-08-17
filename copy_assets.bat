@echo off
echo Androidアプリのアセットをコピー中...

:: アイコンディレクトリを作成
mkdir assets\icons 2>nul

:: メインアイコンをコピー
copy "C:\Users\user\Desktop\Meta5\ic_*.png" assets\icons\ 2>nul

:: 下のバーのアイコンをコピー
copy "C:\Users\user\Desktop\Meta5\下のバー\*.png" assets\icons\ 2>nul

:: 取引画面のアイコンをコピー
copy "C:\Users\user\Desktop\Meta5\取引画面\*.png" assets\icons\ 2>nul

:: 取引履歴のアイコンをコピー
copy "C:\Users\user\Desktop\Meta5\取引履歴\*.png" assets\icons\ 2>nul

:: フォントをコピー
mkdir assets\fonts 2>nul
copy "C:\Users\user\Desktop\Meta5\font\*.ttf" assets\fonts\ 2>nul
copy "C:\Users\user\Desktop\Meta5\roboto-condensed\*.ttf" assets\fonts\ 2>nul

echo.
echo アセットのコピー完了！
pause