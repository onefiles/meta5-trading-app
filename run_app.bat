@echo off
echo Meta5 Flutter アプリを起動します...
echo.

set PATH=%PATH%;C:\flutter\bin
cd /d C:\Users\user\Desktop\Meta5\flutter_meta5

echo [1] Chrome/Edgeで起動（Web版）
echo [2] Androidエミュレータで起動
echo [3] 接続デバイスを確認
echo.

set /p choice="選択してください (1-3): "

if "%choice%"=="1" (
    echo Chromeで起動中...
    flutter run -d chrome
) else if "%choice%"=="2" (
    echo Androidエミュレータで起動中...
    flutter run
) else if "%choice%"=="3" (
    echo 利用可能なデバイス:
    flutter devices
    pause
    goto :eof
) else (
    echo 無効な選択です
    pause
    goto :eof
)

pause