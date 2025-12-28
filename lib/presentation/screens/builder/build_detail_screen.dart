import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
// AppColors removed - using theme
import '../../../data/models/build.dart';
import '../../providers/build_provider.dart';
import '../../widgets/component_card.dart';
import 'builder_screen.dart';

class BuildDetailScreen extends ConsumerStatefulWidget {
  final Build build;

  const BuildDetailScreen({
    super.key,
    required this.build,
  });

  @override
  ConsumerState<BuildDetailScreen> createState() => _BuildDetailScreenState();
}

class _BuildDetailScreenState extends ConsumerState<BuildDetailScreen> {
  late Build _currentBuild;
  bool _isLoading = false;

  // Dummy compatibility data
  final List<Map<String, dynamic>> _compatibilityIssues = [];
  final List<Map<String, dynamic>> _compatibilityWarnings = [];

  @override
  void initState() {
    super.initState();
    _currentBuild = widget.build;
    _initializeCompatibilityData();
  }

  void _initializeCompatibilityData() {
    // Generate dummy compatibility warnings
    final hasCpu = _currentBuild.components.containsKey('cpu');
    final hasGpu = _currentBuild.components.containsKey('video-card');
    final hasPsu = _currentBuild.components.containsKey('power-supply');

    if (hasGpu && _currentBuild.totalTdp != null) {
      final recommendedPsu = _currentBuild.recommendedPsuWattage;
      if (hasPsu) {
        final psuComponent = _currentBuild.components['power-supply'];
        final psuWattage = psuComponent?.specs?['wattage'] ?? 500;
        if (psuWattage < recommendedPsu) {
          _compatibilityWarnings.add({
            'type': 'warning',
            'title': 'PSU Wattage Low',
            'message':
                'Your PSU ($psuWattage W) is below the recommended $recommendedPsu W for this build.',
          });
        }
      }
    }

    if (hasCpu) {
      final cpuComponent = _currentBuild.components['cpu'];
      final cpuSocket = cpuComponent?.specs?['socket'];
      if (cpuSocket != null &&
          _currentBuild.components.containsKey('motherboard')) {
        // This would normally check actual compatibility
        _compatibilityWarnings.add({
          'type': 'info',
          'title': 'Socket Compatibility Checked',
          'message': 'CPU and Motherboard sockets are compatible.',
        });
      }
    }
  }

  Future<void> _toggleVisibility() async {
    setState(() {
      _isLoading = true;
    });

    final newVisibility =
        _currentBuild.visibility == 'public' ? 'private' : 'public';

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _currentBuild = _currentBuild.copyWith(visibility: newVisibility);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newVisibility == 'public'
                ? 'Build published to gallery'
                : 'Build is now private',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _shareBuild() async {
    final buildText = '''
${_currentBuild.name}
${_currentBuild.description ?? 'No description'}

Components:
${_currentBuild.components.entries.map((e) => '- ${e.value.name}').join('\n')}

Total Cost: \$${(_currentBuild.totalCost / 120).toStringAsFixed(2)}
Total TDP: ${_currentBuild.totalTdp ?? 0} W

Shared from RigCheck
''';

    await Clipboard.setData(ClipboardData(text: buildText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Build details copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteBuild() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Build'),
        content: Text('Are you sure you want to delete "${_currentBuild.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      final success = await ref.read(buildProvider.notifier).deleteBuild(
            _currentBuild.id ?? 0,
          );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Build deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete build'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editBuild() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuilderScreen(existingBuild: _currentBuild),
      ),
    );

    // Refresh build data after editing
    if (mounted) {
      // In a real app, you'd fetch the updated build from the provider
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Build updated'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _duplicateBuild() async {
    // Create a copy of the current build without ID (so it's treated as new)
    final duplicatedBuild = Build(
      id: null, // No ID = new build
      name: 'Copy of ${_currentBuild.name}',
      description: _currentBuild.description,
      useCase: _currentBuild.useCase,
      totalCost: _currentBuild.totalCost,
      totalTdp: _currentBuild.totalTdp,
      compatibilityStatus: _currentBuild.compatibilityStatus,
      components: Map.from(_currentBuild.components), // Copy all components
      visibility: 'private', // New copy is private by default
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuilderScreen(existingBuild: duplicatedBuild),
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Build duplicated - You can now edit and save it'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentBuild.name),
        backgroundColor: isDark ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.primary,
        foregroundColor: isDark ? Theme.of(context).colorScheme.onSurface : Colors.white,
        elevation: isDark ? 1 : 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareBuild,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editBuild();
                  break;
                case 'duplicate':
                  _duplicateBuild();
                  break;
                case 'export':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Export feature coming soon'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 12),
                    Text('Duplicate'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 12),
                    Text('Export'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Build Header Card
                  _buildHeaderCard(),

                  // Cost Breakdown
                  _buildCostBreakdown(),

                  // TDP & PSU Section
                  _buildPowerSection(),

                  // Compatibility Status
                  _buildCompatibilityStatus(),

                  // Component List
                  _buildComponentList(),

                  // Action Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          highlightColor: Colors.white,
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Container(
              height: 100,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentBuild.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (_currentBuild.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _currentBuild.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _currentBuild.visibility == 'public'
                      ? Colors.green
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _currentBuild.visibility == 'public'
                          ? Icons.public
                          : Icons.lock,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currentBuild.visibility == 'public' ? 'Public' : 'Private',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderStat(
                icon: Icons.memory,
                label: 'Components',
                value: '${_currentBuild.componentCount}',
              ),
              const SizedBox(width: 24),
              _buildHeaderStat(
                icon: Icons.calendar_today,
                label: 'Created',
                value: _formatDate(_currentBuild.createdAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostBreakdown() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Cost Breakdown',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._currentBuild.components.entries.map((entry) {
                final component = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatCategoryName(entry.key),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ),
                      Text(
                        component.priceBdt != null
                            ? '${component.priceBdt!.toStringAsFixed(0)} BDT'
                            : 'N/A',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total Cost',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  Text(
                    '\$${(_currentBuild.totalCost / 120).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Prices may vary. Check retailer websites for current pricing.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerSection() {
    final tdp = _currentBuild.totalTdp ?? 0;
    final recommendedPsu = _currentBuild.recommendedPsuWattage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.power, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Power & TDP',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPowerStat(
                      label: 'Estimated TDP',
                      value: '$tdp W',
                      icon: Icons.flash_on,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPowerStat(
                      label: 'Recommended PSU',
                      value: '$recommendedPsu W',
                      icon: Icons.power_settings_new,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'TDP is estimated. Actual power draw may vary based on usage.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPowerStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityStatus() {
    final hasErrors = _compatibilityIssues.isNotEmpty;
    final hasWarnings = _compatibilityWarnings.isNotEmpty;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (hasErrors) {
      statusColor = Theme.of(context).colorScheme.error;
      statusIcon = Icons.error;
      statusText = 'Compatibility Issues Found';
    } else if (hasWarnings) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
      statusText = 'Warnings Present';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'All Components Compatible';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user, color: statusColor),
                  const SizedBox(width: 8),
                  Text(
                    'Compatibility Status',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: statusColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            statusText,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hasErrors
                                ? '${_compatibilityIssues.length} issue(s) detected'
                                : hasWarnings
                                    ? '${_compatibilityWarnings.length} warning(s)'
                                    : 'Your build looks good!',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_compatibilityIssues.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Issues',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 8),
                ..._compatibilityIssues
                    .map((issue) => _buildCompatibilityItem(issue)),
              ],
              if (_compatibilityWarnings.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Warnings',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                ),
                const SizedBox(height: 8),
                ..._compatibilityWarnings
                    .map((warning) => _buildCompatibilityItem(warning)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompatibilityItem(Map<String, dynamic> item) {
    Color color;
    IconData icon;

    switch (item['type']) {
      case 'error':
        color = Theme.of(context).colorScheme.error;
        icon = Icons.error;
        break;
      case 'warning':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['message'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.list, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Components (${_currentBuild.componentCount})',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_currentBuild.components.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No components added yet',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._currentBuild.components.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getCategoryIcon(entry.key),
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatCategoryName(entry.key),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ComponentCard(component: entry.value),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _editBuild,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Build'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _shareBuild,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleVisibility,
                  icon: Icon(
                    _currentBuild.visibility == 'public'
                        ? Icons.lock
                        : Icons.public,
                  ),
                  label: Text(
                    _currentBuild.visibility == 'public'
                        ? 'Make Private'
                        : 'Publish to Gallery',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _currentBuild.visibility == 'public'
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _deleteBuild,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'cpu':
        return Icons.memory;
      case 'motherboard':
        return Icons.developer_board;
      case 'video-card':
        return Icons.videogame_asset;
      case 'memory':
        return Icons.sd_storage;
      case 'internal-hard-drive':
        return Icons.storage;
      case 'power-supply':
        return Icons.power;
      case 'case':
        return Icons.computer;
      case 'cpu-cooler':
        return Icons.ac_unit;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatCategoryName(String category) {
    switch (category) {
      case 'cpu':
        return 'CPU';
      case 'motherboard':
        return 'Motherboard';
      case 'video-card':
        return 'Graphics Card';
      case 'memory':
        return 'RAM';
      case 'internal-hard-drive':
        return 'Storage';
      case 'power-supply':
        return 'Power Supply';
      case 'case':
        return 'Case';
      case 'cpu-cooler':
        return 'CPU Cooler';
      default:
        return category
            .replaceAll('-', ' ')
            .split(' ')
            .map((word) => word[0].toUpperCase() + word.substring(1))
            .join(' ');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
