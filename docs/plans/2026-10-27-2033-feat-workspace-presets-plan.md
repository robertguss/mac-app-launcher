---
title: Workspace Presets - Plan
type: feat
date: 2026-10-27
topic: workspace-presets
artifact_contract: ce-unified-plan/v1
product_contract_source: ce-brainstorm
execution: code
---

# Workspace Presets - Plan

## Goal Capsule

- **Objective:** Robert switches into a work or personal mode with one Raycast command, and every app for that mode is open and sitting in its saved spot on the 40" monitor within seconds, with nothing dragged by hand.
- **Means:** A small native Swift command-line tool that saves and applies named presets, invoked by one Raycast Script Command per preset.
- **Product authority:** Robert is the sole user and decides product behavior. This is a personal tool; there is no distribution, onboarding, or second user.
- **Open blockers:** None.

---

## Product Contract

### Summary

A Swift command-line tool with two commands. `save <name>` records which app sits in which spot on the current monitor. `apply <name>` launches missing apps, moves each saved window into place, and hides every app outside the preset. Raycast triggers each preset; the tool never restores what is inside a window.

### Problem Frame

Robert works on a single 40" monitor with six windows in a fixed 3x2 arrangement. Every time he starts work he opens the apps and drags each window into its slot with Rectangle. The arrangement never changes, so the repetition is pure friction. He previously used a Setapp app (likely Workspaces by Apptorium) that did this and wants his own version, partly for a custom fit and partly for the fun of building it.

His current work preset, for reference:

| Slot | App |
|---|---|
| Top left | Notion |
| Top middle | Chrome, work profile |
| Top right | Chrome, personal profile |
| Bottom left | Cursor |
| Bottom middle | WezTerm |
| Bottom right | Amp |

### Key Decisions

- **Presets are captured, not authored.** Robert arranges windows by hand once, as he already does, and saves the result; there is no layout editor or config to write. (session-settled: user-approved — chosen over a grid editor or a config file: captures his real arrangement with zero editing UI.) Governs R1, R2.
- **Launch and place only.** Apps restore their own content (tabs, projects, sessions). (session-settled: user-approved — chosen over opening specific URLs or folders and full content restore: each content type would be a separate integration.) Governs R5.
- **Other apps are hidden, not quit or left in place.** (session-settled: user-approved — chosen over leaving them or quitting them: clears the screen without risking unsaved work.) Governs R7.
- **Raycast is the only trigger surface.** No menu bar item, no built-in hotkeys; Raycast supplies search and hotkeys. (session-settled: user-directed — chosen over a menu bar list with hotkeys: Robert already lives in Raycast.) Governs R10.
- **The tool positions windows itself.** Robert uses Rectangle-style snapping, which only acts on command, so there is no tiling manager to drive or fight. (session-settled: user-directed — chosen over integrating with a tiling window manager: he does not use one.) Governs R4.
- **Build approach A: Swift CLI plus Raycast Script Commands.** (session-settled: user-directed — chosen over a Hammerspoon config and a full Raycast extension: least code to own while still a real native build; a Raycast extension can sit on top later.)

### Requirements

**Saving a preset**

- R1. `save <name>` records, for each visible window on the current display, the app, its position and size, and the display it was saved on.
- R2. Saving under an existing name overwrites that preset without confirmation.
- R3. Windows of the same app are distinguished by Chrome profile, so the work and personal Chrome windows save as separate entries.

**Applying a preset**

- R4. `apply <name>` moves each saved window to its saved position and size.
- R5. Apps in the preset that are not running are launched, Chrome entries into their saved profile, and the tool does not open any specific file, URL, or project.
- R6. When an app has several matching windows, the most recently used one is placed and the rest are left where they are.
- R7. Every running app not in the preset is hidden.
- R8. When the display the preset was saved on is not connected, apps are launched but no window is moved.
- R9. When a launched app's window does not appear within a short, bounded wait, that entry is skipped and the rest of the preset still applies.

**Triggering**

- R10. Each preset is triggered by its own Raycast Script Command, and saving a new preset is also runnable from Raycast.

### Acceptance Examples

- AE1. **Covers R4, R5, R7.** Given only Spotify and Messages are open, when Robert runs Apply Work, then all six work apps open in their slots and Spotify and Messages are hidden.
- AE2. **Covers R6.** Given three work-profile Chrome windows are open, when Robert runs Apply Work, then the most recently used one moves to top middle and the other two stay where they were.
- AE3. **Covers R8.** Given the laptop is undocked from the 40" monitor, when Robert runs Apply Work, then missing apps launch and no window moves.
- AE4. **Covers R9.** Given Cursor takes too long to show a window, when Robert runs Apply Work, then the other five windows are placed and Cursor is left unplaced.
- AE5. **Covers R3, R5.** Given Chrome is not running, when Robert runs Apply Work, then one window opens in the work profile at top middle and one in the personal profile at top right.

### Success Criteria

- From a cold start with none of the six apps running, Apply Work leaves all six windows in place in well under 15 seconds.
- Running Apply Work twice in a row changes nothing the second time.

### Scope Boundaries

**Deferred for later**

- A Raycast extension UI for listing, renaming, and deleting presets.
- Presets spanning multiple monitors or macOS Spaces.
- Opening specific files, URLs, or project folders per window.
- Proportional scaling of a layout onto a different display.
- A visual layout editor.

**Outside this tool's identity**

- Content restore (tabs, terminal sessions, editor state).
- A general window manager or snapping tool; Rectangle keeps that job.
- Distribution to other users.

### Dependencies / Assumptions

- macOS Accessibility permission is granted to whatever process runs the tool (likely Raycast, which typically already holds it for its own window commands).
- Chrome shows the profile name in each window title when more than one profile exists; R3 depends on this and it is unverified on Robert's machine.
- Amp runs as its own desktop app with its own window, not as a WezTerm or Chrome tab.

### Outstanding Questions

**Deferred to Planning**

- How the tool reliably reads a Chrome window's profile and launches Chrome into a named profile.
- Where presets are stored on disk.
- The exact bounded wait for cold-launched windows in R9.
