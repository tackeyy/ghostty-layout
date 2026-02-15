# ghostty-layout

> Ghosttyターミナルの画面分割をコマンドラインから実行するCLIツール

[![Lint & Test](https://github.com/tackeyy/ghostty-layout/actions/workflows/lint.yml/badge.svg)](https://github.com/tackeyy/ghostty-layout/actions/workflows/lint.yml)
[![codecov](https://codecov.io/gh/tackeyy/ghostty-layout/branch/main/graph/badge.svg)](https://codecov.io/gh/tackeyy/ghostty-layout)

[Ghostty](https://ghostty.org)ターミナルのウィンドウ分割レイアウトをキーボードショートカットの自動化により作成するコマンドラインユーティリティです。プリセットレイアウトとカスタムグリッド設定をサポートしています。

## 特徴

- **プリセットレイアウト**: よく使う分割のショートカット（2, 4, 6, 8, 9ペイン）
- **グリッド記法**: CxR形式で任意のグリッドを作成（例: `3x2` = 3列 x 2行）
- **自動検出**: Ghosttyの設定からキーバインドを読み取り（プレフィックスキー対応）
- **均等分割**: レイアウト作成後に自動でペインサイズを均等化

## 動作環境

- macOS 13 (Ventura) 以降
- Swift 5.9+（ソースからビルドする場合）

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
| `ghostty-layout h` | 水平2分割（2x1） |
| `ghostty-layout v` | 垂直2分割（1x2） |
| `ghostty-layout 4` | 4分割（2x2） |
| `ghostty-layout 6` | 6分割（2x3） |
| `ghostty-layout 8` | 8分割（4x2） |
| `ghostty-layout 9` | 9分割（3x3） |

### グリッド記法（CxR）

`CxR`形式でカスタムグリッドを作成できます（C=列数、R=行数）:

```bash
ghostty-layout 2x3   # 2列 x 3行 = 6ペイン
ghostty-layout 3x2   # 3列 x 2行 = 6ペイン
ghostty-layout 4x2   # 4列 x 2行 = 8ペイン
```

1x1から8x8までのグリッドをサポートしています。

### オプション

```bash
ghostty-layout --help         # ヘルプを表示
ghostty-layout --version      # バージョンを表示
ghostty-layout --list         # 利用可能なレイアウト一覧を表示
ghostty-layout --show-config  # 現在の設定を表示
ghostty-layout --init-config  # 設定ファイルをGhosttyの設定から再生成
ghostty-layout --sync-config  # Ghosttyの設定と設定ファイルを同期
```

## 設定

ghostty-layoutは初回実行時にGhosttyのキーバインドを自動的に読み取り、設定ファイルを生成します。

### 設定ファイルの場所

```
~/.config/ghostty-layout/config.json
```

### 自動検出

ツールはGhosttyの設定ファイル（`~/.config/ghostty/config`）を解析し、以下のキーバインドを抽出します:

- `new_split:right` - 水平分割（右に新しいペインを作成）
- `new_split:down` - 垂直分割（下に新しいペインを作成）
- `goto_split:left/right/up/down` - ペイン間の移動
- `equalize_splits` - 全ペインのサイズを均等化
- プレフィックスキーのサポート（例: `ctrl+t > h`）

### 設定の同期

Ghosttyのキーバインドを変更した場合は、設定を同期してください:

```bash
ghostty-layout --sync-config
```

同期とレイアウト適用を同時に行うこともできます:

```bash
ghostty-layout --sync-config 3x2
```

### 手動設定

設定ファイルはJSON形式です:

```json
{
  "prefix": {
    "key": "t",
    "modifiers": ["control"]
  },
  "splitRight": {
    "key": "backslash",
    "modifiers": ["shift"]
  },
  "splitDown": {
    "key": "-",
    "modifiers": []
  },
  "gotoLeft": {
    "key": "h",
    "modifiers": []
  },
  "gotoRight": {
    "key": "l",
    "modifiers": []
  },
  "gotoUp": {
    "key": "k",
    "modifiers": []
  },
  "gotoDown": {
    "key": "j",
    "modifiers": []
  },
  "equalizeSplits": {
    "key": "=",
    "modifiers": []
  }
}
```

## 前提条件

### 1. Accessibility権限

初回実行時にAccessibility権限を許可する必要があります。

**システム設定 > プライバシーとセキュリティ > アクセシビリティ** でターミナル（またはghostty-layout）を許可してください。

### 2. Ghosttyのキーバインド設定

Ghosttyの設定ファイル（`~/.config/ghostty/config`）に以下のアクションがバインドされていることを確認してください:

```
# 分割コマンド
keybind = cmd+d=new_split:right
keybind = cmd+shift+d=new_split:down

# ナビゲーション
keybind = cmd+ctrl+left=goto_split:left
keybind = cmd+ctrl+right=goto_split:right
keybind = cmd+ctrl+up=goto_split:up
keybind = cmd+ctrl+down=goto_split:down

# 均等化（ペインサイズを均等にするために推奨）
keybind = cmd+ctrl+=equalize_splits
```

またはプレフィックスキー（tmuxスタイル）:

```
keybind = ctrl+t>shift+backslash=new_split:right
keybind = ctrl+t>minus=new_split:down
keybind = ctrl+t>h=goto_split:left
keybind = ctrl+t>l=goto_split:right
keybind = ctrl+t>k=goto_split:up
keybind = ctrl+t>j=goto_split:down
keybind = ctrl+t>=equalize_splits
```

## Raycast連携

Raycastのスクリプトコマンドとして登録できます:

```bash
#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Ghostty 4分割
# @raycast.mode silent

/usr/local/bin/ghostty-layout 4
```

異なるレイアウト用に複数のスクリプトを作成:

```bash
#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Ghostty 2x3 Grid
# @raycast.mode silent

/usr/local/bin/ghostty-layout 2x3
```

## 開発

```bash
# ビルド
swift build

# テスト実行
swift test

# リリースビルド
swift build -c release
```

## コントリビューション

コントリビューションを歓迎します！プルリクエストを送る前に[コントリビューションガイド](CONTRIBUTING.md)をお読みください。

- [コントリビューションガイド](CONTRIBUTING.md)
- [テストガイド](docs/TESTING.md)
- [行動規範](CODE_OF_CONDUCT.md)

## ライセンス

MIT
