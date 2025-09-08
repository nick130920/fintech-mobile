import 'dart:ui';

import 'package:flutter/material.dart';

enum GlassmorphismStyle {
  light,
  medium,
  heavy,
  dynamic,
}

class GlassmorphismCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final GlassmorphismStyle style;
  final bool enableHoverEffect;
  final bool enableEntryAnimation;
  final Duration animationDuration;
  final VoidCallback? onTap;
  final VoidCallback? onHover;
  final double? width;
  final double? height;
  final Color? tintColor;
  final double? customBlur;
  final double? customOpacity;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.style = GlassmorphismStyle.medium,
    this.enableHoverEffect = true,
    this.enableEntryAnimation = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.onTap,
    this.onHover,
    this.width,
    this.height,
    this.tintColor,
    this.customBlur,
    this.customOpacity,
  });

  @override
  State<GlassmorphismCard> createState() => _GlassmorphismCardState();
}

class _GlassmorphismCardState extends State<GlassmorphismCard>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _hoverController;
  late AnimationController _blurController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _hoverScaleAnimation;
  late Animation<double> _hoverBlurAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.enableEntryAnimation) {
      _startEntryAnimation();
    }
    _startBlurVariation();
  }

  void _setupAnimations() {
    // Entry Animation Controller
    _entryController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Hover Animation Controller
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Dynamic Blur Controller
    _blurController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // Entry Animations
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeInOut,
    ));

    // Hover Animations
    _hoverScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _hoverBlurAnimation = Tween<double>(
      begin: 0.0,
      end: 5.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    // Dynamic Blur Animation
    _blurAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _blurController,
      curve: Curves.easeInOut,
    ));
  }

  void _startEntryAnimation() {
    Future.delayed(Duration(milliseconds: (widget.hashCode % 300)), () {
      if (mounted) {
        _entryController.forward();
      }
    });
  }

  void _startBlurVariation() {
    _blurController.repeat(reverse: true);
  }

  void _onHoverEnter() {
    if (!widget.enableHoverEffect) return;
    setState(() => _isHovered = true);
    _hoverController.forward();
    widget.onHover?.call();
  }

  void _onHoverExit() {
    if (!widget.enableHoverEffect) return;
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  double _getBlurIntensity() {
    if (widget.customBlur != null) return widget.customBlur!;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final baseBlur = switch (widget.style) {
      GlassmorphismStyle.light => isDark ? 8.0 : 2.0,
      GlassmorphismStyle.medium => isDark ? 15.0 : 4.0,
      GlassmorphismStyle.heavy => isDark ? 25.0 : 8.0,
      GlassmorphismStyle.dynamic => isDark ? 15.0 + (_blurAnimation.value * 10.0) : 4.0 + (_blurAnimation.value * 2.0),
    };
    
    return baseBlur + _hoverBlurAnimation.value;
  }

  double _getOpacity() {
    if (widget.customOpacity != null) return widget.customOpacity!;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (widget.style) {
      GlassmorphismStyle.light => isDark ? 0.05 : 0.95,
      GlassmorphismStyle.medium => isDark ? 0.1 : 0.98,
      GlassmorphismStyle.heavy => isDark ? 0.2 : 1.0,
      GlassmorphismStyle.dynamic => isDark ? 0.1 : 0.98,
    };
  }

  List<Color> _getGradientColors() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opacity = _getOpacity();
    
    if (isDark) {
      final tint = widget.tintColor ?? Theme.of(context).colorScheme.primary;
      return [
        tint.withValues(alpha: opacity + 0.05),
        tint.withValues(alpha: opacity - 0.02),
      ];
    } else {
      // Para modo claro, usar colores más sólidos del tema
      return [
        Theme.of(context).colorScheme.surfaceContainerHighest,
        Theme.of(context).colorScheme.surfaceContainerHigh,
      ];
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _hoverController.dispose();
    _blurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entryController,
        _hoverController,
        _blurController,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value * _hoverScaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: MouseRegion(
              onEnter: (_) => _onHoverEnter(),
              onExit: (_) => _onHoverExit(),
              child: GestureDetector(
                onTap: widget.onTap,
                child: SizedBox(
                  width: widget.width,
                  height: widget.height,
                  child: ClipRRect(
                    borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _getBlurIntensity(),
                        sigmaY: _getBlurIntensity(),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: widget.padding,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _getGradientColors(),
                          ),
                          borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark 
                              ? Colors.white.withValues(alpha: 0.3 + (_hoverBlurAnimation.value * 0.1))
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2 + (_hoverBlurAnimation.value * 0.1)),
                            width: _isHovered ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark 
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.05),
                              blurRadius: isDark ? 20 + _hoverBlurAnimation.value : 8 + _hoverBlurAnimation.value,
                              offset: Offset(0, isDark ? 8 + _hoverBlurAnimation.value : 2 + _hoverBlurAnimation.value),
                              spreadRadius: isDark ? -5 : 0,
                            ),
                            if (_isHovered)
                              BoxShadow(
                                color: (widget.tintColor ?? Theme.of(context).colorScheme.primary)
                                    .withValues(alpha: isDark ? 0.2 : 0.1),
                                blurRadius: isDark ? 20 : 10,
                                offset: const Offset(0, 0),
                                spreadRadius: 0,
                              ),
                          ],
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Helper class for easy creation of different glass styles
class GlassStyles {
  static const light = GlassmorphismStyle.light;
  static const medium = GlassmorphismStyle.medium;
  static const heavy = GlassmorphismStyle.heavy;
  static const dynamic = GlassmorphismStyle.dynamic;
}
