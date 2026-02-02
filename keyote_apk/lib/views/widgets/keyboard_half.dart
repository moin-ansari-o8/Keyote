import 'package:flutter/material.dart';

class KeyboardHalf extends StatelessWidget {
  final List<Widget> rows;
  final String side; // 'left' or 'right'

  const KeyboardHalf({super.key, required this.rows, required this.side});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: side == 'left'
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: rows,
      ),
    );
  }
}
