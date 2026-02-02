import 'package:flutter/material.dart';

class ModifierKey extends StatefulWidget {
  final String label;
  final bool isActive;
  final Function(bool) onStateChange;
  final double widthMultiplier;

  const ModifierKey({
    super.key,
    required this.label,
    required this.isActive,
    required this.onStateChange,
    this.widthMultiplier = 1.0,
  });

  @override
  State<ModifierKey> createState() => _ModifierKeyState();
}

class _ModifierKeyState extends State<ModifierKey>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

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
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
    widget.onStateChange(true);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onStateChange(false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onStateChange(false);
  }

  @override
  Widget build(BuildContext context) {
    final baseSize = 50.0;
    final keyWidth = baseSize * widget.widthMultiplier;

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
            color: _isPressed || widget.isActive
                ? const Color(0xFF1976D2)
                : const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: widget.isActive
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.1),
              width: widget.isActive ? 2 : 1,
            ),
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
              widget.label.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
