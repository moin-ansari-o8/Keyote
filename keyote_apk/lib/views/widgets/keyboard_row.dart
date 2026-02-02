import 'package:flutter/material.dart';

class KeyboardRow extends StatelessWidget {
  final List<Widget> keys;
  final MainAxisAlignment alignment;

  const KeyboardRow({
    super.key,
    required this.keys,
    this.alignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(mainAxisAlignment: alignment, children: keys),
    );
  }
}
