# Learnings

## Chrome profiles

- Chrome's Accessibility window title ends in ` - Google Chrome - <label>`, for example `Repo - Google Chrome - Robert (Work)`. The text inside the trailing parentheses is the profile `name` from `~/Library/Application Support/Google/Chrome/Local State` → `profile.info_cache`, keyed by profile directory (`Default`, `Profile 5`).
- Chrome's AppleScript `name of window` is only the page title, so it cannot identify the profile.
- `NSWorkspace.openApplication` with `createsNewApplicationInstance = true` and `--profile-directory=<dir>` opens a new window in that profile in the running Chrome.

## macOS 26 behavior

- `NSRunningApplication.hide()` and `unhide()` return `false` even when they work. Do not use the return value.
- WezTerm applies an Accessibility size change asynchronously. One position/size/position pass leaves the window clamped by its old size. Re-sending the frame after about 100 ms lands it, so `move` retries until the frame reads back correctly.
- Notion has a minimum window width of 640 points.
- `kAXWindowsAttribute` returns an app's windows front to back for Chrome, which is how the most recently used window is chosen.
- Accessibility permission belongs to the responsible app. Commands run inside a WezTerm session use WezTerm's grant, and Raycast Script Commands use Raycast's.
- Minimized Chrome windows still expose their profile title and frame through AX. Apply must include them in matching and set `AXMinimized` to false before checking or placing the frame. Save must continue to exclude them. Verified against an existing Work window without opening a duplicate.

## Save display selection

- A real compact Raycast Script Command runs under `Raycast Backend → /bin/bash` while Raycast can remain frontmost with its `AXSystemDialog` panel focused. The old Save path used that panel's display even though it excluded the panel from captured standard windows.
- Verified with Raycast focused at `[525,187 750x475]` on the built-in display and three layout windows on DELL U4025QW. Old Save captured two built-in windows. Window-count selection captured the Dell UUID `E28319F7-8A5E-400C-8506-A18AA967E8B5` and all three layout windows. Each saved display-relative frame matched an independent AX snapshot after adding the Dell origin `[-1602,-2160]`.
- Save now selects the display containing the most visible standard window centers. It prefers the main display on ties, then UUID order. It uses the same snapshot for display selection and capture, so the focused app and Raycast panel do not determine the saved display.

## Proof tooling

- An independent AX probe (a small Swift script that lists standard windows with frames and can set a frame) is the fastest way to arrange, scramble, and read back windows when proving save and apply.
