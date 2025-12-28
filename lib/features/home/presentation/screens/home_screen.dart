import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/file_size_formatter.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/cleaning_provider.dart';
import '../../../../providers/storage_provider.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/storage_overview_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Auto-analyze storage on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storageProvider =
          Provider.of<StorageProvider>(context, listen: false);
      if (!storageProvider.hasAnalyzed) {
        storageProvider.analyzeStorage();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startOneTapClean() async {
    final cleaningProvider =
        Provider.of<CleaningProvider>(context, listen: false);

    if (cleaningProvider.state == CleaningState.idle) {
      // Vibrate feedback
      HapticFeedback.mediumImpact();

      await cleaningProvider.startScan();
      if (mounted) {
        await cleaningProvider.startCleaning();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      body: Consumer2<StorageProvider, CleaningProvider>(
        builder: (context, storageProvider, cleaningProvider, _) {
          return RefreshIndicator(
            onRefresh: () async {
              await storageProvider.analyzeStorage();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // One-tap clean button
                  _buildCleanButton(
                    context,
                    l10n,
                    cleaningProvider,
                  ),

                  const SizedBox(height: 24),

                  // Storage overview
                  StorageOverviewCard(
                    storageProvider: storageProvider,
                  ),

                  const SizedBox(height: 16),

                  // Quick actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.delete_sweep,
                          title: l10n.junkFiles,
                          subtitle: 'Scan & Clean',
                          color: AppTheme.junkColor,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await cleaningProvider.startScan();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.memory,
                          title: l10n.ramBooster,
                          subtitle: 'Free RAM',
                          color: AppTheme.infoColor,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await cleaningProvider.boostRam();
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.photo_library,
                          title: l10n.duplicateFinder,
                          subtitle: 'Find & Delete',
                          color: AppTheme.mediaColor,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            await cleaningProvider.findDuplicates();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: QuickActionCard(
                          icon: Icons.battery_charging_full,
                          title: l10n.batterySaver,
                          subtitle: 'Optimize',
                          color: AppTheme.successColor,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showBatterySaverDialog(context, l10n);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Clean history
                  if (cleaningProvider.cleanCount > 0)
                    _buildCleanHistoryCard(context, l10n, cleaningProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCleanButton(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider cleaningProvider,
  ) {
    final theme = Theme.of(context);
    final isWorking = cleaningProvider.state == CleaningState.scanning ||
        cleaningProvider.state == CleaningState.cleaning;
    final isCompleted = cleaningProvider.state == CleaningState.completed;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = isWorking ? 1.0 : 1.0 + (_pulseController.value * 0.03);

        return Transform.scale(
          scale: scale,
          child: Container(
            height: 220,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isCompleted
                    ? [
                        AppTheme.successColor,
                        AppTheme.successColor.withValues(alpha: 0.8),
                      ]
                    : [
                        AppTheme.primaryColor,
                        AppTheme.primaryColorDark,
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isCompleted ? AppTheme.successColor : AppTheme.primaryColor)
                      .withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isWorking ? null : _startOneTapClean,
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isWorking)
                        CircularPercentIndicator(
                          radius: 50,
                          lineWidth: 6,
                          percent: cleaningProvider.progress,
                          progressColor: Colors.white,
                          backgroundColor: Colors.white24,
                          circularStrokeCap: CircularStrokeCap.round,
                          center: Icon(
                            cleaningProvider.state == CleaningState.scanning
                                ? Icons.search
                                : Icons.cleaning_services,
                            size: 40,
                            color: Colors.white,
                          ),
                        )
                      else if (isCompleted)
                        const Icon(
                          Icons.check_circle,
                          size: 80,
                          color: Colors.white,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cleaning_services,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        isWorking
                            ? (cleaningProvider.state == CleaningState.scanning
                                ? l10n.scanning
                                : l10n.cleaning)
                            : isCompleted
                                ? l10n.cleaningComplete
                                : l10n.oneTabClean,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isWorking && cleaningProvider.currentTask.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            cleaningProvider.currentTask,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      if (isCompleted)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l10n.deviceOptimized,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCleanHistoryCard(
    BuildContext context,
    AppLocalizations l10n,
    CleaningProvider cleaningProvider,
  ) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.cleanHistory,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHistoryStat(
                    context,
                    l10n.totalFreed,
                    FileSizeFormatter.format(cleaningProvider.totalFreedSpace),
                    Icons.storage,
                  ),
                ),
                Expanded(
                  child: _buildHistoryStat(
                    context,
                    l10n.cleanCount,
                    '${cleaningProvider.cleanCount}',
                    Icons.cleaning_services,
                  ),
                ),
                if (cleaningProvider.lastCleanDate != null)
                  Expanded(
                    child: _buildHistoryStat(
                      context,
                      l10n.lastClean,
                      _formatDate(cleaningProvider.lastCleanDate!),
                      Icons.calendar_today,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.colorScheme.secondary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  void _showBatterySaverDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.battery_charging_full,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(l10n.batterySaver),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.batterySaverTip),
            const SizedBox(height: 16),
            _buildBatteryTip(Icons.wifi_off, 'Turn off Wi-Fi when not in use'),
            _buildBatteryTip(
                Icons.bluetooth_disabled, 'Disable Bluetooth when idle'),
            _buildBatteryTip(
                Icons.brightness_low, 'Reduce screen brightness'),
            _buildBatteryTip(
                Icons.location_off, 'Turn off location services'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
