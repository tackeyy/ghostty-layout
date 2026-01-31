#!/bin/bash
set -e

echo "Building ghostty-layout..."
cd "$(dirname "$0")/.."

swift build -c release

echo "Installing to /usr/local/bin..."
sudo cp .build/release/ghostty-layout /usr/local/bin/

echo "Done! Run 'ghostty-layout --help' to get started."
