# PurePaste

PurePaste 是一个常驻 macOS 菜单栏的小工具，用来监听系统剪贴板，并在需要时自动移除富文本格式，只保留纯文本内容。

## 功能

- 常驻菜单栏运行
- 自动监听剪贴板变化
- 检测到富文本内容时，自动转换为纯文本
- 支持托盘开关：
  - 默认关闭 `Preserve Formatting`
  - 未勾选时：自动去除格式
  - 勾选后：保留原始复制格式
- `Preserve Formatting` 状态会持久化保存，重启后保持上次选择

## 运行方式

如果已有打包产物，直接打开：

- [PurePaste.dmg](./PurePaste.dmg)

安装后启动应用，会在菜单栏显示 `PP` 图标。

## 菜单项说明

- `PurePaste: Stripping On`
  当前处于自动去格式模式
- `PurePaste: Bypass On`
  当前处于保留格式模式
- `Preserve Formatting`
  勾选后保留原始富文本格式
- `Quit PurePaste`
  退出应用

## 本地编译

当前项目是单文件 Swift 小工具，可直接使用 `swiftc` 编译：

```bash
swiftc ClipboardFormatterStripper.swift -o ClipboardFormatterStripper
```

如果要更新 `.app` 内可执行文件，可替换：

```bash
swiftc ClipboardFormatterStripper.swift -o PurePaste.app/Contents/MacOS/PurePaste
```

## 打包 DMG

当前目录下已经生成了：

- `PurePaste.app`
- `PurePaste.dmg`

如果需要重新打包，可先更新 `.app`，再生成 DMG。

## 系统要求

- macOS 13.0+
- 当前构建产物为 `x86_64`

## License

本项目基于 [MIT License](./LICENSE) 开源。
