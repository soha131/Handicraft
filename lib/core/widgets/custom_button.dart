import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isOutline;
  final bool isGradient;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.isOutline = false,
    this.isGradient = false,
    this.icon,
    this.width,
    this.height = 54,
    this.borderRadius = 27, // Capsule styling by default
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.value = 1.0;
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _animController.reverse();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _animController.forward();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _animController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color getBgColor() {
      if (widget.onPressed == null) return isDark ? Colors.grey[800]! : Colors.grey[300]!;
      if (widget.isSecondary) return AppColors.secondary;
      return AppColors.primary;
    }

    Color getTextColor() {
      if (widget.onPressed == null) return isDark ? Colors.grey[600]! : Colors.grey[500]!;
      if (widget.isOutline) {
        return widget.isSecondary ? AppColors.secondary : AppColors.primary;
      }
      return Colors.white;
    }

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: (widget.isGradient && !widget.isOutline && widget.onPressed != null)
                  ? AppColors.artisanGradient
                  : null,
              color: (widget.isGradient && !widget.isOutline && widget.onPressed != null)
                  ? null
                  : (widget.isOutline ? Colors.transparent : getBgColor()),
              border: widget.isOutline
                  ? Border.all(
                      color: widget.isSecondary ? AppColors.secondary : AppColors.primary,
                      width: 1.5,
                    )
                  : null,
              boxShadow: (widget.onPressed != null && !widget.isOutline)
                  ? [
                      BoxShadow(
                        color: (widget.isSecondary ? AppColors.secondary : AppColors.primary)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: getTextColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: getTextColor(),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
