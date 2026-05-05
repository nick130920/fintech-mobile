import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

class CardSkeletonWidget extends StatelessWidget {
  final double height;

  const CardSkeletonWidget({super.key, this.height = 100});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.allBase,
        ),
      ),
    );
  }
}

class TransactionSkeletonWidget extends StatelessWidget {
  final int itemCount;

  const TransactionSkeletonWidget({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: AppSpacing.card,
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.step3),
        itemBuilder: (context, index) => Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: AppRadius.allSm,
              ),
            ),
            const SizedBox(width: AppSpacing.step3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 180, color: scheme.surfaceContainerHighest),
                  const SizedBox(height: AppSpacing.step2),
                  Container(height: 12, width: 120, color: scheme.surfaceContainerHighest),
                ],
              ),
            ),
            Container(height: 14, width: 70, color: scheme.surfaceContainerHighest),
          ],
        ),
      ),
    );
  }
}

class DashboardSkeletonWidget extends StatelessWidget {
  const DashboardSkeletonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: SingleChildScrollView(
        padding: AppSpacing.card,
        child: const Column(
          children: [
            CardSkeletonWidget(height: 120),
            SizedBox(height: AppSpacing.step4),
            CardSkeletonWidget(height: 120),
            SizedBox(height: AppSpacing.step4),
            CardSkeletonWidget(height: 140),
            SizedBox(height: AppSpacing.step4),
            CardSkeletonWidget(height: 220),
          ],
        ),
      ),
    );
  }
}
