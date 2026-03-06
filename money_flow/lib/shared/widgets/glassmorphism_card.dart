import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum GlassmorphismStyle {
  light,
  medium,
  heavy,
  dynamic,
}

enum GlassmorphismPerformanceMode {
  adaptive,
  high,
  reduced,
}

class GlassmorphismCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final GlassmorphismStyle style;
  final GlassmorphismPerformanceMode performanceMode;
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
  final bool enableBlurAnimation;

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.style = GlassmorphismStyle.light,
    this.performanceMode = GlassmorphismPerformanceMode.reduced,
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
    this.enableBlurAnimation = false,
  });

  @override
  State<GlassmorphismCard> createState() => _GlassmorphismCardState();
}

class _GlassmorphismCardState extends State<GlassmorphismCard>
    with TickerProviderStateMixin {
  AnimationController? _entryController;
  AnimationController? _hoverController;
  AnimationController? _blurController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _hoverScaleAnimation;
  late Animation<double> _hoverBlurAnimation;

  bool _isHovered = false;
  double _performanceScale = 1.0;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.enableEntryAnimation) {
      _startEntryAnimation();
    }
    if (_blurController != null) {
      _startBlurVariation();
    }
  }

  void _setupAnimations() {
    // Entry Animations
    if (widget.enableEntryAnimation) {
      _entryController = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );

      _scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _entryController!,
        curve: Curves.elasticOut,
      ));

      _opacityAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _entryController!,
        curve: Curves.easeInOut,
      ));
    } else {
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
      _opacityAnimation = const AlwaysStoppedAnimation(1.0);
    }

    final useHoverAnimations = _canUseHover;
    if (useHoverAnimations) {
      _hoverController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );

      _hoverScaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.02,
      ).animate(CurvedAnimation(
        parent: _hoverController!,
        curve: Curves.easeInOut,
      ));

      _hoverBlurAnimation = Tween<double>(
        begin: 0.0,
        end: 5.0,
      ).animate(CurvedAnimation(
        parent: _hoverController!,
        curve: Curves.easeInOut,
      ));
    } else {
      _hoverScaleAnimation = const AlwaysStoppedAnimation(1.0);
      _hoverBlurAnimation = const AlwaysStoppedAnimation(0.0);
    }

    final shouldAnimateBlur =
        widget.enableBlurAnimation || widget.style == GlassmorphismStyle.dynamic;
    if (shouldAnimateBlur) {
      _blurController = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      );

      _blurAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _blurController!,
        curve: Curves.easeInOut,
      ));
    } else {
      _blurAnimation = const AlwaysStoppedAnimation(0.0);
    }
  }

  void _startEntryAnimation() {
    Future.delayed(Duration(milliseconds: (widget.hashCode % 300)), () {
      if (mounted) {
        _entryController?.forward();
      }
    });
  }

  void _startBlurVariation() {
    _blurController?.repeat(reverse: true);
  }

  void _onHoverEnter() {
    if (_hoverController == null) return;
    setState(() => _isHovered = true);
    _hoverController!.forward();
    widget.onHover?.call();
  }

  void _onHoverExit() {
    if (_hoverController == null) return;
    setState(() => _isHovered = false);
    _hoverController!.reverse();
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
    
    final blur = baseBlur + _hoverBlurAnimation.value;
    return blur * _performanceScale;
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
    _entryController?.dispose();
    _hoverController?.dispose();
    _blurController?.dispose();
    super.dispose();
  }

  bool get _canUseHover {
    if (!widget.enableHoverEffect) return false;
    if (kIsWeb) return true;

    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return true;
      default:
        return false;
    }
  }

  double _resolvePerformanceScale(BuildContext context) {
    switch (widget.performanceMode) {
      case GlassmorphismPerformanceMode.high:
        return 1.0;
      case GlassmorphismPerformanceMode.reduced:
        return 0.55;
      case GlassmorphismPerformanceMode.adaptive:
        final mediaQuery = MediaQuery.maybeOf(context);
        if (mediaQuery == null) return 0.8;

        if (mediaQuery.disableAnimations) {
          return 0.5;
        }

        final shortestSide = mediaQuery.size.shortestSide;
        final pixelRatio = mediaQuery.devicePixelRatio;
        final isPhone = shortestSide < 600;

        if (!isPhone) {
          return 1.0;
        }

        if (pixelRatio >= 3.3) return 0.9;
        if (pixelRatio >= 2.7) return 0.8;
        if (pixelRatio >= 2.2) return 0.7;
        return 0.6;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    _performanceScale = _resolvePerformanceScale(context);
    final useBackdropFilter = _performanceScale >= 0.6;
    final hoverContribution = _hoverBlurAnimation.value * _performanceScale;
    final borderWidth =
        (_isHovered ? 2.0 : 1.0) * (0.75 + (_performanceScale * 0.25));
    final animations = Listenable.merge([
      _scaleAnimation,
      _hoverScaleAnimation,
      _hoverBlurAnimation,
      _blurAnimation,
    ]);
    
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animations,
        child: widget.child,
        builder: (context, child) {
          Widget content = GestureDetector(
            onTap: widget.onTap,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: ClipRRect(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
                child: _GlassBody(
                  useBackdropFilter: useBackdropFilter,
                  blurBuilder: _getBlurIntensity,
                  padding: widget.padding,
                  borderRadius: widget.borderRadius,
                  gradientColors: _getGradientColors(),
                  borderColor: isDark
                      ? Colors.white.withValues(
                          alpha: 0.3 + (hoverContribution * 0.1))
                      : Theme.of(context).colorScheme.outline.withValues(
                          alpha: 0.2 + (hoverContribution * 0.1)),
                  borderWidth: borderWidth,
                  shadowColor: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.05),
                  hoverShadowColor: (widget.tintColor ??
                          Theme.of(context).colorScheme.primary)
                      .withValues(alpha: isDark ? 0.2 : 0.1),
                  baseShadowBlur: isDark ? 20 : 8,
                  baseShadowOffset: isDark ? 8 : 2,
                  baseShadowSpread: isDark ? -5 : 0,
                  performanceScale: _performanceScale,
                  hoverContribution: hoverContribution,
                  isHovered: _isHovered,
                  child: child,
                ),
              ),
            ),
          );

          if (_canUseHover) {
            content = MouseRegion(
              onEnter: (_) => _onHoverEnter(),
              onExit: (_) => _onHoverExit(),
              child: content,
            );
          }

          return Transform.scale(
            scale: _scaleAnimation.value * _hoverScaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: content,
            ),
          );
        },
      ),
    );
  }
}

class _GlassBody extends StatelessWidget {
  const _GlassBody({
    required this.useBackdropFilter,
    required this.blurBuilder,
    required this.padding,
    required this.borderRadius,
    required this.gradientColors,
    required this.borderColor,
    required this.borderWidth,
    required this.shadowColor,
    required this.hoverShadowColor,
    required this.baseShadowBlur,
    required this.baseShadowOffset,
    required this.baseShadowSpread,
    required this.performanceScale,
    required this.hoverContribution,
    required this.isHovered,
    required this.child,
  });

  final bool useBackdropFilter;
  final double Function() blurBuilder;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final List<Color> gradientColors;
  final Color borderColor;
  final double borderWidth;
  final Color shadowColor;
  final Color hoverShadowColor;
  final double baseShadowBlur;
  final double baseShadowOffset;
  final double baseShadowSpread;
  final double performanceScale;
  final double hoverContribution;
  final bool isHovered;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final shadowScale = 0.65 + (performanceScale * 0.35);
    final currentChild = child ?? const SizedBox.shrink();
    final body = Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: (baseShadowBlur * shadowScale) + hoverContribution,
            offset: Offset(
              0,
              (baseShadowOffset * shadowScale) + hoverContribution,
            ),
            spreadRadius: baseShadowSpread == 0
                ? 0
                : baseShadowSpread * shadowScale.clamp(0.6, 1.0),
          ),
          if (isHovered)
            BoxShadow(
              color: hoverShadowColor,
              blurRadius: 12 * shadowScale,
              offset: const Offset(0, 0),
              spreadRadius: 0,
            ),
        ],
      ),
      child: currentChild,
    );

    if (!useBackdropFilter) {
      return body;
    }

    final blurValue = blurBuilder();
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: blurValue,
        sigmaY: blurValue,
      ),
      child: body,
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
