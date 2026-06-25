#!/usr/bin/env bash
# 干净的 PyInstaller 打包脚本(瘦身后的 PySide6)
set -e
cd "$(dirname "$0")"

VENV="$PWD/build_venv"
PY="$VENV/bin/python"

# 排除清单:PySide6 用不到的 Qt 模块 + 第三方噪音
EXCLUDES=(
  --exclude-module PyQt5
  --exclude-module PyQt6
  --exclude-module PyQtWebEngine
  --exclude-module PyQt5_sip
  # PySide6 全部非 GUI 子模块 —— 排除能省 ~150-200MB
  --exclude-module PySide6.Qt3DAnimation
  --exclude-module PySide6.Qt3DCore
  --exclude-module PySide6.Qt3DExtras
  --exclude-module PySide6.Qt3DInput
  --exclude-module PySide6.Qt3DLogic
  --exclude-module PySide6.Qt3DRender
  --exclude-module PySide6.QtBluetooth
  --exclude-module PySide6.QtCanvasPainter
  --exclude-module PySide6.QtCharts
  --exclude-module PySide6.QtDataVisualization
  --exclude-module PySide6.QtDBus
  --exclude-module PySide6.QtDesigner
  --exclude-module PySide6.QtGraphs
  --exclude-module PySide6.QtGraphsWidgets
  --exclude-module PySide6.QtHelp
  --exclude-module PySide6.QtHttpServer
  --exclude-module PySide6.QtLocation
  --exclude-module PySide6.QtMultimedia
  --exclude-module PySide6.QtMultimediaWidgets
  --exclude-module PySide6.QtNfc
  --exclude-module PySide6.QtPdf
  --exclude-module PySide6.QtPdfWidgets
  --exclude-module PySide6.QtPositioning
  --exclude-module PySide6.QtQml
  --exclude-module PySide6.QtQuick
  --exclude-module PySide6.QtQuick3D
  --exclude-module PySide6.QtQuickControls2
  --exclude-module PySide6.QtQuickTest
  --exclude-module PySide6.QtQuickWidgets
  --exclude-module PySide6.QtRemoteObjects
  --exclude-module PySide6.QtScxml
  --exclude-module PySide6.QtSensors
  --exclude-module PySide6.QtSerialBus
  --exclude-module PySide6.QtSerialPort
  --exclude-module PySide6.QtSpatialAudio
  --exclude-module PySide6.QtSql
  --exclude-module PySide6.QtSvg
  --exclude-module PySide6.QtSvgWidgets
  --exclude-module PySide6.QtTest
  --exclude-module PySide6.QtTextToSpeech
  --exclude-module PySide6.QtWebChannel
  --exclude-module PySide6.QtWebEngineCore
  --exclude-module PySide6.QtWebEngineQuick
  --exclude-module PySide6.QtWebEngineWidgets
  --exclude-module PySide6.QtWebSockets
  --exclude-module PySide6.QtXml
  # 科学栈(anaconda 残留)
  --exclude-module numpy
  --exclude-module pandas
  --exclude-module scipy
  --exclude-module matplotlib
  --exclude-module torch
  --exclude-module sklearn
  --exclude-module ray
  --exclude-module playwright
  --exclude-module pyarrow
  --exclude-module tokenizers
  --exclude-module hf_xet
  --exclude-module spacy
  --exclude-module cryptography
  --exclude-module lxml
  --exclude-module PIL
)

rm -rf dist build 订单匹配工具.spec 2>/dev/null || true
# 上面 rm 可能被拒,单独再删一次
[ -d dist ] && chmod -R u+w dist && rm -rf dist
[ -d build ] && chmod -R u+w build && rm -rf build

"$PY" -m PyInstaller \
  --noconfirm \
  --windowed \
  --name "订单匹配工具" \
  --osx-bundle-identifier "com.tianyu.ordermatch" \
  "${EXCLUDES[@]}" \
  order_match_gui.py

echo ""
echo "✅ 打包完成"
du -sh dist/订单匹配工具.app/