import 'dart:ui';

import 'package:flutter/material.dart';

enum GlassButtonStyle {
  primary,
  secondary,
  outline,
  floating,
}

class GlassmorphismButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final GlassButtonStyle style;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double? width;
  final double? height;
  final Color? color;
  final bool enablePulseEffect;
  final bool enableRippleEffect;
  final Duration animationDuration;

  const GlassmorphismButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style = GlassButtonStyle.primary,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.borderRadius,
    this.width,
    this.height,
    this.color,
    this.enablePulseEffect = true,
    this.enableRippleEffect = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<GlassmorphismButton> createState() => _GlassmorphismButtonState();
}

class _GlassmorphismButtonState extends State<GlassmorphismButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late AnimationController _rippleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  bool _isHovered = false;
  Offset? _rippleOffset;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.enablePulseEffect) {
      _startPulseAnimation();
    }
  }

  void _setupAnimations() {
    _pressController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pressController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));
  }

  void _startPulseAnimation() {
    Future.delayed(Duration(milliseconds: widget.hashCode % 1000), () {
      if (mounted && widget.onPressed != null) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _rippleOffset = details.localPosition;
    });
    _pressController.forward();
    if (widget.enableRippleEffect) {
      _rippleController.forward();
    }
  }

  void _onTapUp() {
    _pressController.reverse();
    _rippleController.reset();
  }

  void _onTapCancel() {
    _pressController.reverse();
    _rippleController.reset();
  }

  void _onHoverEnter() {
    setState(() => _isHovered = true);
  }

  void _onHoverExit() {
    setState(() => _isHovered = false);
  }

  Color _getButtonColor() {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    return switch (widget.style) {
      GlassButtonStyle.primary => color,
      GlassButtonStyle.secondary => color.withValues(alpha: 0.7),
      GlassButtonStyle.outline => Colors.transparent,
      GlassButtonStyle.floating => color.withValues(alpha: 0.9),
    };
  }

  List<Color> _getGradientColors() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = _getButtonColor();
    
    return switch (widget.style) {
      GlassButtonStyle.primary => [
        buttonColor.withValues(alpha: isDark ? 0.8 : 0.9),
        buttonColor.withValues(alpha: isDark ? 0.6 : 0.7),
      ],
      GlassButtonStyle.secondary => [
        Colors.white.withValues(alpha: isDark ? 0.2 : 0.8),
        Colors.white.withValues(alpha: isDark ? 0.1 : 0.6),
      ],
      GlassButtonStyle.outline => [
        Colors.white.withValues(alpha: isDark ? 0.1 : 0.3),
        Colors.white.withValues(alpha: isDark ? 0.05 : 0.2),
      ],
      GlassButtonStyle.floating => [
        buttonColor.withValues(alpha: isDark ? 0.9 : 0.95),
        buttonColor.withValues(alpha: isDark ? 0.7 : 0.8),
      ],
    };
  }

  double _getBlurIntensity() {
    return switch (widget.style) {
      GlassButtonStyle.primary => 10.0,
      GlassButtonStyle.secondary => 15.0,
      GlassButtonStyle.outline => 8.0,
      GlassButtonStyle.floating => 20.0,
    };
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _pressController,
        _pulseController,
        _rippleController,
      ]),
      builder: (context, child) {
        return MouseRegion(
          onEnter: (_) => _onHoverEnter(),
          onExit: (_) => _onHoverExit(),
          child: GestureDetector(
            onTapDown: isEnabled ? _onTapDown : null,
            onTapUp: (_) => isEnabled ? _onTapUp() : null,
            onTapCancel: isEnabled ? _onTapCancel : null,
            onTap: widget.onPressed,
            child: Transform.scale(
              scale: _scaleAnimation.value * 
                     (widget.enablePulseEffect ? _pulseAnimation.value : 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: widget.width,
                height: widget.height,
                child: ClipRRect(
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: _getBlurIntensity(),
                      sigmaY: _getBlurIntensity(),
                    ),
                    child: Stack(
                      children: [
                        // Main button container
                        Container(
                          padding: widget.padding,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: _getGradientColors(),
                            ),
                            borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                            border: widget.style == GlassButtonStyle.outline
                                ? Border.all(
                                    color: (widget.color ?? Theme.of(context).colorScheme.primary)
                                        .withValues(alpha: 0.8),
                                    width: 2,
                                  )
                                : Border.all(
                                    color: isDark 
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.6),
                                    width: 1,
                                  ),
                            boxShadow: [
                              if (widget.style == GlassButtonStyle.floating) ...[
                                BoxShadow(
                                  color: (widget.color ?? Theme.of(context).colorScheme.primary)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                  spreadRadius: -3,
                                ),
                              ],
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                                blurRadius: _isHovered ? 15 : 10,
                                offset: Offset(0, _isHovered ? 6 : 4),
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: DefaultTextStyle(
                              style: TextStyle(
                                color: widget.style == GlassButtonStyle.outline
                                    ? (widget.color ?? Theme.of(context).colorScheme.primary)
                                    : Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              child: widget.child,
                            ),
                          ),
                        ),
                        
                        // Ripple effect
                        if (widget.enableRippleEffect && _rippleOffset != null)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                              child: CustomPaint(
                                painter: RipplePainter(
                                  offset: _rippleOffset!,
                                  animation: _rippleAnimation,
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        
                        // Hover glow effect
                        if (_isHovered)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
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

class RipplePainter extends CustomPainter {
  final Offset offset;
  final Animation<double> animation;
  final Color color;

  RipplePainter({
    required this.offset,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(
        alpha: ((1.0 - animation.value) * (color.a * 255.0)),
      )
      ..style = PaintingStyle.fill;

    final radius = animation.value * (size.width + size.height) * 0.5;
    canvas.drawCircle(offset, radius, paint);
  }

  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.animation.value != animation.value ||
           oldDelegate.offset != offset;
  }
}

// Helper class for easy button style access
class GlassButtonStyles {
  static const primary = GlassButtonStyle.primary;
  static const secondary = GlassButtonStyle.secondary;
  static const outline = GlassButtonStyle.outline;
  static const floating = GlassButtonStyle.floating;
}
