import 'package:flutter/material.dart';
// AppColors removed - using theme
import '../../core/services/compatibility_service.dart';
import '../../data/models/component.dart';

class CompatibilityDetailsModal extends StatelessWidget {
  final LocalCompatibilityResult compatibilityResult;
  final Map<String, Component> components;
  final int totalTdp;
  final int recommendedPsu;

  const CompatibilityDetailsModal({
    super.key,
    required this.compatibilityResult,
    required this.components,
    required this.totalTdp,
    required this.recommendedPsu,
  });

  static Future<void> show(
    BuildContext context, {
    required LocalCompatibilityResult compatibilityResult,
    required Map<String, Component> components,
    required int totalTdp,
    required int recommendedPsu,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CompatibilityDetailsModal(
        compatibilityResult: compatibilityResult,
        components: components,
        totalTdp: totalTdp,
        recommendedPsu: recommendedPsu,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compatibility Details',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusSummary(),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                // Overall Status Card
                _buildOverallStatusCard(),
                const SizedBox(height: 16),

                // TDP Summary
                _buildTdpSummaryCard(),
                const SizedBox(height: 16),

                // Errors Section
                if (compatibilityResult.errors.isNotEmpty) ...[
                  _buildSectionHeader('Errors', Icons.error, Colors.red),
                  const SizedBox(height: 8),
                  ...compatibilityResult.errors.map((error) => _buildIssueCard(
                        error,
                        isError: true,
                      )),
                  const SizedBox(height: 16),
                ],

                // Warnings Section
                if (compatibilityResult.warnings.isNotEmpty) ...[
                  _buildSectionHeader(
                      'Warnings', Icons.warning_amber, Colors.orange),
                  const SizedBox(height: 8),
                  ...compatibilityResult.warnings.map((warning) =>
                      _buildIssueCard(
                        warning,
                        isError: false,
                      )),
                  const SizedBox(height: 16),
                ],

                // All Checks Passed
                if (compatibilityResult.isValid &&
                    !compatibilityResult.hasWarnings) ...[
                  _buildAllChecksPassedCard(),
                  const SizedBox(height: 16),
                ],

                // Component Checks Summary
                _buildComponentChecksSummary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStatusCard() {
    final hasErrors = compatibilityResult.hasErrors;
    final hasWarnings = compatibilityResult.hasWarnings;

    Color statusColor;
    IconData statusIcon;
    String statusTitle;

    if (hasErrors) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusTitle = 'Build has compatibility errors';
    } else if (hasWarnings) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_amber_rounded;
      statusTitle = 'Build has warnings';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusTitle = 'All compatibility checks passed';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasErrors
                      ? 'Please fix the errors before saving'
                      : hasWarnings
                          ? 'Review warnings before saving'
                          : 'Your build is ready to save',
                  style: TextStyle(
                    fontSize: 13,
                    color: statusColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTdpSummaryCard() {
    final psu = components['power-supply'];
    final psuWattage = psu?.specs?['wattage'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Power Summary',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Total TDP', '${totalTdp}W', Colors.amber),
            const SizedBox(height: 8),
            _buildInfoRow(
                'Recommended PSU', '${recommendedPsu}W', Colors.blue),
            if (psuWattage != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                'Selected PSU',
                '${psuWattage}W',
                psuWattage >= recommendedPsu
                    ? Colors.green
                    : Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIssueCard(CompatibilityIssue issue, {required bool isError}) {
    final color = isError ? Colors.red : Colors.orange;
    final icon = isError ? Icons.error : Icons.warning_amber;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                    _getCategoryDisplayName(issue.category),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    issue.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                  if (!isError) ...[
                    const SizedBox(height: 8),
                    Text(
                      'This is a suggestion, not a requirement',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllChecksPassedCard() {
    final checksPassed = [
      'CPU-Motherboard socket compatibility',
      'RAM type compatibility',
      'PSU wattage sufficiency',
      'Case form factor compatibility',
      'GPU clearance',
      'Cooler compatibility',
      'Storage interface compatibility',
    ];

    return Card(
      color: Colors.green.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.green.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Text(
                  'All Checks Passed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...checksPassed.map((check) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.check,
                          color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          check,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentChecksSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Component Summary',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...components.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(entry.key),
                        size: 18,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getCategoryDisplayName(entry.key),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      Icon(Icons.check_circle,
                          color: Colors.green, size: 16),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black54,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _getStatusSummary() {
    final errorCount = compatibilityResult.errors.length;
    final warningCount = compatibilityResult.warnings.length;

    if (errorCount > 0 && warningCount > 0) {
      return '$errorCount error${errorCount > 1 ? 's' : ''}, $warningCount warning${warningCount > 1 ? 's' : ''}';
    } else if (errorCount > 0) {
      return '$errorCount error${errorCount > 1 ? 's' : ''} found';
    } else if (warningCount > 0) {
      return '$warningCount warning${warningCount > 1 ? 's' : ''} detected';
    } else {
      return 'No issues detected';
    }
  }

  Color _getStatusColor() {
    if (compatibilityResult.hasErrors) {
      return Colors.red;
    } else if (compatibilityResult.hasWarnings) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getCategoryDisplayName(String category) {
    final names = {
      'cpu': 'CPU',
      'motherboard': 'Motherboard',
      'video-card': 'Graphics Card',
      'memory': 'RAM',
      'internal-hard-drive': 'Storage',
      'power-supply': 'Power Supply',
      'case': 'Case',
      'cpu-cooler': 'CPU Cooler',
      'socket': 'Socket Compatibility',
      'power': 'Power Supply',
      'form_factor': 'Form Factor',
      'clearance': 'Component Clearance',
      'cooler': 'Cooler Compatibility',
      'storage': 'Storage Compatibility',
    };
    return names[category] ?? category;
  }

  IconData _getCategoryIcon(String category) {
    final icons = {
      'cpu': Icons.memory,
      'motherboard': Icons.developer_board,
      'video-card': Icons.videogame_asset,
      'memory': Icons.sd_storage,
      'internal-hard-drive': Icons.storage,
      'power-supply': Icons.power,
      'case': Icons.computer,
      'cpu-cooler': Icons.ac_unit,
    };
    return icons[category] ?? Icons.hardware;
  }
}
