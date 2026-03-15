import 'package:flutter/material.dart';

class GlassmorphismListItem extends StatefulWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool enableSlideAnimation;
  final bool enableHoverEffect;
  final Duration animationDelay;
  final int index;

  const GlassmorphismListItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.enableSlideAnimation = false,
    this.enableHoverEffect = false,
    this.animationDelay = const Duration(milliseconds: 50),
    this.index = 0,
  });

  @override
  State<GlassmorphismListItem> createState() => _GlassmorphismListItemState();
}

class _GlassmorphismListItemState extends State<GlassmorphismListItem>
    with SingleTickerProviderStateMixin {
  AnimationController? _slideController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _fadeAnimation;
  bool _isHovered = false;
  bool _animationStarted = false;

  @override
  void initState() {
    super.initState();
    if (widget.enableSlideAnimation) {
      _setupAnimations();
    }
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeIn,
    ));
  }

  void _startAnimation() {
    if (_animationStarted || _slideController == null) return;
    _animationStarted = true;
    
    final delay = widget.animationDelay.inMilliseconds * widget.index;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _slideController?.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start animation on first build
    if (widget.enableSlideAnimation && !_animationStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    // Mismo estilo que GlassmorphismCard (medium) para que coincida con Saldo, Gastos, Cuentas
    final decoration = isDark
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                primary.withValues(alpha: 0.15),
                primary.withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: _isHovered ? 0.25 : 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          )
        : BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: _isHovered ? 0.3 : 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          );

    Widget content = Container(
      margin: widget.margin,
      padding: widget.padding,
      decoration: decoration,
      child: Row(
        children: [
          if (widget.leading != null) ...[
            widget.leading!,
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: widget.title,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    child: widget.subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: 16),
            widget.trailing!,
          ],
        ],
      ),
    );

    // Wrap with gesture detector if onTap provided
    if (widget.onTap != null) {
      content = GestureDetector(
        onTap: widget.onTap,
        child: content,
      );
    }

    // Wrap with hover effects on desktop
    if (widget.enableHoverEffect) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.01 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: content,
        ),
      );
    }

    // Wrap with slide animation if enabled
    if (widget.enableSlideAnimation && _slideController != null) {
      return AnimatedBuilder(
        animation: _slideController!,
        child: content,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation!,
            child: FadeTransition(
              opacity: _fadeAnimation!,
              child: child,
            ),
          );
        },
      );
    }

    return content;
  }
}

class GlassmorphismListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const GlassmorphismListView({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
