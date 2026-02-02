# KEYOTE SPLIT KEYBOARD UI REDESIGN - COMPLETE SPECIFICATION

## OBJECTIVE

Transform Keyote mobile app into a professional split ergonomic keyboard with proper key behavior, spacing, and visual design matching the provided mechanical keyboard image.

---

## CRITICAL BEHAVIORAL REQUIREMENT

### Modifier Keys Must Work Like Real Keyboards

**MODIFIER KEYS WORK ONLY WHILE PRESSED DOWN:**
- Shift/Ctrl/Alt/Win keys work ONLY while pressed down (onTapDown/onTapUp events)
- **NOT toggle behavior** - keys activate on press, deactivate on release
- Example: Hold Shift → Press K → Release Shift = Types "K"
- Example: Hold Ctrl → Press C → Release Ctrl = Sends Ctrl+C
- Multiple modifiers: Hold Ctrl+Shift together, then press key
- Visual feedback: Key highlights ONLY while finger is touching it

**Current WRONG behavior (toggle):**
- Tap Shift once → stays active → tap again to disable

**Required CORRECT behavior (hold):**
- Press & hold Shift → active only while holding → release = deactivates

---

## KEYBOARD LAYOUT SPECIFICATION

### Orientation

- **Landscape-only mode** (lock portrait completely)
- **Force orientation on app start**

### Left Half (6 Rows)

```
Row 1: [Esc] [F1] [F2] [F3] [F4] [F5] [F6]

Row 2: [`~] [1!] [2@] [3#] [4$] [5%] [6^]

Row 3: [Tab——] [Q] [W] [E] [R] [T]

Row 4: [Caps——] [A] [S] [D] [F] [G]

Row 5: [Shift————] [Z] [X] [C] [V] [B]

Row 6: [Ctrl] [Win] [Alt] [———————Space———————]
```

**Key Width Multipliers (Left):**
- Standard key: 1.0x (50-60px)
- Tab: 1.5x
- Caps Lock: 1.75x
- Left Shift: 2.25x
- Space (left portion): 3.0x

---

### Right Half (6 Rows)

```
Row 1: [F7] [F8] [F9] [F10] [F11] [F12] [PrtSc] [Del]

Row 2: [7&] [8*] [9(] [0)] [-_] [=+] [———Backspace———]

Row 3: [Y] [U] [I] [O] [P] [{[] [}]] [\|]

Row 4: [H] [J] [K] [L] [;:] ['"] [———Enter———]
                                      ┃
Row 5: [N] [M] [,<] [.>] [/?] [——Shift——] [↑]

Row 6: [———————Space———————] [Alt] [Fn] [Ctrl] [←] [↓] [→]
```

**Key Width Multipliers (Right):**
- Standard key: 1.0x
- Backspace: 2.0x
- Enter: 2.0x (consider vertical spanning if possible)
- Right Shift: 2.75x
- Space (right portion): 3.0x
- Arrow keys: 1.0x each

**Arrow Key Position:**
- Row 5: Up arrow (↑) placed immediately right of Shift
- Row 6: Left (←), Down (↓), Right (→) arrows placed right of Ctrl

---

## VISUAL DESIGN SPECIFICATIONS

### Spacing and Layout

**Key Spacing:**
- **Gap between keys:** 3-4px
- **Gap between left/right halves:** 80-120px (large enough for future mouse controller area)
- **Vertical spacing between rows:** 4-6px
- **Edge padding:** 12-16px from screen edges

**Middle Gap Usage:**
- Reserve 80-120px center space (currently empty)
- This space will hold mouse trackpad controls in future
- Optionally show connection indicator or subtle branding here

### Color Scheme

**Key Categories:**
- **Alpha keys (A-Z):** Light gray background (#E8E8E8), dark text (#1F1F1F)
- **Number/Symbol keys:** Same as alpha
- **Modifiers (Ctrl, Alt, Shift, Win, Fn):** Blue accent (#2196F3), white text
- **Special keys (Tab, Caps, Enter, Backspace):** Medium gray (#B0B0B0), dark text
- **Function keys (F1-F12):** Dark gray (#616161), white text
- **Navigation (Arrows, Del, PrtSc):** Orange accent (#FF9800), white text
- **Space bar:** Gradient blue (#2196F3 to #1976D2), white text

**State Indicators:**
- **Pressed state (while holding):** Darker shade + scale 0.95x + shadow
- **Caps Lock active:** Green LED indicator or highlighted border
- **Connection status:** Small colored dot in middle gap area

### Typography

**Dual-Character Display:**
```
  !          @          #
[1]        [2]        [3]
```
- Primary character: 18-20px, bold, center-bottom
- Secondary character: 10-12px, normal weight, top-right corner
- Spacing: 2-4px from key edges

**Special Key Labels:**
- Modifier text: 12-14px, uppercase
- Function keys: 10-12px
- Arrow symbols: Use Material Icons (keyboard_arrow_up/down/left/right)

### Key Appearance

**Border and Shadow:**
- Border radius: 6-8px (rounded corners)
- Border: 1px solid rgba(0,0,0,0.1)
- Shadow (unpressed): 0px 2px 4px rgba(0,0,0,0.15)
- Shadow (pressed): 0px 1px 2px rgba(0,0,0,0.1) (inset feel)

**Animation:**
- Press animation: Scale 0.95x + darken 10% (duration: 100ms)
- Release animation: Scale back to 1.0x (duration: 100ms)
- Ripple effect on tap

---

## FUNCTIONAL REQUIREMENTS

### A. Modifier Key Behavior (CRITICAL)

**Implementation using GestureDetector:**

```dart
// Pseudo-code for modifier keys
GestureDetector(
  onTapDown: (_) {
    setState(() => ctrlPressed = true);
    // Visual highlight
  },
  onTapUp: (_) {
    setState(() => ctrlPressed = false);
    // Remove highlight
  },
  onTapCancel: () {
    setState(() => ctrlPressed = false);
    // Handle if finger moves away
  },
  child: ModifierKeyWidget(label: 'Ctrl', isActive: ctrlPressed),
)
```

**Rules:**
- Modifiers activate on `onTapDown`, deactivate on `onTapUp`
- Multiple modifiers can be held simultaneously
- When character key pressed, send with active modifier states
- No sticky/toggle mode for Shift/Ctrl/Alt
- Exception: Caps Lock uses toggle behavior (standard keyboard behavior)

### B. Dual-Character Key Logic

```dart
Map<String, DualChar> keyMap = {
  '1': DualChar(primary: '1', secondary: '!'),
  '2': DualChar(primary: '2', secondary: '@'),
  '3': DualChar(primary: '3', secondary: '#'),
  '4': DualChar(primary: '4', secondary: '\$'),
  '5': DualChar(primary: '5', secondary: '%'),
  '6': DualChar(primary: '6', secondary: '^'),
  '7': DualChar(primary: '7', secondary: '&'),
  '8': DualChar(primary: '8', secondary: '*'),
  '9': DualChar(primary: '9', secondary: '('),
  '0': DualChar(primary: '0', secondary: ')'),
  '-': DualChar(primary: '-', secondary: '_'),
  '=': DualChar(primary: '=', secondary: '+'),
  '[': DualChar(primary: '[', secondary: '{'),
  ']': DualChar(primary: ']', secondary: '}'),
  '\\': DualChar(primary: '\\', secondary: '|'),
  ';': DualChar(primary: ';', secondary: ':'),
  '\'': DualChar(primary: '\'', secondary: '"'),
  ',': DualChar(primary: ',', secondary: '<'),
  '.': DualChar(primary: '.', secondary: '>'),
  '/': DualChar(primary: '/', secondary: '?'),
  '`': DualChar(primary: '`', secondary: '~'),
};

// On key press
void sendCharacter(String keyId) {
  String char;
  
  if (keyMap.containsKey(keyId)) {
    char = shiftPressed 
      ? keyMap[keyId].secondary 
      : keyMap[keyId].primary;
  } else if (isAlpha(keyId)) {
    char = (shiftPressed || capsLockActive) 
      ? keyId.toUpperCase() 
      : keyId.toLowerCase();
  } else {
    char = keyId;
  }
  
  keyboardService.sendKey(
    char,
    ctrl: ctrlPressed,
    alt: altPressed,
    shift: shiftPressed,
  );
}
```

### C. Special Key Behaviors

**Caps Lock:**
- Toggle on/off with tap
- Visual indicator (LED dot or border highlight)
- Affects ONLY letter keys (A-Z)
- Does NOT affect number/symbol keys

**Backspace/Delete:**
- Single tap: Delete one character
- Long press: Continuous repeat (150ms intervals)
- Use `onLongPress` + Timer for repeat

**Arrow Keys:**
- Single tap: Move cursor once
- Long press: Continuous movement (100ms intervals)

**Space Bar:**
- Spans across both halves (6x width total: 3x left + 3x right)
- OR create two space buttons (one per half) that send same command
- Center alignment between halves

**Function Keys (F1-F12):**
- Map to system function keys
- No repeat on long press

**PrtSc (Print Screen):**
- Send screenshot command to laptop

**Win Key:**
- Send Windows/Super key command
- Works with modifiers (Win+L, Win+D, etc.)

**Fn Key:**
- Currently placeholder (future: media controls, brightness)
- Optional: Toggle secondary layer (volume, brightness keys)

---

## FILE STRUCTURE

### New/Modified Files

```
lib/
├── main.dart (modify: add orientation lock)
├── views/
│   ├── keyboard_screen.dart (COMPLETE REFACTOR)
│   └── widgets/
│       ├── split_keyboard_layout.dart (NEW - main keyboard container)
│       ├── keyboard_half.dart (NEW - left/right half containers)
│       ├── keyboard_row.dart (NEW - row layout with spacing)
│       ├── dual_char_key.dart (NEW - keys with primary/secondary chars)
│       ├── modifier_key.dart (NEW - hold-to-activate keys)
│       ├── special_key.dart (NEW - Tab, Enter, Backspace, etc.)
│       ├── function_key.dart (NEW - F1-F12)
│       ├── arrow_key.dart (NEW - navigation arrows)
│       ├── space_bar.dart (NEW - spanning space key)
│       └── connection_indicator.dart (existing - move to middle gap)
├── viewmodels/
│   └── keyboard_viewmodel.dart (REFACTOR - add hold behavior)
└── services/
    └── keyboard_service.dart (verify/update as needed)
```

---

## IMPLEMENTATION STEPS

### Step 1: Lock Orientation

```dart
// In main.dart or keyboard_screen.dart initState
import 'package:flutter/services.dart';

SystemChrome.setPreferredOrientations([
  DeviceOrientation.landscapeLeft,
  DeviceOrientation.landscapeRight,
]);
```

### Step 2: Create Key Widget Components

**DualCharKey Widget:**
- Display primary/secondary characters
- Handle tap with modifier state
- Visual feedback on press
- Sizing based on width multiplier

**ModifierKey Widget:**
- onTapDown/onTapUp events (NOT onTap)
- Visual highlight while held
- Return hold state to parent

**SpecialKey Widget:**
- Single-function keys (Tab, Enter, etc.)
- Long press support for repeatable keys
- Custom sizing

### Step 3: Build Row Layouts

Create 6 rows per half with proper key sequences and spacing.

### Step 4: Assemble Split Layout

- Main container: Row with left half, center gap, right half
- Responsive sizing based on screen width
- Handle different screen sizes (phones, tablets)

### Step 5: Update ViewModel Logic

- Track modifier states (ctrlPressed, altPressed, shiftPressed, etc.)
- Track Caps Lock toggle state
- Implement hold-based modifier activation
- Send keys with correct modifier combinations

### Step 6: Backend Integration

- Ensure KeyboardService correctly handles all key codes
- Test modifier combinations
- Verify special keys (F-keys, PrtSc, Win, etc.)

---

## SUCCESS CRITERIA

### Functional Requirements

- App opens in landscape mode only
- Keyboard displays as split design with center gap
- All 104+ keys present and positioned correctly
- Dual characters display on appropriate keys
- Shift works ONLY while held down (not toggle)
- Ctrl/Alt work ONLY while held down
- Caps Lock toggles (standard behavior)
- Multiple modifiers can be held together (Ctrl+Shift+X)
- Arrow keys positioned correctly (Up in row 5, Left/Down/Right in row 6)
- Long press repeat works on Backspace, Delete, Arrows
- All characters send correctly to laptop
- Function keys (F1-F12) work
- Space bar functional

### Visual Requirements

- Proper spacing between keys (3-4px)
- Large center gap (80-120px) for future mouse controls
- Color coding matches specification
- Key sizes match multipliers (Tab 1.5x, Shift 2.25x, etc.)
- Dual characters positioned correctly (primary bottom, secondary top-right)
- Pressed state shows visual feedback
- Caps Lock shows active indicator
- Connection status visible (middle gap)
- No layout overflow on different screen sizes
- Keys are easily tappable (not too small)

### Performance Requirements

- No lag on key presses
- Animations smooth (60fps)
- Modifiers respond instantly
- No missed inputs

---

## DESIGN GOALS

1. **Ergonomic Split Layout:** Left/right separation reduces wrist strain (mental model for mobile)
2. **Real Keyboard Behavior:** Modifiers work by holding, not toggling
3. **Professional Appearance:** Clean, modern, properly spaced UI
4. **Future-Proof:** Center gap reserved for mouse trackpad controls
5. **Responsive:** Works on various Android screen sizes
6. **Tactile Feedback:** Visual/haptic response on key presses
7. **Accessibility:** Large enough keys for accurate typing

---

## CRITICAL IMPLEMENTATION NOTES

### DO NOT

- Use toggle behavior for Shift/Ctrl/Alt
- Create separate space keys that work differently
- Ignore the center gap spacing requirement
- Mix up arrow key positions (Up is Row 5, others Row 6)
- Make keys too small to tap comfortably
- Use portrait mode or allow rotation

### DO

- Use onTapDown/onTapUp for modifiers
- Maintain 80-120px center gap
- Test on physical device (not just emulator)
- Implement proper visual feedback
- Handle edge cases (rapid tapping, multiple fingers)
- Test all key combinations
- Verify backend receives correct commands

---

## TESTING CHECKLIST

### Basic Typing

- Type "Hello World" using shift correctly
- Type all lowercase letters (a-z)
- Type all uppercase letters (A-Z)
- Type all numbers (0-9)
- Type all symbols (!@#$%^&*()_+-=[]{}|;:'",.<>/?)

### Modifier Combinations

- Ctrl+C (copy)
- Ctrl+V (paste)
- Ctrl+Z (undo)
- Ctrl+Shift+N (new incognito window)
- Alt+Tab (switch windows)
- Ctrl+Alt+Del (task manager)
- Win+L (lock screen)

### Special Keys

- Backspace deletes one character
- Backspace long press repeats
- Delete key works
- Enter/Return works
- Tab works (indentation, focus change)
- Esc key works
- Arrow keys navigate
- Arrow long press repeats
- Caps Lock toggles correctly
- Caps Lock indicator shows state

### Function Keys

- F1 through F12 all work
- PrtSc captures screenshot
- Win key activates start menu

### Edge Cases

- Hold Shift, tap multiple letters, release Shift (all caps)
- Rapidly tap keys (no missed inputs)
- Hold multiple modifiers + character key
- Tap modifier without pressing other key (does nothing)
- Connection lost during typing (graceful handling)

---

## FINAL UI MOCKUP DESCRIPTION

**Landscape view layout:**

```
┌────────────────────────────────────────────────────────────────────────────┐
│ Status Bar (Connection: Connected)                           [Settings]   │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  LEFT HALF                    [CENTER GAP]              RIGHT HALF         │
│  ┌─────────────┐                                      ┌─────────────┐    │
│  │ Esc F1 F2...│              (Reserved for          │...F10 F11 F12│    │
│  │ `~ 1! 2@... │               mouse trackpad)       │ 7& 8* 9(... │    │
│  │ Tab Q W E...│                                      │ Y U I O P...│    │
│  │ Caps A S D..│              80-120px gap           │ H J K L ;:..│    │
│  │ Shift Z X C.│                                      │ N M ,< .>.. │    │
│  │ Ctrl Win Alt│                                      │ Alt Fn Ctrl │    │
│  │  [————Space————]                               [————Space————]  │    │
│  └─────────────┘                                      └─────────────┘    │
│                                                         [↑]               │
│                                                      [←][↓][→]            │
└────────────────────────────────────────────────────────────────────────────┘
```

**Color visualization:**
- Gray keys: Alpha/numbers
- Blue keys: Modifiers (Ctrl, Alt, Shift, Win, Fn)
- Orange keys: Arrows, Del, PrtSc
- Dark gray: Function keys
- Medium gray: Tab, Caps, Enter, Backspace
- Blue gradient: Space bar

**When pressing Shift:**
- Shift key highlights in bright blue
- Dual-char keys visually emphasize secondary character
- Release Shift = returns to normal

---

## END OF SPECIFICATION
