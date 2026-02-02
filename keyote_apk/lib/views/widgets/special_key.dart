import 'package:flutter/material.dart';
import 'dart:async';

class SpecialKey extends StatefulWidget {
  final String label;
  final double widthMultiplier;
  final VoidCallback onPressed;
  final bool enableRepeat;
  final Color? backgroundColor;
  final Color? textColor;

  const SpecialKey({
    super.key,
    required this.label,
    this.widthMultiplier = 1.0,
    required this.onPressed,
    this.enableRepeat = false,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<SpecialKey> createState() => _SpecialKeyState();
}

class _SpecialKeyState extends State<SpecialKey>
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

    if (widget.enableRepeat) {
      _repeatTimer = Timer.periodic(
        const Duration(milliseconds: 150),
        (_) => widget.onPressed(),
      );
    }
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
    final baseSize = 50.0;
    final keyWidth = baseSize * widget.widthMultiplier;
    final bgColor = widget.backgroundColor ?? const Color(0xFFB0B0B0);
    final txtColor = widget.textColor ?? const Color(0xFF1F1F1F);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: keyWidth,
          height: baseSize,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _isPressed
                ? Color.lerp(bgColor, Colors.black, 0.1)
                : bgColor,
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
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.label.length > 6 ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: txtColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
