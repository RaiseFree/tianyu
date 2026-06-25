# 订单匹配工具 - Windows 10/11 打包说明书

## 一键打包(给没耐心的陛下)

1. 把 `build_windows.bat` 和 `order_match_gui.py` 放到任意**没有中文路径**的目录(比如 `D:\tools\`)
2. 双击 `build_windows.bat`
3. 等待 3-5 分钟
4. 产物在 `dist\订单匹配工具.exe`,双击运行

---

## 详细步骤

### 0. 前置条件(只做一次)

#### (1) 装 Python 3.11 或 3.12

- 官网下载:https://www.python.org/downloads/windows/
- ⚠️ **安装时务必勾选 "Add Python to PATH"**(底部第一个 checkbox)
- 不要装 3.13+(PyInstaller 6.x 还没完全兼容,可能出怪问题)

安装完按 `Win+R` 输入 `cmd`,敲 `python --version` 能看到版本号说明 OK。

#### (2) 把代码放到无中文路径

⚠️ **重要**:整条路径不能有中文,否则 PyInstaller 会报编码错误。

- ✅ 好的路径:`D:\tools\`、`C:\dev\build\`
- ❌ 坏的路径:`D:\工具\`、`C:\用户\桌面\订单匹配\`

需要放进该目录的文件(就两个):
```
build_windows.bat
order_match_gui.py
```

### 1. 双击运行打包脚本

双击 `build_windows.bat`,会自动:

1. 检测 Python 版本
2. 创建 `build_venv\` 虚拟环境(首次约 30 秒)
3. 安装 PySide6 + openpyxl + pyinstaller(首次约 2-3 分钟,后续跳过)
4. 清理旧产物
5. 跑 PyInstaller(约 1-2 分钟)
6. 在最后打印产物路径和大小

### 2. 拿产物

打包成功后:
```
你的目录\
├── dist\
│   └── 订单匹配工具.exe    ← 双击这个!
├── build\
├── build_venv\
├── build_windows.bat
└── order_match_gui.py
```

**双击 `dist\订单匹配工具.exe` 即可运行**。

`build\` 和 `build_venv\` 可以删掉,只是构建过程的中间产物。

---

## 常见问题

### Q1: 双击 .exe 弹"Windows 已保护你的电脑"

**原因**:PyInstaller 出的 .exe 没数字签名,Win10/11 默认拦截未签名 exe。
**解决**:
1. 点"更多信息"
2. 点"仍要运行"
3. 一次性,以后双击就正常了

**永久解决**:花 ¥2000+ 买代码签名证书(不在臣的服务范围内)。

### Q2: 启动后弹个黑窗口一闪而过,啥都没出

**原因**:Python 报错但 `--windowed` 把 stderr 吞了。
**排查**:
1. 用命令行跑:`cd dist && 订单匹配工具.exe`
2. 看完整报错,通常是缺 dll 或环境变量问题

### Q3: 启动报 "Could not load Qt platform plugin"

**原因**:PyInstaller 没把 Qt 插件收全。
**解决**:确认 `build_windows.bat` 里 `--collect-submodules PySide6` 这一行没被删。

### Q4: 打包失败,日志里有 "ERROR: Microsoft Visual C++ 14.0 or greater is required"

**原因**:某些包需要 C 编译器(比如 lxml 的 fast 模式)。
**解决**:本工具不需要 lxml,正常不应该出这个错。如果出了,说明环境里装了多余的包,请用臣给的**干净 venv**(脚本会自动建)。

### Q5: 打包到一半卡死/超时

**正常**:PyInstaller 首次扫描依赖可能要 1-3 分钟,不是卡死,等就行。
**真卡死**:5 分钟没动静,Ctrl+C 杀掉,把 build_venv 删了重来。

### Q6: 打包成功但运行报"找不到 order_match_gui 模块"

**原因**:`order_match_gui.py` 不在 bat 脚本同目录。
**解决**:两个文件必须同级。

### Q7: 网络慢,装依赖超时

**解决**:用国内镜像。在 bat 脚本的"安装依赖"那一段,手动把 pip 命令换成:
```cmd
!PY! -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple PySide6 openpyxl pyinstaller --quiet
```
清华源、阿里源、豆瓣源都行。

---

## 进阶:重打包

代码改了想重新打,直接双击 `build_windows.bat`。脚本会复用 `build_venv\`,跳过重装依赖,只重跑 PyInstaller,大概 1 分钟。

## 进阶:分发给他人

直接拷贝 `dist\订单匹配工具.exe` 一个文件即可,Win10/11 上双击就能跑,不依赖系统装 Python。

⚠️ 但首次打开会弹"Windows 已保护你的电脑"警告(因为没数字签名),对方需要点"仍要运行"。

---

## 文件清单

| 文件 | 用途 |
|------|------|
| `order_match_gui.py` | GUI 主程序(读源文件 → 匹配 → 写结果) |
| `build_windows.bat` | 一键打包脚本 |
| `build_macos.sh` | Mac 端打包脚本(Mac 用户的副本) |

预计产物大小:80-120MB(PySide6 Qt 库 + Python 运行时 + 业务代码)。

---

## 臣碎碎念

- Win 上不建议装 anaconda,会污染 venv;直接用 python.org 的官方包最稳
- `--onefile` 出来的 exe 启动时会有 2-5 秒"解压延迟"(PyInstaller 自解压到临时目录),这是正常的
- 想看 Win 端调试日志,临时把 `build_windows.bat` 里的 `--windowed` 改成 `--console`,exe 启动会带个黑窗口,异常会打印出来