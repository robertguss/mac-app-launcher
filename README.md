# Workspace Presets

Save which app sits where on your monitor, then put everything back with one Raycast command.

- `presets save <name>` records every visible window on the display containing the most visible standard windows. It records the app, its frame, and the Chrome profile for Chrome windows. Ties prefer the main display, then display UUID order. Raycast's focused panel does not select the display. Minimized windows are not saved.
- `presets apply <name>` unhides and launches the preset's apps, restores matching minimized windows, moves each saved window into place, and hides every other app. When the saved display is not connected, it launches missing apps and leaves existing windows unchanged.

Presets live in `~/Library/Application Support/WorkspacePresets/<name>.json`. Set `PRESETS_DIR` to use another directory.

## Install

```bash
scripts/install.sh
```

This builds a release binary and copies it to `~/.local/bin/presets`.

## Raycast

1. Raycast Settings → Extensions → Script Commands → Add Directories, and choose this repo's `raycast/` folder.
2. Run **Save Preset** once with your windows arranged, for example with the name `work`.
3. Run **Apply Work**. For another preset, copy `raycast/apply-work.sh`, then change its title and the preset name.

The process that runs `presets` needs Accessibility permission: System Settings → Privacy & Security → Accessibility → Raycast (or your terminal).

## Develop

```bash
swift test
```
