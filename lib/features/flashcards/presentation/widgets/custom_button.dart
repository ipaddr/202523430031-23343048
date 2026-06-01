import "package:flutter/material.dart";

class CustomButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: widget.backgroundColor ?? theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onHighlightChanged: (value) {
            if (isEnabled) {
              setState(() => _pressed = value);
            }
          },
          onTap: isEnabled ? widget.onPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.foregroundColor ?? theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                else if (widget.icon != null)
                  Icon(
                    widget.icon,
                    size: 20,
                    color:
                        widget.foregroundColor ?? theme.colorScheme.onPrimary,
                  ),
                if (widget.isLoading || widget.icon != null)
                  const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color:
                        widget.foregroundColor ?? theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
