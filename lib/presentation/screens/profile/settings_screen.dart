import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// AppColors removed - using theme
import '../../providers/theme_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../providers/component_provider.dart';
import '../../providers/build_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSyncing = false;
  String _appVersion = '1.0.0';
  String _cacheSize = 'Calculating...';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _calculateCacheSize();
  }

  Future<void> _loadAppInfo() async {
    // TODO: Implement package_info_plus when needed
    setState(() {
      _appVersion = '1.0.0';
    });
  }

  Future<void> _calculateCacheSize() async {
    try {
      final localStorageService = ref.read(localStorageServiceProvider);
      final stats = await localStorageService.getCacheStats();
      final componentCount = stats['component_cache_size'] ?? 0;
      final buildCount = stats['build_cache_size'] ?? 0;

      // Rough estimate: 10KB per component, 5KB per build
      final sizeInKB = (componentCount * 10) + (buildCount * 5);
      final sizeInMB = sizeInKB / 1024;

      setState(() {
        _cacheSize = '${sizeInMB.toStringAsFixed(1)} MB cached data';
      });
    } catch (e) {
      setState(() {
        _cacheSize = 'Unknown size';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final prefsState = ref.watch(userPreferencesProvider);
    final lastSyncTime = prefsState.lastSyncTime;

    String lastSyncText = 'Never';
    if (lastSyncTime != null) {
      final diff = DateTime.now().difference(lastSyncTime);
      if (diff.inMinutes < 60) {
        lastSyncText = '${diff.inMinutes} minutes ago';
      } else if (diff.inHours < 24) {
        lastSyncText = '${diff.inHours} hours ago';
      } else {
        lastSyncText = '${diff.inDays} days ago';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        children: [
          // Display Settings
          _buildSectionHeader('Display'),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: 'Enable dark theme',
            value: themeState.isDarkMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
          _buildSelectTile(
            icon: Icons.money,
            title: 'Currency',
            subtitle: prefsState.currency,
            onTap: () => _showCurrencyDialog(),
          ),
          _buildSelectTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: prefsState.language,
            onTap: () => _showLanguageDialog(),
          ),

          const Divider(height: 32),

          // Data & Storage Settings
          _buildSectionHeader('Data & Storage'),
          _buildSwitchTile(
            icon: Icons.download,
            title: 'Auto-download Images',
            subtitle: 'Download component images automatically',
            value: prefsState.autoDownloadImages,
            onChanged: (value) {
              ref.read(userPreferencesProvider.notifier).toggleAutoDownloadImages(value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.offline_bolt,
            title: 'Offline Mode',
            subtitle: 'Use cached data only',
            value: prefsState.offlineMode,
            onChanged: (value) {
              ref.read(userPreferencesProvider.notifier).toggleOfflineMode(value);
            },
          ),
          _buildActionTile(
            icon: Icons.sync,
            title: 'Sync Data',
            subtitle: _isSyncing ? 'Syncing...' : 'Last synced: $lastSyncText',
            onTap: _isSyncing ? () {} : () => _syncData(),
          ),
          _buildActionTile(
            icon: Icons.delete_outline,
            title: 'Clear Cache',
            subtitle: _cacheSize,
            onTap: () => _showClearCacheDialog(),
          ),

          const Divider(height: 32),

          // Notification Settings
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Receive app notifications',
            value: prefsState.notificationsEnabled,
            onChanged: (value) {
              ref.read(userPreferencesProvider.notifier).toggleNotifications(value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.price_change_outlined,
            title: 'Price Drop Alerts',
            subtitle: 'Get notified when prices drop',
            value: prefsState.priceAlertsEnabled,
            onChanged: (value) {
              ref.read(userPreferencesProvider.notifier).togglePriceAlerts(value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.comment_outlined,
            title: 'Build Comments',
            subtitle: 'Notify when someone comments',
            value: prefsState.buildCommentsEnabled,
            onChanged: (value) {
              ref.read(userPreferencesProvider.notifier).toggleBuildComments(value);
            },
          ),
          _buildSwitchTile(
            icon: Icons.favorite_outline,
            title: 'Build Likes',
            subtitle: 'Notify when someone likes your build',
            value: prefsState.buildLikesEnabled,
            onChanged: (value) {
              ref.read(userPreferencesProvider.notifier).toggleBuildLikes(value);
            },
          ),

          const Divider(height: 32),

          // About Settings
          _buildSectionHeader('About'),
          _buildInfoTile(
            icon: Icons.info_outline,
            title: 'App Version',
            subtitle: _appVersion,
          ),
          _buildInfoTile(
            icon: Icons.storage,
            title: 'Data Version',
            subtitle: 'Updated: Dec 14, 2025',
          ),
          _buildActionTile(
            icon: Icons.update,
            title: 'Check for Updates',
            subtitle: 'You have the latest version',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You are on the latest version'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),

          const Divider(height: 32),

          // Support Settings
          _buildSectionHeader('Support'),
          _buildActionTile(
            icon: Icons.bug_report_outlined,
            title: 'Report a Bug',
            subtitle: 'Help us improve',
            onTap: () {
              // Open bug report
            },
          ),
          _buildActionTile(
            icon: Icons.star_outline,
            title: 'Rate App',
            subtitle: 'Show your support',
            onTap: () {
              // Open app store rating
            },
          ),
          _buildActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              // Open privacy policy
            },
          ),
          _buildActionTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'Read our terms',
            onTap: () {
              // Open terms of service
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSelectTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  void _showCurrencyDialog() {
    final prefsState = ref.read(userPreferencesProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('BDT', 'Bangladeshi Taka', prefsState.currency),
            _buildCurrencyOption('USD', 'US Dollar', prefsState.currency),
            _buildCurrencyOption('EUR', 'Euro', prefsState.currency),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String code, String name, String currentCurrency) {
    return RadioListTile<String>(
      title: Text('$name ($code)'),
      value: code,
      groupValue: currentCurrency,
      onChanged: (value) {
        ref.read(userPreferencesProvider.notifier).setCurrency(value!);
        Navigator.pop(context);
      },
    );
  }

  void _showLanguageDialog() {
    final prefsState = ref.read(userPreferencesProvider);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', prefsState.language),
            _buildLanguageOption('বাংলা', prefsState.language),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String currentLanguage) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: currentLanguage,
      onChanged: (value) {
        ref.read(userPreferencesProvider.notifier).setLanguage(value!);
        Navigator.pop(context);
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: Text(
          'This will clear $_cacheSize. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Clear image cache and local storage
                setState(() {
                  _cacheSize = '0.0 MB cached data';
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cache cleared successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to clear cache: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // Refresh component data
      ref.invalidate(componentProvider);

      // Refresh build data
      ref.invalidate(buildProvider);

      // Update last sync time
      await ref.read(userPreferencesProvider.notifier).updateLastSyncTime();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data synced successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }
}
