import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/cleaning_provider.dart';
import '../../../../providers/storage_provider.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.results),
      ),
      body: Consumer2<StorageProvider, CleaningProvider>(
        builder: (context, storageProvider, cleaningProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // RAM Booster Section
                _buildRamBoosterCard(context, l10n, cleaningProvider),

                const SizedBox(height: 16),

                // Storage breakdown
                _buildStorageBreakdownCard(context, l10n, storageProvider),

                const SizedBox(height: 16),

                // Cleaning stats
                _buildCleaningStatsCard(context, l10n, cleaningProvider),

                const SizedBox(height: 16),

                // Device health
                _buildDeviceHealthCard(context, l10n, storageProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRamBoosterCard(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider provider,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.infoColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.memory,
                    color: AppTheme.infoColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.ramBooster,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (provider.ramBefore > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRamStat(
                    context,
                    l10n.ramBefore,
                    '${provider.ramBefore} MB',
                    Colors.red,
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  _buildRamStat(
                    context,
                    l10n.ramAfter,
                    '${provider.ramAfter} MB',
                    Colors.green,
                  ),
                  _buildRamStat(
                    context,
                    l10n.ramFreed,
                    '${provider.ramBefore - provider.ramAfter} MB',
                    AppTheme.successColor,
                  ),
                ],
              )
            else
              Center(
                child: Column(
                  children: [
                    Text(
                      'Tap to boost RAM',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        await provider.boostRam();
                      },
                      icon: const Icon(Icons.rocket_launch),
                      label: Text(l10n.boostRam),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRamStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStorageBreakdownCard(
    BuildContext context,
    AppLocalizations l10n,
    StorageProvider provider,
  ) {
    final theme = Theme.of(context);

    if (!provider.hasAnalyzed) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.pie_chart, size: 48),
              const SizedBox(height: 16),
              Text(
                l10n.storageAnalyzer,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => provider.analyzeStorage(),
                child: const Text('Analyze'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.pie_chart,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.storageAnalyzer,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: CircularPercentIndicator(
                radius: 80,
                lineWidth: 12,
                percent: provider.usedPercentage.clamp(0, 1),
                progressColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                circularStrokeCap: CircularStrokeCap.round,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(provider.usedPercentage * 100).toInt()}%',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.usedSpace,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...provider.categories.map((category) {
              final percent = category.bytes / provider.totalSpace;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: category.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.name,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      FileSizeFormatter.format(category.bytes),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(category.color),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCleaningStatsCard(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider provider,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.cleaning_services,
                    color: AppTheme.successColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.cleanHistory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.storage,
                    l10n.totalFreed,
                    FileSizeFormatter.format(provider.totalFreedSpace),
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    Icons.repeat,
                    l10n.cleanCount,
                    '${provider.cleanCount}',
                    AppTheme.infoColor,
                  ),
                ),
              ],
            ),
            if (provider.lastCleanDate != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.lastClean}: ${_formatDate(provider.lastCleanDate!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceHealthCard(
    BuildContext context,
    AppLocalizations l10n,
    StorageProvider provider,
  ) {
    final theme = Theme.of(context);
    final healthScore = _calculateHealthScore(provider);
    final healthColor = _getHealthColor(healthScore);
    final healthLabel = _getHealthLabel(healthScore);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: healthColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: healthColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Device Health',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 60,
                    lineWidth: 10,
                    percent: healthScore / 100,
                    progressColor: healthColor,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Text(
                      '$healthScore',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: healthColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    healthLabel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: healthColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateHealthScore(StorageProvider provider) {
    if (!provider.hasAnalyzed) return 50;

    // Base score
    int score = 100;

    // Deduct for high storage usage
    final usagePercent = provider.usedPercentage * 100;
    if (usagePercent > 90) {
      score -= 40;
    } else if (usagePercent > 80) {
      score -= 25;
    } else if (usagePercent > 70) {
      score -= 15;
    } else if (usagePercent > 60) {
      score -= 5;
    }

    // Find junk and cache categories
    for (final category in provider.categories) {
      if (category.id == 'junk') {
        final junkGB = category.bytes / (1024 * 1024 * 1024);
        if (junkGB > 2) score -= 15;
        else if (junkGB > 1) score -= 10;
        else if (junkGB > 0.5) score -= 5;
      }
      if (category.id == 'cache') {
        final cacheGB = category.bytes / (1024 * 1024 * 1024);
        if (cacheGB > 3) score -= 10;
        else if (cacheGB > 2) score -= 5;
      }
    }

    return score.clamp(0, 100);
  }

  Color _getHealthColor(int score) {
    if (score >= 80) return AppTheme.successColor;
    if (score >= 60) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  String _getHealthLabel(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    return 'Needs Attention';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
