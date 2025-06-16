@echo off
echo Running Flutter Business Dashboard...
echo.

cd /d %~dp0
call flutter clean
call flutter pub get
call flutter run -d chrome

pause 