import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

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
    this.padding = AppSpacing.card,
    this.margin = const EdgeInsets.only(bottom: AppSpacing.step3),
    this.enableSlideAnimation = false,
    this.enableHoverEffect = false,
    this.animationDelay = AppMotion.listItemStagger,
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
      duration: AppMotion.listItemSlideIn,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: AppMotion.listItemStartOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: AppMotion.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: AppMotion.easeIn,
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
    if (widget.enableSlideAnimation && !_animationStarted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startAnimation());
    }

    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    final primary = scheme.primary;

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
            borderRadius: AppRadius.allLg,
            border: Border.all(
              color: AppColors.white.withValues(alpha: _isHovered ? 0.25 : 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.2),
                blurRadius: AppSpacing.step2,
                offset: const Offset(0, 2),
              ),
            ],
          )
        : BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: AppRadius.allLg,
            border: Border.all(
              color: scheme.outline.withValues(alpha: _isHovered ? 0.3 : 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.05),
                blurRadius: AppSpacing.step2,
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
            const SizedBox(width: AppSpacing.step4),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle(
                  style: AppTypography.titleSm.copyWith(color: scheme.onSurface),
                  child: widget.title,
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: AppSpacing.step1),
                  DefaultTextStyle(
                    style: AppTypography.bodyMd.copyWith(
                      color: scheme.onSurface.withValues(alpha: 0.7),
                    ),
                    child: widget.subtitle!,
                  ),
                ],
              ],
            ),
          ),
          if (widget.trailing != null) ...[
            const SizedBox(width: AppSpacing.step4),
            widget.trailing!,
          ],
        ],
      ),
    );

    if (widget.onTap != null) {
      content = GestureDetector(
        onTap: widget.onTap,
        child: content,
      );
    }

    if (widget.enableHoverEffect) {
      content = MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? AppMotion.hoverLiftListScale : 1.0,
          duration: AppMotion.hoverLiftList,
          child: content,
        ),
      );
    }

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
    this.padding = AppSpacing.card,
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
