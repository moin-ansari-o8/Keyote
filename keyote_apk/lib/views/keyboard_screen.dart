import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/keyboard_viewmodel.dart';
import 'widgets/connection_indicator.dart';
import 'widgets/key_button.dart';
import 'widgets/modifier_toggle.dart';

class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({super.key});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardViewModel = context.watch<KeyboardViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyote Remote'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const ConnectionIndicator(),
              const SizedBox(height: 24),

              TextField(
                controller: _textController,
                focusNode: _focusNode,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Type here...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    final lastChar = text[text.length - 1];
                    keyboardViewModel.sendKey(lastChar);
                  }
                },
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ModifierToggle(
                    label: 'Ctrl',
                    isPressed: keyboardViewModel.ctrlPressed,
                    onToggle: keyboardViewModel.toggleCtrl,
                  ),
                  ModifierToggle(
                    label: 'Alt',
                    isPressed: keyboardViewModel.altPressed,
                    onToggle: keyboardViewModel.toggleAlt,
                  ),
                  ModifierToggle(
                    label: 'Shift',
                    isPressed: keyboardViewModel.shiftPressed,
                    onToggle: keyboardViewModel.toggleShift,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  KeyButton(
                    label: 'Esc',
                    onPressed: () => keyboardViewModel.sendKey('Escape'),
                  ),
                  KeyButton(
                    label: 'Tab',
                    onPressed: () => keyboardViewModel.sendKey('Tab'),
                  ),
                  KeyButton(
                    label: 'Enter',
                    onPressed: () => keyboardViewModel.sendKey('Return'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  KeyButton(
                    label: 'Backspace',
                    onPressed: () => keyboardViewModel.sendKey('BackSpace'),
                    onLongPress: () =>
                        keyboardViewModel.startKeyRepeat('BackSpace'),
                    onLongPressEnd: keyboardViewModel.stopKeyRepeat,
                  ),
                  KeyButton(
                    label: 'Delete',
                    onPressed: () => keyboardViewModel.sendKey('Delete'),
                    onLongPress: () =>
                        keyboardViewModel.startKeyRepeat('Delete'),
                    onLongPressEnd: keyboardViewModel.stopKeyRepeat,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Column(
                children: [
                  KeyButton(
                    icon: Icons.keyboard_arrow_up,
                    label: '',
                    onPressed: () => keyboardViewModel.sendKey('Up'),
                    onLongPress: () => keyboardViewModel.startKeyRepeat('Up'),
                    onLongPressEnd: keyboardViewModel.stopKeyRepeat,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      KeyButton(
                        icon: Icons.keyboard_arrow_left,
                        label: '',
                        onPressed: () => keyboardViewModel.sendKey('Left'),
                        onLongPress: () =>
                            keyboardViewModel.startKeyRepeat('Left'),
                        onLongPressEnd: keyboardViewModel.stopKeyRepeat,
                      ),
                      const SizedBox(width: 8),
                      KeyButton(
                        icon: Icons.keyboard_arrow_down,
                        label: '',
                        onPressed: () => keyboardViewModel.sendKey('Down'),
                        onLongPress: () =>
                            keyboardViewModel.startKeyRepeat('Down'),
                        onLongPressEnd: keyboardViewModel.stopKeyRepeat,
                      ),
                      const SizedBox(width: 8),
                      KeyButton(
                        icon: Icons.keyboard_arrow_right,
                        label: '',
                        onPressed: () => keyboardViewModel.sendKey('Right'),
                        onLongPress: () =>
                            keyboardViewModel.startKeyRepeat('Right'),
                        onLongPressEnd: keyboardViewModel.stopKeyRepeat,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  KeyButton(
                    label: 'Copy',
                    onPressed: () => keyboardViewModel.sendKey('c', ctrl: true),
                  ),
                  KeyButton(
                    label: 'Paste',
                    onPressed: () => keyboardViewModel.sendKey('v', ctrl: true),
                  ),
                  KeyButton(
                    label: 'Undo',
                    onPressed: () => keyboardViewModel.sendKey('z', ctrl: true),
                  ),
                  KeyButton(
                    label: 'Save',
                    onPressed: () => keyboardViewModel.sendKey('s', ctrl: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
