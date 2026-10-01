@echo off
chcp 65001 >nul
setlocal

REM ============================================
REM  本地一键打包：需要先安装 Java 17 + Android SDK
REM  输出：apk-builder\app\build\outputs\apk\debug\app-debug.apk
REM ============================================

echo ============================================
echo  食物保质期 App - Android APK 本地构建
echo ============================================
echo.

where java >nul 2>nul
if errorlevel 1 (
    echo [错误] 没有检测到 Java。
    echo 请先到 https://adoptium.net 下载安装 Temurin 17 (LTS)，然后重新运行本脚本。
    pause
    exit /b 1
)

if not exist local.properties (
    echo [提示] 未找到 local.properties，需要填写 Android SDK 路径。
    echo.
    set /p SDKDIR=请粘贴你的 Android SDK 路径（例如 C:\Users\你的用户名\AppData\Local\Android\Sdk）:
    echo sdk.dir=!SDKDIR! ^> local.properties
    exit /b 1
)

echo [1/2] 准备 Gradle...
set GRADLE_URL=https\://services.gradle.org/distributions/gradle-8.7-bin.zip
if not exist "%~dp0gradle-8.7" (
    echo 首次运行需要下载 Gradle（约 110MB），请稍候...
    powershell -Command "Invoke-WebRequest -Uri '%GRADLE_URL%' -OutFile '%~dp0gradle.zip'"
    powershell -Command "Expand-Archive -Path '%~dp0gradle.zip' -DestinationPath '%~dp0' -Force"
)

echo [2/2] 编译中，首次构建约 5-10 分钟，请耐心等待...
cd /d "%~dp0apk-builder"
call "%~dp0gradle-8.7\bin\gradle.bat" --no-daemon assembleDebug

if exist app\build\outputs\apk\debug\app-debug.apk (
    echo.
    echo ============================================
    echo  构建成功！安装包位置：
    echo  %CD%\app\build\outputs\apk\debug\app-debug.apk
    echo ============================================
) else (
    echo.
    echo 构建失败，请检查上面的错误信息。
)

pause
