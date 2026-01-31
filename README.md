# ghostty-layout

Ghosttyターミナルの画面分割をコマンドラインから実行するCLIツール。

## インストール

### ソースからビルド

```bash
git clone https://github.com/tackeyy/ghostty-layout.git
cd ghostty-layout
swift build -c release
sudo cp .build/release/ghostty-layout /usr/local/bin/
```

### リリースバイナリ

```bash
curl -sL https://github.com/tackeyy/ghostty-layout/releases/latest/download/ghostty-layout -o /usr/local/bin/ghostty-layout && chmod +x /usr/local/bin/ghostty-layout
```

## 使い方

```bash
ghostty-layout <layout>
```

### レイアウト

| コマンド | 説明 |
|---------|------|
| `ghostty-layout h` | 水平2分割（左右） |
| `ghostty-layout v` | 垂直2分割（上下） |
| `ghostty-layout 4` | 4分割 (2x2) |
| `ghostty-layout 6` | 6分割 (3x2) |
| `ghostty-layout 8` | 8分割 (4x2) |

### オプション

```bash
ghostty-layout --help     # ヘルプ表示
ghostty-layout --version  # バージョン表示
ghostty-layout --list     # レイアウト一覧
```

## 前提条件

### 1. Accessibility権限

初回実行時にシステム設定で許可が必要です。

**システム設定 > プライバシーとセキュリティ > アクセシビリティ** でターミナル（またはghostty-layout）を許可してください。

### 2. Ghosttyのキーバインド設定

ペイン移動のため、以下の設定を `~/.config/ghostty/config` に追加してください：

```
keybind = alt+h=goto_split:left
keybind = alt+l=goto_split:right
keybind = alt+j=goto_split:bottom
keybind = alt+k=goto_split:top
```

## Raycast連携

Raycastのスクリプトコマンドとして登録できます：

```bash
#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Ghostty 4分割
# @raycast.mode silent

/usr/local/bin/ghostty-layout 4
```

## ライセンス

MIT
