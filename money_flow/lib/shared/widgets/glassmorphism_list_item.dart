import 'dart:ui';

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
    this.enableSlideAnimation = true,
    this.enableHoverEffect = true,
    this.animationDelay = const Duration(milliseconds: 100),
    this.index = 0,
  });

  @override
  State<GlassmorphismListItem> createState() => _GlassmorphismListItemState();
}

class _GlassmorphismListItemState extends State<GlassmorphismListItem>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _hoverController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _hoverScaleAnimation;
  late Animation<double> _hoverBlurAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    if (widget.enableSlideAnimation) {
      _startSlideAnimation();
    }
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _hoverScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.01,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));

    _hoverBlurAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    ));
  }

  void _startSlideAnimation() {
    final delay = widget.animationDelay.inMilliseconds * widget.index;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  void _onHoverEnter() {
    if (!widget.enableHoverEffect) return;
    setState(() => _isHovered = true);
    _hoverController.forward();
  }

  void _onHoverExit() {
    if (!widget.enableHoverEffect) return;
    setState(() => _isHovered = false);
    _hoverController.reverse();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: Listenable.merge([_slideController, _hoverController]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _hoverScaleAnimation.value,
              child: Container(
                margin: widget.margin,
                child: MouseRegion(
                  onEnter: (_) => _onHoverEnter(),
                  onExit: (_) => _onHoverExit(),
                  child: GestureDetector(
                    onTap: widget.onTap,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10 + _hoverBlurAnimation.value,
                          sigmaY: 10 + _hoverBlurAnimation.value,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: widget.padding,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark ? [
                                Colors.white.withValues(alpha: _isHovered ? 0.15 : 0.1),
                                Colors.white.withValues(alpha: _isHovered ? 0.08 : 0.05),
                              ] : [
                                Colors.white.withValues(alpha: _isHovered ? 0.9 : 0.8),
                                Colors.white.withValues(alpha: _isHovered ? 0.7 : 0.6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark 
                                ? Colors.white.withValues(alpha: _isHovered ? 0.3 : 0.2)
                                : Colors.white.withValues(alpha: _isHovered ? 0.8 : 0.6),
                              width: _isHovered ? 1.5 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark 
                                  ? Colors.black.withValues(alpha: 0.2)
                                  : Colors.black.withValues(alpha: 0.08),
                                blurRadius: _isHovered ? 15 : 10,
                                offset: Offset(0, _isHovered ? 6 : 4),
                                spreadRadius: -3,
                              ),
                              if (_isHovered)
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 0),
                                  spreadRadius: 0,
                                ),
                            ],
                          ),
                          child: Row(
                            children: [
                              if (widget.leading != null) ...[
                                widget.leading!,
                                const SizedBox(width: 16),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          color: Theme.of(context).colorScheme.secondary,
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
                        ),
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

// Helper widget for creating glassmorphism list views
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
      itemBuilder: (context, index) {
        final child = children[index];
        if (child is GlassmorphismListItem) {
          return GlassmorphismListItem(
            key: child.key,
            leading: child.leading,
            title: child.title,
            subtitle: child.subtitle,
            trailing: child.trailing,
            onTap: child.onTap,
            padding: child.padding,
            margin: child.margin,
            enableSlideAnimation: child.enableSlideAnimation,
            enableHoverEffect: child.enableHoverEffect,
            animationDelay: child.animationDelay,
            index: index, // Pass the actual index
          );
        }
        return child;
      },
    );
  }
}
