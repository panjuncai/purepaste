# PurePaste

PurePaste 是一个双平台剪贴板纯文本工具，监听系统剪贴板变化，在需要时自动去掉富文本格式，仅保留纯文本内容。

当前仓库按平台拆分：

- `macos/`：Swift + AppKit 菜单栏版本
- `windows/`：C# + WinForms 托盘版本

两端都支持：

- 默认自动去格式
- `Preserve Formatting` 开关
- 开关状态持久化

## 目录结构

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
├── README.md
└── RELEASE_NOTES_v1.0.0.md
```

## 本地构建

### macOS

```bash
bash macos/package_macos.sh
```

### Windows

```powershell
dotnet publish windows/PurePaste.Windows/PurePaste.Windows.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true
```

## 自动发布

推送 `v*` tag 后，GitHub Actions 会自动生成：

- `PurePaste.dmg`
- `PurePaste-windows-x64.zip`

工作流见 [`.github/workflows/build.yml`](./.github/workflows/build.yml)。

## v1.0.0 Release Notes

首个正式版本，提供 macOS 与 Windows 双平台剪贴板纯文本处理能力。

### Highlights

- 新增 macOS 菜单栏版本
- 新增 Windows 托盘版本
- 默认自动去除复制内容中的富文本格式，仅保留纯文本
- 新增 `Preserve Formatting` 开关
- `Preserve Formatting` 状态支持持久化，重启后保持上次选择
- 支持 GitHub Actions 自动构建与发布双平台产物

### Artifacts

- macOS: `PurePaste.dmg`
- Windows: `PurePaste-windows-x64.zip`

### Notes

- macOS 当前发布目标为 13.0+
- Windows 当前发布目标为 `win-x64`

## License

本项目基于 [MIT License](./LICENSE) 开源。
