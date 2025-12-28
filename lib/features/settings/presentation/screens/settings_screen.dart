import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/permission_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../providers/app_state_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, appState, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance section
              _buildSectionHeader(context, 'Appearance'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      leading: Icon(
                        appState.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                      ),
                      title: Text(l10n.darkMode),
                      subtitle: Text(
                        appState.isDarkMode ? 'Dark theme' : 'Light theme',
                      ),
                      value: appState.isDarkMode,
                      onChanged: (value) {
                        HapticFeedback.lightImpact();
                        appState.setDarkMode(value);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Language section
              _buildSectionHeader(context, l10n.language),
              Card(
                child: Column(
                  children: [
                    _buildLanguageOption(
                      context,
                      appState,
                      const Locale('en'),
                      l10n.english,
                      '🇺🇸',
                    ),
                    const Divider(height: 1),
                    _buildLanguageOption(
                      context,
                      appState,
                      const Locale('ru'),
                      l10n.russian,
                      '🇷🇺',
                    ),
                    const Divider(height: 1),
                    _buildLanguageOption(
                      context,
                      appState,
                      const Locale('es'),
                      l10n.spanish,
                      '🇪🇸',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Permissions section
              _buildSectionHeader(context, l10n.permissions),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.folder),
                      title: Text(l10n.storagePermission),
                      subtitle: Text(l10n.storagePermissionDesc),
                      trailing: FutureBuilder<bool>(
                        future: PermissionService.hasStoragePermission(),
                        builder: (context, snapshot) {
                          final hasPermission = snapshot.data ?? false;
                          return Icon(
                            hasPermission
                                ? Icons.check_circle
                                : Icons.error_outline,
                            color: hasPermission ? Colors.green : Colors.orange,
                          );
                        },
                      ),
                      onTap: () async {
                        final granted =
                            await PermissionService.requestStoragePermission();
                        if (!granted && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Permission denied. Please grant storage permission in settings.',
                              ),
                              action: SnackBarAction(
                                label: 'Open Settings',
                                onPressed: () {
                                  PermissionService.openSettings();
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // About section
              _buildSectionHeader(context, l10n.about),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(l10n.version),
                      subtitle: const Text('1.0.0'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.code),
                      title: const Text('Developer'),
                      subtitle: const Text('Cleaner Pro Team'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.star),
                      title: const Text('Rate App'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you for your support!'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: const Text('Share App'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Sharing coming soon!'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: Text(
                  'Made with ❤️ by Cleaner Pro Team',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '© 2024 All rights reserved',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    AppStateProvider appState,
    Locale locale,
    String name,
    String flag,
  ) {
    final isSelected = appState.locale.languageCode == locale.languageCode;

    return ListTile(
      leading: Text(
        flag,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(name),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        HapticFeedback.lightImpact();
        appState.setLocale(locale);
      },
    );
  }
}
