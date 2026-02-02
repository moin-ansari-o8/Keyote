import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/keyboard_viewmodel.dart';
import 'keyboard_half.dart';
import 'keyboard_row.dart';
import 'dual_char_key.dart';
import 'modifier_key.dart' as custom;
import 'special_key.dart';
import 'function_key.dart';
import 'arrow_key.dart';
import 'space_bar.dart';
import 'alpha_key.dart';

class SplitKeyboardLayout extends StatelessWidget {
  const SplitKeyboardLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<KeyboardViewModel>();
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    // Calculate responsive key size
    // Available height minus header (56px only now, no separate preview box)
    final availableHeight =
        screenHeight - 56 - 5; // Header + minimal bottom padding
    final availableWidth =
        screenWidth - 4; // 2px padding each side (maximize space)

    // 6 rows with gaps, each row ~54px (50px key + 4px gap)
    final neededHeight = 6 * 54;
    final verticalScale = availableHeight / neededHeight;

    // Width: left ~400px + center 10px + right ~400px = ~810px (minimal center gap)
    final neededWidth = 810;
    final horizontalScale = availableWidth / neededWidth;

    // Use smaller scale factor to fit both dimensions
    final scaleFactor =
        (verticalScale < horizontalScale ? verticalScale : horizontalScale)
            .clamp(0.4, 1.1);

    return Center(
      child: Transform.scale(
        scale: scaleFactor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Half
            KeyboardHalf(side: 'left', rows: _buildLeftHalf(viewModel)),

            // Center Gap (minimal 10px)
            const SizedBox(width: 10),

            // Right Half
            KeyboardHalf(side: 'right', rows: _buildRightHalf(viewModel)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLeftHalf(KeyboardViewModel vm) {
    return [
      // Row 1: Function keys
      KeyboardRow(
        keys: [
          FunctionKey(label: 'Esc', onPressed: () => vm.sendKey('Escape')),
          FunctionKey(label: 'F1', onPressed: () => vm.sendKey('F1')),
          FunctionKey(label: 'F2', onPressed: () => vm.sendKey('F2')),
          FunctionKey(label: 'F3', onPressed: () => vm.sendKey('F3')),
          FunctionKey(label: 'F4', onPressed: () => vm.sendKey('F4')),
          FunctionKey(label: 'F5', onPressed: () => vm.sendKey('F5')),
          FunctionKey(label: 'F6', onPressed: () => vm.sendKey('F6')),
        ],
      ),

      // Row 2: Numbers
      KeyboardRow(
        keys: [
          DualCharKey(
            primary: '`',
            secondary: '~',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('`'),
            onLongPress: () => vm.sendSecondaryChar('`'),
          ),
          DualCharKey(
            primary: '1',
            secondary: '!',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('1'),
            onLongPress: () => vm.sendSecondaryChar('1'),
          ),
          DualCharKey(
            primary: '2',
            secondary: '@',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('2'),
            onLongPress: () => vm.sendSecondaryChar('2'),
          ),
          DualCharKey(
            primary: '3',
            secondary: '#',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('3'),
            onLongPress: () => vm.sendSecondaryChar('3'),
          ),
          DualCharKey(
            primary: '4',
            secondary: '\$',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('4'),
            onLongPress: () => vm.sendSecondaryChar('4'),
          ),
          DualCharKey(
            primary: '5',
            secondary: '%',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('5'),
            onLongPress: () => vm.sendSecondaryChar('5'),
          ),
          DualCharKey(
            primary: '6',
            secondary: '^',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('6'),
            onLongPress: () => vm.sendSecondaryChar('6'),
          ),
        ],
      ),

      // Row 3: QWERTY
      KeyboardRow(
        keys: [
          SpecialKey(
            label: 'Tab',
            widthMultiplier: 1.5,
            onPressed: () => vm.sendSpecialKey('Tab'),
          ),
          AlphaKey(label: 'Q', onPressed: () => vm.sendCharacter('q')),
          AlphaKey(label: 'W', onPressed: () => vm.sendCharacter('w')),
          AlphaKey(label: 'E', onPressed: () => vm.sendCharacter('e')),
          AlphaKey(label: 'R', onPressed: () => vm.sendCharacter('r')),
          AlphaKey(label: 'T', onPressed: () => vm.sendCharacter('t')),
        ],
      ),

      // Row 4: ASDFG
      KeyboardRow(
        keys: [
          SpecialKey(
            label: 'Caps',
            widthMultiplier: 1.75,
            onPressed: () => vm.toggleCapsLock(),
            backgroundColor: vm.capsLockActive
                ? const Color(0xFF4CAF50)
                : const Color(0xFFB0B0B0),
            textColor: vm.capsLockActive
                ? Colors.white
                : const Color(0xFF1F1F1F),
          ),
          AlphaKey(label: 'A', onPressed: () => vm.sendCharacter('a')),
          AlphaKey(label: 'S', onPressed: () => vm.sendCharacter('s')),
          AlphaKey(label: 'D', onPressed: () => vm.sendCharacter('d')),
          AlphaKey(label: 'F', onPressed: () => vm.sendCharacter('f')),
          AlphaKey(label: 'G', onPressed: () => vm.sendCharacter('g')),
        ],
      ),

      // Row 5: ZXCVB
      KeyboardRow(
        keys: [
          custom.ModifierKey(
            label: 'Shift',
            widthMultiplier: 2.25,
            isActive: vm.shiftPressed,
            onStateChange: (pressed) => vm.setShift(pressed),
          ),
          AlphaKey(label: 'Z', onPressed: () => vm.sendCharacter('z')),
          AlphaKey(label: 'X', onPressed: () => vm.sendCharacter('x')),
          AlphaKey(label: 'C', onPressed: () => vm.sendCharacter('c')),
          AlphaKey(label: 'V', onPressed: () => vm.sendCharacter('v')),
          AlphaKey(label: 'B', onPressed: () => vm.sendCharacter('b')),
        ],
      ),

      // Row 6: Bottom modifiers + space
      KeyboardRow(
        keys: [
          custom.ModifierKey(
            label: 'Ctrl',
            isActive: vm.ctrlPressed,
            onStateChange: (pressed) => vm.setCtrl(pressed),
          ),
          custom.ModifierKey(
            label: 'Win',
            isActive: vm.winPressed,
            onStateChange: (pressed) => vm.setWin(pressed),
          ),
          custom.ModifierKey(
            label: 'Alt',
            isActive: vm.altPressed,
            onStateChange: (pressed) => vm.setAlt(pressed),
          ),
          SpaceBar(
            widthMultiplier: 3.0,
            onPressed: () => vm.sendSpecialKey(' '),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildRightHalf(KeyboardViewModel vm) {
    return [
      // Row 1: Function keys
      KeyboardRow(
        keys: [
          FunctionKey(label: 'F7', onPressed: () => vm.sendKey('F7')),
          FunctionKey(label: 'F8', onPressed: () => vm.sendKey('F8')),
          FunctionKey(label: 'F9', onPressed: () => vm.sendKey('F9')),
          FunctionKey(label: 'F10', onPressed: () => vm.sendKey('F10')),
          FunctionKey(label: 'F11', onPressed: () => vm.sendKey('F11')),
          FunctionKey(label: 'F12', onPressed: () => vm.sendKey('F12')),
          SpecialKey(
            label: 'PrtSc',
            onPressed: () => vm.sendKey('Print'),
            backgroundColor: const Color(0xFFFF9800),
            textColor: Colors.white,
          ),
          SpecialKey(
            label: 'Del',
            onPressed: () => vm.sendKey('Delete'),
            enableRepeat: true,
            backgroundColor: const Color(0xFFFF9800),
            textColor: Colors.white,
          ),
        ],
      ),

      // Row 2: Numbers
      KeyboardRow(
        keys: [
          DualCharKey(
            primary: '7',
            secondary: '&',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('7'),
          ),
          DualCharKey(
            primary: '8',
            secondary: '*',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('8'),
          ),
          DualCharKey(
            primary: '9',
            secondary: '(',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('9'),
          ),
          DualCharKey(
            primary: '0',
            secondary: ')',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('0'),
          ),
          DualCharKey(
            primary: '-',
            secondary: '_',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('-'),
          ),
          DualCharKey(
            primary: '=',
            secondary: '+',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('='),
          ),
          SpecialKey(
            label: 'Backspace',
            widthMultiplier: 2.0,
            onPressed: () => vm.sendSpecialKey('Backspace'),
            enableRepeat: true,
          ),
        ],
      ),

      // Row 3: YUIOP
      KeyboardRow(
        keys: [
          AlphaKey(label: 'Y', onPressed: () => vm.sendCharacter('y')),
          AlphaKey(label: 'U', onPressed: () => vm.sendCharacter('u')),
          AlphaKey(label: 'I', onPressed: () => vm.sendCharacter('i')),
          AlphaKey(label: 'O', onPressed: () => vm.sendCharacter('o')),
          AlphaKey(label: 'P', onPressed: () => vm.sendCharacter('p')),
          DualCharKey(
            primary: '[',
            secondary: '{',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('['),
          ),
          DualCharKey(
            primary: ']',
            secondary: '}',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter(']'),
          ),
          DualCharKey(
            primary: '\\',
            secondary: '|',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('\\\\'),
          ),
        ],
      ),

      // Row 4: HJKL
      KeyboardRow(
        keys: [
          AlphaKey(label: 'H', onPressed: () => vm.sendCharacter('h')),
          AlphaKey(label: 'J', onPressed: () => vm.sendCharacter('j')),
          AlphaKey(label: 'K', onPressed: () => vm.sendCharacter('k')),
          AlphaKey(label: 'L', onPressed: () => vm.sendCharacter('l')),
          DualCharKey(
            primary: ';',
            secondary: ':',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter(';'),
          ),
          DualCharKey(
            primary: '\'',
            secondary: '"',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('\''),
          ),
          SpecialKey(
            label: 'Enter',
            widthMultiplier: 2.0,
            onPressed: () => vm.sendSpecialKey('Return'),
          ),
        ],
      ),

      // Row 5: NM,. + arrows
      KeyboardRow(
        keys: [
          AlphaKey(label: 'N', onPressed: () => vm.sendCharacter('n')),
          AlphaKey(label: 'M', onPressed: () => vm.sendCharacter('m')),
          DualCharKey(
            primary: ',',
            secondary: '<',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter(','),
          ),
          DualCharKey(
            primary: '.',
            secondary: '>',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('.'),
          ),
          DualCharKey(
            primary: '/',
            secondary: '?',
            shiftActive: vm.shiftPressed,
            onPressed: () => vm.sendCharacter('/'),
          ),
          custom.ModifierKey(
            label: 'Shift',
            widthMultiplier: 2.75,
            isActive: vm.shiftPressed,
            onStateChange: (pressed) => vm.setShift(pressed),
          ),
          ArrowKey(
            icon: Icons.keyboard_arrow_up,
            onPressed: () => vm.sendSpecialKey('Up'),
          ),
        ],
      ),

      // Row 6: Bottom modifiers + arrows
      KeyboardRow(
        keys: [
          SpaceBar(
            widthMultiplier: 3.0,
            onPressed: () => vm.sendSpecialKey(' '),
          ),
          custom.ModifierKey(
            label: 'Alt',
            isActive: vm.altPressed,
            onStateChange: (pressed) => vm.setAlt(pressed),
          ),
          custom.ModifierKey(
            label: 'Fn',
            isActive: false,
            onStateChange: (pressed) {},
          ),
          custom.ModifierKey(
            label: 'Ctrl',
            isActive: vm.ctrlPressed,
            onStateChange: (pressed) => vm.setCtrl(pressed),
          ),
          ArrowKey(
            icon: Icons.keyboard_arrow_left,
            onPressed: () => vm.sendSpecialKey('Left'),
          ),
          ArrowKey(
            icon: Icons.keyboard_arrow_down,
            onPressed: () => vm.sendSpecialKey('Down'),
          ),
          ArrowKey(
            icon: Icons.keyboard_arrow_right,
            onPressed: () => vm.sendSpecialKey('Right'),
          ),
        ],
      ),
    ];
  }
}
