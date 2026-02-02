import 'package:flutter/material.dart';
import 'widgets/connection_indicator.dart';
import 'widgets/split_keyboard_layout.dart';

class KeyboardScreen extends StatelessWidget {
  const KeyboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyote Remote'),
        centerTitle: true,
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[900],
        child: SafeArea(
          child: Column(
            children: [
              // Connection indicator at top
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const ConnectionIndicator(),
              ),

              // Keyboard takes remaining space
              Expanded(child: Center(child: const SplitKeyboardLayout())),
            ],
          ),
        ),
      ),
    );
  }
}
