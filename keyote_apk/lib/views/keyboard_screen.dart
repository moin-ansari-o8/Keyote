import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/keyboard_viewmodel.dart';
import 'widgets/split_keyboard_layout.dart';

class KeyboardScreen extends StatefulWidget {
  const KeyboardScreen({super.key});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVm = context.watch<KeyboardViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            // Custom header with title, input preview, and controls
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: Colors.black87,
              child: Row(
                children: [
                  // Connection indicator dot
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: keyboardVm.isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: keyboardVm.isConnected
                              ? Colors.green.withOpacity(0.5)
                              : Colors.red.withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title
                  const Text(
                    'Keyote',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Input preview box (inline)
                  Expanded(
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: !keyboardVm.isConnected
                                  ? Alignment.center
                                  : Alignment.centerLeft,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Show placeholder or actual text with cursor
                                    if (!keyboardVm.isConnected)
                                      Text(
                                        'CONNECT TO SERVER..!',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      )
                                    else if (keyboardVm.inputPreview.isEmpty)
                                      Text(
                                        'Type something...',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                          fontFamily: 'monospace',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      )
                                    else ...[
                                      // Text before cursor
                                      if (keyboardVm.cursorPosition > 0)
                                        Text(
                                          keyboardVm.inputPreview.substring(
                                            0,
                                            keyboardVm.cursorPosition,
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'monospace',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.clip,
                                        ),
                                      // Cursor at position
                                      Container(
                                        width: 2,
                                        height: 16,
                                        color: Colors.white,
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                      ),
                                      // Text after cursor
                                      if (keyboardVm.cursorPosition < keyboardVm.inputPreview.length)
                                        Text(
                                          keyboardVm.inputPreview.substring(
                                            keyboardVm.cursorPosition,
                                          ),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'monospace',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.clip,
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (keyboardVm.inputPreview.isNotEmpty)
                            IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Colors.white70,
                                size: 18,
                              ),
                              onPressed: keyboardVm.clearInputPreview,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Settings button
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ),

            // Keyboard takes remaining space
            Expanded(child: const SplitKeyboardLayout()),
          ],
        ),
      ),
    );
  }
}
