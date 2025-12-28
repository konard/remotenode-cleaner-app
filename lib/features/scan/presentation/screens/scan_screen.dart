import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/cleaning_provider.dart';
import '../widgets/junk_category_card.dart';
import '../widgets/duplicate_group_card.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scan),
        actions: [
          Consumer<CleaningProvider>(
            builder: (context, provider, _) {
              if (provider.state == CleaningState.scanned) {
                return TextButton.icon(
                  onPressed: () {
                    provider.reset();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CleaningProvider>(
        builder: (context, cleaningProvider, _) {
          return _buildBody(context, l10n, cleaningProvider);
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider provider,
  ) {
    switch (provider.state) {
      case CleaningState.idle:
        return _buildIdleState(context, l10n, provider);
      case CleaningState.scanning:
        return _buildScanningState(context, l10n, provider);
      case CleaningState.scanned:
        return _buildScannedState(context, l10n, provider);
      case CleaningState.cleaning:
        return _buildCleaningState(context, l10n, provider);
      case CleaningState.completed:
        return _buildCompletedState(context, l10n, provider);
    }
  }

  Widget _buildIdleState(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider provider,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 64,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Start a Scan',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Scan your device for junk files, cache, and duplicates',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await provider.startScan();
                  },
                  icon: const Icon(Icons.delete_sweep),
                  label: Text(l10n.junkFiles),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    HapticFeedback.mediumImpact();
                    await provider.findDuplicates();
                  },
                  icon: const Icon(Icons.photo_library),
                  label: Text(l10n.findDuplicates),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningState(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider provider,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 80,
              lineWidth: 10,
              percent: provider.progress,
              progressColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              circularStrokeCap: CircularStrokeCap.round,
              center: Text(
                '${(provider.progress * 100).toInt()}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.scanning,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.currentTask,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedState(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider provider,
  ) {
    final theme = Theme.of(context);

    // Check if we're showing junk files or duplicates
    if (provider.duplicates.isNotEmpty) {
      return _buildDuplicatesResults(context, l10n, provider);
    }

    if (provider.junkFiles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noJunkFound,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your device is clean!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Summary card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.warningColor,
                AppTheme.warningColor.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_sweep,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FileSizeFormatter.format(provider.totalJunkSize),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      l10n.itemsFound(provider.junkFiles.length),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Select all / Deselect all
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: provider.selectAllJunk,
                child: Text(l10n.selectAll),
              ),
              TextButton(
                onPressed: provider.deselectAllJunk,
                child: Text(l10n.deselectAll),
              ),
            ],
          ),
        ),

        // Junk categories
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              if (provider.cacheSize > 0)
                JunkCategoryCard(
                  title: l10n.appCache,
                  icon: Icons.cached,
                  color: AppTheme.cacheColor,
                  size: provider.cacheSize,
                  files: provider.junkFiles
                      .where((f) => f.category == 'cache')
                      .toList(),
                  onToggle: provider.toggleJunkFile,
                ),
              if (provider.tempFilesSize > 0)
                JunkCategoryCard(
                  title: l10n.tempFiles,
                  icon: Icons.folder_delete,
                  color: AppTheme.junkColor,
                  size: provider.tempFilesSize,
                  files: provider.junkFiles
                      .where((f) => f.category == 'temp')
                      .toList(),
                  onToggle: provider.toggleJunkFile,
                ),
              if (provider.thumbnailsSize > 0)
                JunkCategoryCard(
                  title: l10n.thumbnails,
                  icon: Icons.photo_size_select_small,
                  color: AppTheme.mediaColor,
                  size: provider.thumbnailsSize,
                  files: provider.junkFiles
                      .where((f) => f.category == 'thumbnails')
                      .toList(),
                  onToggle: provider.toggleJunkFile,
                ),
              if (provider.logFilesSize > 0)
                JunkCategoryCard(
                  title: l10n.logFiles,
                  icon: Icons.description,
                  color: AppTheme.documentsColor,
                  size: provider.logFilesSize,
                  files: provider.junkFiles
                      .where((f) => f.category == 'logs')
                      .toList(),
                  onToggle: provider.toggleJunkFile,
                ),
              if (provider.residualFilesSize > 0)
                JunkCategoryCard(
                  title: l10n.residualFiles,
                  icon: Icons.folder_off,
                  color: AppTheme.otherColor,
                  size: provider.residualFilesSize,
                  files: provider.junkFiles
                      .where((f) => f.category == 'residual')
                      .toList(),
                  onToggle: provider.toggleJunkFile,
                ),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDuplicatesResults(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider provider,
  ) {
    final theme = Theme.of(context);

    if (provider.duplicates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: AppTheme.successColor,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noDuplicatesFound,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No duplicate photos or videos found',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final totalDuplicateSize = provider.duplicates.fold(
      0,
      (sum, group) => sum + group.duplicateSize,
    );

    return Column(
      children: [
        // Summary card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.mediaColor,
                AppTheme.mediaColor.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FileSizeFormatter.format(totalDuplicateSize),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${provider.duplicates.length} duplicate groups found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Duplicate groups
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: provider.duplicates.length + 1,
            itemBuilder: (context, index) {
              if (index == provider.duplicates.length) {
                return const SizedBox(height: 100); // Space for FAB
              }
              return DuplicateGroupCard(
                group: provider.duplicates[index],
                onToggleGroup: () =>
                    provider.toggleDuplicateGroup(provider.duplicates[index]),
                onToggleFile: provider.toggleDuplicateFile,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCleaningState(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider provider,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 80,
              lineWidth: 10,
              percent: provider.progress,
              progressColor: AppTheme.successColor,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              circularStrokeCap: CircularStrokeCap.round,
              center: const Icon(
                Icons.cleaning_services,
                size: 50,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.cleaning,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.currentTask,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider provider,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 80,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.cleaningComplete,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.deviceOptimized,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                provider.reset();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Scan Again'),
            ),
          ],
        ),
      ),
    );
  }
}
