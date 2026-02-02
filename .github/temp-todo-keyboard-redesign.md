# Task: Split Keyboard UI Complete Redesign
Generated: 2026-02-02

## Tasks
[updated] Lock orientation to landscape-only mode
[updated] Create DualCharKey widget with primary/secondary character display
[updated] Create ModifierKey widget with hold-down behavior (onTapDown/onTapUp)
[updated] Create SpecialKey widget (Tab, Enter, Backspace, etc.)
[updated] Create FunctionKey widget (F1-F12)
[updated] Create ArrowKey widget with navigation symbols
[updated] Create SpaceBar widget spanning across halves
[updated] Create KeyboardRow widget with proper spacing
[updated] Create KeyboardHalf widget (left/right containers)
[updated] Create SplitKeyboardLayout main container with center gap
[updated] Update KeyboardViewModel with hold-based modifier logic
[updated] Add dual-character selection logic based on Shift state
[updated] Implement long-press repeat for Backspace/Delete/Arrows
[updated] Implement Caps Lock toggle with visual indicator
[updated] Build complete 6-row left keyboard layout
[updated] Build complete 6-row right keyboard layout
[updated] Add visual styling (colors, shadows, borders, animations)
[updated] Wire up all keys to KeyboardService backend
[updated] Refactor keyboard_screen.dart to use new split layout
[todo-20] Test all modifier combinations (Ctrl+C, Ctrl+Shift+N, etc.)
[todo-21] Test dual-character input with Shift
[todo-22] Test long-press repeat behavior
[todo-23] Test Caps Lock indicator and behavior
[todo-24] Test on physical device in landscape mode
[todo-25] Security review and final polish

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
