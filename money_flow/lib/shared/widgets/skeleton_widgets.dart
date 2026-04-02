import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

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
          borderRadius: BorderRadius.circular(12),
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
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 180, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 120, color: Theme.of(context).colorScheme.surfaceContainerHighest),
                ],
              ),
            ),
            Container(height: 14, width: 70, color: Theme.of(context).colorScheme.surfaceContainerHighest),
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
        padding: const EdgeInsets.all(16),
        child: const Column(
          children: [
            CardSkeletonWidget(height: 120),
            SizedBox(height: 16),
            CardSkeletonWidget(height: 120),
            SizedBox(height: 16),
            CardSkeletonWidget(height: 140),
            SizedBox(height: 16),
            CardSkeletonWidget(height: 220),
          ],
        ),
      ),
    );
  }
}
