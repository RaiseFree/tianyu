@echo off
REM ============================================================
REM   订单匹配工具 - Windows 10/11 打包脚本
REM   双击运行,自动建 venv + 装依赖 + PyInstaller 打包
REM   产物:dist\订单匹配工具.exe
REM ============================================================

setlocal enabledelayedexpansion
chcp 65001 > nul

REM 切到脚本所在目录
cd /d "%~dp0"

echo.
echo ============================================================
echo   订单匹配工具 - Windows 打包
echo ============================================================
echo.

REM ---------- 1. 找 Python ----------
where python >nul 2>&1
if errorlevel 1 (
    echo [错误] 没找到 python,请先安装 Python 3.11 或 3.12
    echo 下载地址:https://www.python.org/downloads/windows/
    echo 安装时务必勾选 "Add Python to PATH"
    pause
    exit /b 1
)

for /f "tokens=2" %%v in ('python --version 2^>^&1') do set PY_VER=%%v
echo [1/5] 检测到 Python !PY_VER!

REM 拒绝 3.13+(PyInstaller 6.13 还不稳)
for /f "tokens=1,2 delims=." %%a in ("!PY_VER!") do (
    set MAJOR=%%a
    set MINOR=%%b
)
if !MAJOR! GEQ 4 (
    echo [错误] Python !PY_VER! 不支持,请装 3.11 或 3.12
    pause
    exit /b 1
)

REM ---------- 2. 建/复用 venv ----------
echo.
echo [2/5] 准备 venv...
if not exist build_venv\Scripts\python.exe (
    echo       正在创建 venv(首次约 30 秒)...
    python -m venv build_venv
    if errorlevel 1 (
        echo [错误] venv 创建失败
        pause
        exit /b 1
    )
) else (
    echo       venv 已存在,复用
)

set PY="%~dp0build_venv\Scripts\python.exe"

REM ---------- 3. 装依赖 ----------
echo.
echo [3/5] 安装依赖(首次约 2-3 分钟)...
!PY! -m pip install --upgrade pip --quiet
!PY! -m pip install PySide6 openpyxl pyinstaller --quiet
if errorlevel 1 (
    echo [错误] 依赖安装失败,请检查网络或用国内镜像
    echo 镜像命令:!PY! -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple PySide6 openpyxl pyinstaller
    pause
    exit /b 1
)
echo       依赖就绪

REM ---------- 4. 清理 + 打包 ----------
echo.
echo [4/5] 开始打包(约 1-3 分钟)...

REM 关键排除清单 —— 与 macOS 版保持一致
set EXCLUDES=^
    --exclude-module PySide6.Qt3DAnimation ^
    --exclude-module PySide6.Qt3DCore ^
    --exclude-module PySide6.Qt3DExtras ^
    --exclude-module PySide6.Qt3DInput ^
    --exclude-module PySide6.Qt3DLogic ^
    --exclude-module PySide6.Qt3DRender ^
    --exclude-module PySide6.QtBluetooth ^
    --exclude-module PySide6.QtCanvasPainter ^
    --exclude-module PySide6.QtCharts ^
    --exclude-module PySide6.QtDataVisualization ^
    --exclude-module PySide6.QtDBus ^
    --exclude-module PySide6.QtDesigner ^
    --exclude-module PySide6.QtGraphs ^
    --exclude-module PySide6.QtGraphsWidgets ^
    --exclude-module PySide6.QtHelp ^
    --exclude-module PySide6.QtHttpServer ^
    --exclude-module PySide6.QtLocation ^
    --exclude-module PySide6.QtMultimedia ^
    --exclude-module PySide6.QtMultimediaWidgets ^
    --exclude-module PySide6.QtNfc ^
    --exclude-module PySide6.QtPdf ^
    --exclude-module PySide6.QtPdfWidgets ^
    --exclude-module PySide6.QtPositioning ^
    --exclude-module PySide6.QtQml ^
    --exclude-module PySide6.QtQuick ^
    --exclude-module PySide6.QtQuick3D ^
    --exclude-module PySide6.QtQuickControls2 ^
    --exclude-module PySide6.QtQuickTest ^
    --exclude-module PySide6.QtQuickWidgets ^
    --exclude-module PySide6.QtRemoteObjects ^
    --exclude-module PySide6.QtScxml ^
    --exclude-module PySide6.QtSensors ^
    --exclude-module PySide6.QtSerialBus ^
    --exclude-module PySide6.QtSerialPort ^
    --exclude-module PySide6.QtSpatialAudio ^
    --exclude-module PySide6.QtSql ^
    --exclude-module PySide6.QtSvg ^
    --exclude-module PySide6.QtSvgWidgets ^
    --exclude-module PySide6.QtTest ^
    --exclude-module PySide6.QtTextToSpeech ^
    --exclude-module PySide6.QtWebChannel ^
    --exclude-module PySide6.QtWebEngineCore ^
    --exclude-module PySide6.QtWebEngineQuick ^
    --exclude-module PySide6.QtWebEngineWidgets ^
    --exclude-module PySide6.QtWebSockets ^
    --exclude-module PySide6.QtXml ^
    --exclude-module numpy ^
    --exclude-module pandas ^
    --exclude-module scipy ^
    --exclude-module matplotlib ^
    --exclude-module torch ^
    --exclude-module sklearn

REM 清旧产物
if exist dist rmdir /s /q dist
if exist build rmdir /s /q build
if exist 订单匹配工具.spec del 订单匹配工具.spec

!PY! -m PyInstaller ^
    --noconfirm ^
    --onefile ^
    --windowed ^
    --name "订单匹配工具" ^
    --collect-submodules PySide6 ^
    --collect-submodules openpyxl ^
    --hidden-import openpyxl ^
    %EXCLUDES% ^
    order_match_gui.py

if errorlevel 1 (
    echo.
    echo [错误] 打包失败,见上方日志
    pause
    exit /b 1
)

REM ---------- 5. 报告 ----------
echo.
echo [5/5] 打包完成
echo.
echo ============================================================
echo   产物:dist\订单匹配工具.exe
echo ============================================================
echo.

if exist dist\订单匹配工具.exe (
    for %%f in (dist\订单匹配工具.exe) do echo   文件大小:%%~zf 字节(~ %%~zf / 1048576 MB)
)

echo.
echo 直接双击 dist\订单匹配工具.exe 即可运行
echo.
pause
endlocal