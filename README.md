# ghostty-layout

> CLI tool for splitting Ghostty terminal panes from the command line

A command-line utility that creates window split layouts in [Ghostty](https://ghostty.org) terminal by automating keyboard shortcuts. Supports preset layouts and custom grid configurations.

## Features

- **Preset layouts**: Quick shortcuts for common splits (2, 4, 6, 8, 9 panes)
- **Grid notation**: Create any CxR grid (e.g., `3x2` for 3 columns x 2 rows)
- **Auto-detection**: Reads keybindings from your Ghostty config (including prefix keys)
- **Equalize splits**: Automatically equalizes pane sizes after layout creation

## Installation

### From Source

```bash
git clone https://github.com/tackeyy/ghostty-layout.git
cd ghostty-layout
swift build -c release
sudo cp .build/release/ghostty-layout /usr/local/bin/
```

### Release Binary

```bash
curl -sL https://github.com/tackeyy/ghostty-layout/releases/latest/download/ghostty-layout -o /usr/local/bin/ghostty-layout && chmod +x /usr/local/bin/ghostty-layout
```

## Usage

```bash
ghostty-layout <layout>
```

### Layouts

| Command | Description |
|---------|-------------|
| `ghostty-layout h` | Horizontal 2-column (2x1) |
| `ghostty-layout v` | Vertical 2-row (1x2) |
| `ghostty-layout 4` | 4 panes (2x2) |
| `ghostty-layout 6` | 6 panes (2x3) |
| `ghostty-layout 8` | 8 panes (4x2) |
| `ghostty-layout 9` | 9 panes (3x3) |

### Grid Notation (CxR)

Create custom grids using `CxR` format where C is columns and R is rows:

```bash
ghostty-layout 2x3   # 2 columns x 3 rows = 6 panes
ghostty-layout 3x2   # 3 columns x 2 rows = 6 panes
ghostty-layout 4x2   # 4 columns x 2 rows = 8 panes
```

Supports grids from 1x1 to 8x8.

### Options

```bash
ghostty-layout --help         # Show help
ghostty-layout --version      # Show version
ghostty-layout --list         # List available layouts
ghostty-layout --show-config  # Show current configuration
ghostty-layout --init-config  # Regenerate config from Ghostty settings
ghostty-layout --sync-config  # Sync config with Ghostty settings
```

## Configuration

ghostty-layout automatically reads your Ghostty keybindings and generates a configuration file on first run.

### Config File Location

```
~/.config/ghostty-layout/config.json
```

### Auto-Detection

The tool parses your Ghostty config file (`~/.config/ghostty/config`) and extracts:

- `new_split:right` - Split horizontally (create pane to the right)
- `new_split:down` - Split vertically (create pane below)
- `goto_split:left/right/up/down` - Navigate between panes
- `equalize_splits` - Equalize all pane sizes
- Prefix key support (e.g., `ctrl+t > h`)

### Syncing Configuration

If you change your Ghostty keybindings, sync the configuration:

```bash
ghostty-layout --sync-config
```

You can also sync and apply a layout in one command:

```bash
ghostty-layout --sync-config 3x2
```

### Manual Configuration

The config file uses JSON format:

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

## Prerequisites

### 1. Accessibility Permission

On first run, you must grant Accessibility permission.

**System Settings > Privacy & Security > Accessibility** and allow Terminal (or ghostty-layout).

### 2. Ghostty Keybindings

Ensure these actions are bound in your Ghostty config (`~/.config/ghostty/config`):

```
# Split commands
keybind = cmd+d=new_split:right
keybind = cmd+shift+d=new_split:down

# Navigation
keybind = cmd+ctrl+left=goto_split:left
keybind = cmd+ctrl+right=goto_split:right
keybind = cmd+ctrl+up=goto_split:up
keybind = cmd+ctrl+down=goto_split:down

# Equalize (recommended for even pane sizes)
keybind = cmd+ctrl+=equalize_splits
```

Or with a prefix key (tmux-style):

```
keybind = ctrl+t>shift+backslash=new_split:right
keybind = ctrl+t>minus=new_split:down
keybind = ctrl+t>h=goto_split:left
keybind = ctrl+t>l=goto_split:right
keybind = ctrl+t>k=goto_split:up
keybind = ctrl+t>j=goto_split:down
keybind = ctrl+t>=equalize_splits
```

## Raycast Integration

Register as a Raycast script command:

```bash
#!/bin/bash
# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Ghostty 4-split
# @raycast.mode silent

/usr/local/bin/ghostty-layout 4
```

Create multiple scripts for different layouts:

```bash
#!/bin/bash
# @raycast.schemaVersion 1
# @raycast.title Ghostty 2x3 Grid
# @raycast.mode silent

/usr/local/bin/ghostty-layout 2x3
```

## License

MIT
