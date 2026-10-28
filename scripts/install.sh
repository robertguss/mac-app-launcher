#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."
swift build -c release
mkdir -p "$HOME/.local/bin"
install -m 755 .build/release/presets "$HOME/.local/bin/presets"
echo "Installed $HOME/.local/bin/presets"
