#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Save Preset
# @raycast.mode compact
# @raycast.packageName Workspace Presets
# @raycast.icon 💾
# @raycast.argument1 { "type": "text", "placeholder": "Preset name" }

"$HOME/.local/bin/presets" save "$1" 2>&1
