import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum GlassmorphismStyle {
  light,
  medium,
  heavy,
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

  const GlassmorphismCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius,
    this.style = GlassmorphismStyle.light,
    this.performanceMode = GlassmorphismPerformanceMode.reduced,
    this.enableHoverEffect = false,
    this.enableEntryAnimation = false,
    this.animationDuration = const Duration(milliseconds: 400),
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
    with SingleTickerProviderStateMixin {
  AnimationController? _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isHovered = false;
  late double _performanceScale;
  late bool _useBackdropFilter;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _performanceScale = _resolvePerformanceScale(context);
    _useBackdropFilter = _performanceScale >= 0.6;
  }

  void _setupAnimations() {
    if (widget.enableEntryAnimation) {
      _entryController = AnimationController(
        duration: widget.animationDuration,
        vsync: this,
      );

      _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
        CurvedAnimation(parent: _entryController!, curve: Curves.easeOut),
      );

      _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _entryController!, curve: Curves.easeIn),
      );

      // Start animation after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _entryController?.forward();
      });
    } else {
      _scaleAnimation = const AlwaysStoppedAnimation(1.0);
      _opacityAnimation = const AlwaysStoppedAnimation(1.0);
    }
  }

  void _onHoverEnter() {
    if (!widget.enableHoverEffect || !_canUseHover) return;
    setState(() => _isHovered = true);
    widget.onHover?.call();
  }

  void _onHoverExit() {
    if (!widget.enableHoverEffect || !_canUseHover) return;
    setState(() => _isHovered = false);
  }

  double _getBlurIntensity() {
    if (widget.customBlur != null) return widget.customBlur!;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final baseBlur = switch (widget.style) {
      GlassmorphismStyle.light => isDark ? 8.0 : 2.0,
      GlassmorphismStyle.medium => isDark ? 15.0 : 4.0,
      GlassmorphismStyle.heavy => isDark ? 25.0 : 8.0,
    };
    
    return baseBlur * _performanceScale;
  }

  double _getOpacity() {
    if (widget.customOpacity != null) return widget.customOpacity!;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (widget.style) {
      GlassmorphismStyle.light => isDark ? 0.05 : 0.95,
      GlassmorphismStyle.medium => isDark ? 0.1 : 0.98,
      GlassmorphismStyle.heavy => isDark ? 0.2 : 1.0,
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
      return [
        Theme.of(context).colorScheme.surfaceContainerHighest,
        Theme.of(context).colorScheme.surfaceContainerHigh,
      ];
    }
  }

  @override
  void dispose() {
    _entryController?.dispose();
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
        return 0.5;
      case GlassmorphismPerformanceMode.adaptive:
        final mediaQuery = MediaQuery.maybeOf(context);
        if (mediaQuery == null) return 0.6;

        if (mediaQuery.disableAnimations) return 0.4;

        final shortestSide = mediaQuery.size.shortestSide;
        final isPhone = shortestSide < 600;

        return isPhone ? 0.6 : 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(16);
    final blurValue = _getBlurIntensity();
    final gradientColors = _getGradientColors();
    
    final borderColor = isDark
        ? Colors.white.withValues(alpha: _isHovered ? 0.4 : 0.3)
        : Theme.of(context).colorScheme.outline.withValues(alpha: _isHovered ? 0.3 : 0.2);
    
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.05);

    Widget card = Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor,
          width: _isHovered ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: isDark ? 12 : 6,
            offset: Offset(0, isDark ? 4 : 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: _useBackdropFilter && isDark
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue),
                child: Padding(
                  padding: widget.padding ?? EdgeInsets.zero,
                  child: widget.child,
                ),
              )
            : Padding(
                padding: widget.padding ?? EdgeInsets.zero,
                child: widget.child,
              ),
      ),
    );

    // Wrap with GestureDetector if onTap is provided
    if (widget.onTap != null) {
      card = GestureDetector(
        onTap: widget.onTap,
        child: card,
      );
    }

    // Wrap with MouseRegion for hover effects on desktop
    if (_canUseHover) {
      card = MouseRegion(
        onEnter: (_) => _onHoverEnter(),
        onExit: (_) => _onHoverExit(),
        child: AnimatedScale(
          scale: _isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: card,
        ),
      );
    }

    // Wrap with entry animation if enabled
    if (widget.enableEntryAnimation && _entryController != null) {
      return AnimatedBuilder(
        animation: _entryController!,
        child: card,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
      );
    }

    return card;
  }
}

// Helper class for easy creation of different glass styles
class GlassStyles {
  static const light = GlassmorphismStyle.light;
  static const medium = GlassmorphismStyle.medium;
  static const heavy = GlassmorphismStyle.heavy;
}
