import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class KeyButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final VoidCallback? onLongPressEnd;
  final double? width;
  final double? height;

  const KeyButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.onLongPress,
    this.onLongPressEnd,
    this.width,
    this.height,
  });

  @override
  State<KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<KeyButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: _isPressed
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: _isPressed ? 1 : 3,
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPress: widget.onLongPress,
        onLongPressEnd: (_) {
          setState(() => _isPressed = false);
          widget.onLongPressEnd?.call();
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: AppConstants.animationDuration),
          constraints: BoxConstraints(
            minWidth: widget.width ?? AppConstants.minTapTarget,
            minHeight: widget.height ?? AppConstants.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Center(
            child: widget.icon != null
                ? Icon(
                    widget.icon,
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  )
                : Text(
                    widget.label,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}
