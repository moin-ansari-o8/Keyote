import 'package:flutter/material.dart';
import 'dart:async';

class ArrowKey extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const ArrowKey({super.key, required this.icon, required this.onPressed});

  @override
  State<ArrowKey> createState() => _ArrowKeyState();
}

class _ArrowKeyState extends State<ArrowKey>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  Timer? _repeatTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    widget.onPressed();

    _repeatTimer = Timer.periodic(
      const Duration(milliseconds: 100),
      (_) => widget.onPressed(),
    );
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    _repeatTimer?.cancel();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
    _repeatTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color(0xFFE67E00)
                : const Color(0xFFFF9800),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
