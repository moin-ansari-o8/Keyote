import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class ModifierToggle extends StatelessWidget {
  final String label;
  final bool isPressed;
  final VoidCallback onToggle;

  const ModifierToggle({
    super.key,
    required this.label,
    required this.isPressed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isPressed ? theme.colorScheme.primary : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: isPressed ? 4 : 2,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: AppConstants.minTapTarget,
            minHeight: AppConstants.minTapTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isPressed
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
