import 'package:flutter/material.dart';
import '../const/app_colors.dart';

enum GradientButtonVariant { primary, outlined, danger, success }

class GradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final GradientButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final double fontSize;
  final Color? color;
  final Color? backgroundColor;
  

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.variant = GradientButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = 52,
    this.borderRadius = 14,
    this.fontSize = 15,
    this.color,
    this.backgroundColor,
    
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onTap == null || widget.isLoading) return;
    setState(() => _pressed = true);
    _controller.forward();
  }

  void _onTapUp(_) {
    if (!_pressed) return;
    setState(() => _pressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    if (!_pressed) return;
    setState(() => _pressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isDisabled ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.65 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: _buildButton(),
        ),
      ),
    );
  }

  Widget _buildButton() {
    switch (widget.variant) {
      case GradientButtonVariant.outlined:
        return _OutlinedVariant(widget: widget);
      case GradientButtonVariant.danger:
        return _FilledVariant(
          widget: widget,
          gradient: const LinearGradient(
            colors: [Color(0xFFE74C3C), Color(0xFFc0392b)],
          ),
        );
      case GradientButtonVariant.success:
        return _FilledVariant(
          widget: widget,
          gradient: const LinearGradient(
            colors: [Color(0xFF2ECC71), Color(0xFF27ae60)],
          ),
        );
      case GradientButtonVariant.primary:
      default:
        return _FilledVariant(
          widget: widget,
          gradient: AppColors.heroGradient,
        );
    }
  }
}

class _FilledVariant extends StatelessWidget {
  final GradientButton widget;
  final LinearGradient gradient;

  const _FilledVariant({required this.widget, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: widget.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _OutlinedVariant extends StatelessWidget {
  final GradientButton widget;
  const _OutlinedVariant({required this.widget});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all( color: widget.color ?? AppColors.primary, width: 1.8),
      ),
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.color ?? AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.color ?? AppColors.primary,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}