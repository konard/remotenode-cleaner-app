import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../core/utils/file_size_formatter.dart';
import '../../../../providers/storage_provider.dart';

class StorageOverviewCard extends StatelessWidget {
  final StorageProvider storageProvider;

  const StorageOverviewCard({
    super.key,
    required this.storageProvider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (storageProvider.isAnalyzing) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Analyzing storage...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (!storageProvider.hasAnalyzed) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.storage,
                size: 48,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Tap to analyze storage',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Storage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Storage bar
            LinearPercentIndicator(
              lineHeight: 12,
              percent: storageProvider.usedPercentage.clamp(0, 1),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              linearGradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
              barRadius: const Radius.circular(6),
              padding: EdgeInsets.zero,
            ),

            const SizedBox(height: 12),

            // Storage stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStorageStat(
                  context,
                  'Used',
                  FileSizeFormatter.format(storageProvider.usedSpace),
                  theme.colorScheme.primary,
                ),
                _buildStorageStat(
                  context,
                  'Free',
                  FileSizeFormatter.format(storageProvider.freeSpace),
                  theme.colorScheme.secondary,
                ),
                _buildStorageStat(
                  context,
                  'Total',
                  FileSizeFormatter.format(storageProvider.totalSpace),
                  theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Categories
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: storageProvider.categories.take(6).map((category) {
                return _buildCategoryChip(
                  context,
                  category.name,
                  FileSizeFormatter.formatShort(category.bytes),
                  category.color,
                  category.icon,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    String size,
    Color color,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            '$label: $size',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
