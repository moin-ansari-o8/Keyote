import 'package:flutter/material.dart';

class DualCharKey extends StatefulWidget {
  final String primary;
  final String secondary;
  final double widthMultiplier;
  final VoidCallback onPressed;
  final bool shiftActive;

  const DualCharKey({
    super.key,
    required this.primary,
    required this.secondary,
    this.widthMultiplier = 1.0,
    required this.onPressed,
    this.shiftActive = false,
  });

  @override
  State<DualCharKey> createState() => _DualCharKeyState();
}

class _DualCharKeyState extends State<DualCharKey>
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
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
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
            color: _isPressed
                ? const Color(0xFFD0D0D0)
                : const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black.withOpacity(0.1)),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              // Secondary character (top-right)
              Positioned(
                top: 4,
                right: 6,
                child: Text(
                  widget.secondary,
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.shiftActive
                        ? const Color(0xFF2196F3)
                        : const Color(0xFF1F1F1F).withOpacity(0.6),
                    fontWeight: widget.shiftActive
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              // Primary character (center-bottom)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    widget.primary,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.shiftActive
                          ? const Color(0xFF1F1F1F).withOpacity(0.6)
                          : const Color(0xFF1F1F1F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
