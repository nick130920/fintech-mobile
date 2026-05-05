import 'package:flutter/material.dart';

import '../../../../core/services/preferences_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/money_flow_logo.dart';
import '../../data/models/onboarding_page.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<OnboardingPageModel> _pages;

  @override
  void initState() {
    super.initState();
    _pages = OnboardingData.getPages(onComplete: widget.onComplete);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppMotion.medium,
        curve: AppMotion.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppMotion.medium,
        curve: AppMotion.easeInOut,
      );
    }
  }

  void _skipToEnd() {
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPadding,
        vertical: AppSpacing.inlineGap,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _currentPage > 0 ? _previousPage : null,
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: _currentPage > 0
                  ? AppColors.slate100
                  : Colors.transparent,
              foregroundColor: _currentPage > 0
                  ? AppColors.slate800
                  : AppColors.slate300,
              disabledForegroundColor: AppColors.slate300,
            ),
          ),
          const MoneyFlowLogo(size: 40, showText: false),
          TextButton(
            onPressed: _skipToEnd,
            child: Text(
              'Saltar',
              style: AppTypography.labelLg.copyWith(
                color: AppColors.slate600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPageModel page) {
    return SingleChildScrollView(
      padding: AppSpacing.horizontalScreen,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.step7),
          page.illustration,
          const SizedBox(height: AppSpacing.step7),
          Text(
            page.title,
            style: AppTypography.displaySm.copyWith(
              color: AppColors.slate900,
              fontWeight: FontWeight.w700,
              height: 1.2,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.step4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              page.description,
              style: AppTypography.bodyLg.copyWith(
                color: AppColors.slate600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: AppSpacing.screen,
      child: Column(
        children: [
          _buildPageIndicator(),
          const SizedBox(height: AppSpacing.step5),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 8,
                shadowColor: AppColors.primary.withValues(alpha: 0.3),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.allBase,
                ),
                textStyle: AppTypography.titleMd.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              child: Text(_pages[_currentPage].buttonText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _pages.length,
        (index) => AnimatedContainer(
          duration: AppMotion.medium,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.step1),
          width: _currentPage == index ? 32 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? AppColors.primary
                : AppColors.slate300,
            borderRadius: AppRadius.allXs,
          ),
        ),
      ),
    );
  }
}

class OnboardingWrapper extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingWrapper({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  void _checkOnboardingStatus() async {
    final isCompleted = await PreferencesService.isOnboardingCompleted();
    setState(() {
      _showOnboarding = !isCompleted;
    });

    if (isCompleted) {
      widget.onComplete();
    }
  }

  void _completeOnboarding() async {
    await PreferencesService.setOnboardingCompleted(true);
    await PreferencesService.setFirstLaunch(false);
    setState(() {
      _showOnboarding = false;
    });
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(onComplete: _completeOnboarding);
    } else {
      widget.onComplete();
      return const SizedBox.shrink();
    }
  }
}
