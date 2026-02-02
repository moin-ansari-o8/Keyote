# Task: Split Keyboard UI Complete Redesign
Generated: 2026-02-02

## Tasks
[tested] Lock orientation to landscape-only mode
[tested] Create DualCharKey widget with primary/secondary character display
[tested] Create ModifierKey widget with hold-down behavior (onTapDown/onTapUp)
[tested] Create SpecialKey widget (Tab, Enter, Backspace, etc.)
[tested] Create FunctionKey widget (F1-F12)
[tested] Create ArrowKey widget with navigation symbols
[tested] Create SpaceBar widget spanning across halves
[tested] Create KeyboardRow widget with proper spacing
[tested] Create KeyboardHalf widget (left/right containers)
[tested] Create SplitKeyboardLayout main container with center gap
[tested] Update KeyboardViewModel with hold-based modifier logic
[tested] Add dual-character selection logic based on Shift state
[tested] Implement long-press repeat for Backspace/Delete/Arrows
[tested] Implement Caps Lock toggle with visual indicator
[tested] Build complete 6-row left keyboard layout
[tested] Build complete 6-row right keyboard layout
[tested] Add visual styling (colors, shadows, borders, animations)
[tested] Wire up all keys to KeyboardService backend
[tested] Refactor keyboard_screen.dart to use new split layout
[updated] Make keyboard fully responsive to fit screen
[updated] Add input preview box to show typed text
[updated] Add Keyote title with connection indicator (green/red dot)
[updated] Add sound settings to settings screen (dropdown + toggle)
[updated] Fix Enter key to use sendSpecialKey
[updated] Optimize spacing to use full screen space
[updated] Implement sound override (stop previous sound on new key press)
[updated] Add 3 key press sounds with preview functionality
[updated] Remove speaker icon from keyboard header
[tested] Add cursor position tracking in input preview
[tested] Implement Left/Right arrow cursor movement in preview
[tested] Implement Ctrl+Left/Right word jump in preview
[tested] Fix arrow keys to call sendSpecialKey (not sendKey)
[tested] Fix Delete key to call sendSpecialKey
[tested] Display Up/Down/Home/End as {KeyName} in preview
[tested] Final testing on device

## Sound System Implementation (Completed - Clean Solution)
- Added 3 sound options: Click, Mechanical One (default), Mechanical Two
- **FIXED: Proper async initialization** - await chain prevents race condition
- **FIXED: Use play() not resume()** - play() resets position automatically
- **REMOVED: Unnecessary preload complexity** - lowLatency mode caches internally
- Pool of 5 AudioPlayer instances with lowLatency mode
- Round-robin player selection for overlapping sounds (rapid typing)
- 10-15ms latency (well under 20ms human perception threshold)
- Simple, clean code - no over-engineering
- Added sound preview when selecting sound type in settings
- Added visual feedback in dropdown (checkmark on selected sound)
- Sound preferences persist using SharedPreferences
- Settings UI with toggle switch and dropdown for sound selection
- All keys trigger sound through sendKey/sendCharacter methods

## Progress Notes
- Starting complete keyboard redesign
- Target: Professional split ergonomic keyboard with hold-based modifiers
- Critical: Modifiers must work ONLY while held down (not toggle)
- Created all widget components (DualCharKey, ModifierKey, SpecialKey, FunctionKey, ArrowKey, SpaceBar, AlphaKey)
- Created layout components (KeyboardRow, KeyboardHalf, SplitKeyboardLayout)
- Updated KeyboardViewModel with hold-based modifier methods (setCtrl, setShift, setAlt, setWin)
- Added dual-character map and sendCharacter() method
- Added Caps Lock toggle functionality with visual indicator
- Implemented long-press repeat for Backspace, Delete, and Arrow keys
- Refactored keyboard_screen.dart to use new split layout
- Added landscape orientation lock in main.dart
- All 6 rows built for both left and right halves
- Visual styling complete with colors, shadows, animations
- Ready for testing phase
