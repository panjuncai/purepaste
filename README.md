# PurePaste

PurePaste 是一个常驻系统托盘 / 菜单栏的小工具，用来监听系统剪贴板，并在需要时自动移除富文本格式，只保留纯文本内容。

当前仓库同时维护：

- macOS 版本
- Windows 版本

两端核心功能保持一致。

## 功能

- 常驻系统菜单栏 / 系统托盘运行
- 自动监听剪贴板变化
- 检测到富文本内容时，自动转换为纯文本
- 支持开关：
  - 默认关闭 `Preserve Formatting`
  - 未勾选时：自动去除格式
  - 勾选后：保留原始复制格式
- `Preserve Formatting` 状态会持久化保存，重启后保持上次选择

## 平台实现

### macOS

- 技术栈：Swift + AppKit
- 当前实现文件：[`macos/PurePasteMac.swift`](./macos/PurePasteMac.swift)
- 打包产物：`PurePaste.dmg`

### Windows

- 技术栈：C# + WinForms
- 当前工程目录：[`windows/PurePaste.Windows`](./windows/PurePaste.Windows)
- 打包产物：`PurePaste-windows-x64.zip`

## 项目结构

```text
.
├── macos
│   ├── PurePasteMac.swift
│   └── package_macos.sh
├── windows
│   └── PurePaste.Windows
│       ├── Program.cs
│       └── PurePaste.Windows.csproj
├── .github
│   └── workflows
│       └── build.yml
├── LICENSE
└── README.md
```

## 菜单项说明

- `PurePaste: Stripping On`
  当前处于自动去格式模式
- `PurePaste: Bypass On`
  当前处于保留格式模式
- `Preserve Formatting`
  勾选后保留原始富文本格式
- `Quit PurePaste`
  退出应用

## 本地开发

### macOS

直接编译：

```bash
swiftc macos/PurePasteMac.swift -o ClipboardFormatterStripper
```

生成 `.app` 和 `.dmg`：

```bash
bash macos/package_macos.sh
```

### Windows

Windows 版本建议通过 GitHub Actions 构建，或者在 Windows 机器上使用 .NET 8：

```powershell
dotnet publish windows/PurePaste.Windows/PurePaste.Windows.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

## 自动构建与发布

仓库内置 GitHub Actions 双平台构建流程：

- macOS：自动生成 `PurePaste.dmg`
- Windows：自动生成 `PurePaste-windows-x64.zip`
- 推送 `v*` tag 后自动创建 GitHub Release

工作流配置见 [`.github/workflows/build.yml`](./.github/workflows/build.yml)。

### 发布步骤

```bash
git add .
git commit -m "release: v1.0.0"
git push origin main
git tag v1.0.0
git push origin v1.0.0
```

推送 tag 后，GitHub Actions 会自动构建并上传双平台产物。

## 系统要求

### macOS

- macOS 13.0+
- 当前默认本地产物为 `x86_64`

### Windows

- Windows 10 / 11
- 当前发布目标为 `win-x64`

## License

本项目基于 [MIT License](./LICENSE) 开源。
