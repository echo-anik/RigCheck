import 'package:flutter/material.dart';
// AppColors removed - using theme
import '../../core/services/compatibility_service.dart';

/// Reusable dialog for displaying compatibility warnings and errors
class CompatibilityWarningDialog extends StatelessWidget {
  final List<CompatibilityIssue> issues;
  final VoidCallback? onProceed;
  final VoidCallback? onFixIssues;
  final String? title;
  final String? proceedButtonText;
  final String? fixButtonText;
  final bool showProceedButton;

  const CompatibilityWarningDialog({
    super.key,
    required this.issues,
    this.onProceed,
    this.onFixIssues,
    this.title,
    this.proceedButtonText,
    this.fixButtonText,
    this.showProceedButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final errors = issues.whereType<CompatibilityError>().toList();
    final warnings = issues.whereType<CompatibilityWarning>().toList();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with icon
              Row(
                children: [
                  Icon(
                    errors.isNotEmpty
                        ? Icons.error_outline
                        : Icons.warning_amber_rounded,
                    color: errors.isNotEmpty ? Theme.of(context).colorScheme.error : Colors.orange,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title ?? _getDefaultTitle(errors.isNotEmpty),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary
              if (issues.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      if (errors.isNotEmpty) ...[
                        Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${errors.length} Error${errors.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (warnings.isNotEmpty) ...[
                          const SizedBox(width: 16),
                          Container(
                            width: 1,
                            height: 20,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(width: 16),
                        ],
                      ],
                      if (warnings.isNotEmpty) ...[
                        Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${warnings.length} Warning${warnings.length > 1 ? 's' : ''}',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Errors section
              if (errors.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Errors',
                  Icons.error,
                  Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 8),
                ...errors.map((error) => _buildIssueItem(
                      context,
                      error,
                      Theme.of(context).colorScheme.error,
                    )),
                const SizedBox(height: 16),
              ],

              // Warnings section
              if (warnings.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Warnings',
                  Icons.warning_amber,
                  Colors.orange,
                ),
                const SizedBox(height: 8),
                ...warnings.map((warning) => _buildIssueItem(
                      context,
                      warning,
                      Colors.orange,
                    )),
                const SizedBox(height: 16),
              ],

              // Info message
              if (errors.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Critical errors must be resolved for optimal system performance and stability.',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onFixIssues != null)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onFixIssues!();
                      },
                      child: Text(
                        fixButtonText ?? 'Review Build',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  if (showProceedButton)
                    ElevatedButton(
                      onPressed: errors.isEmpty
                          ? () {
                              Navigator.of(context).pop();
                              if (onProceed != null) onProceed!();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            errors.isEmpty ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Theme.of(context).colorScheme.outline,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        errors.isNotEmpty
                            ? 'Cannot Proceed'
                            : (proceedButtonText ?? 'Proceed Anyway'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  Widget _buildIssueItem(
    BuildContext context,
    CompatibilityIssue issue,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  issue.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCategoryDisplayName(issue.category),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getDefaultTitle(bool hasErrors) {
    if (hasErrors) {
      return 'Compatibility Issues Found';
    }
    return 'Compatibility Warnings';
  }

  String _getCategoryDisplayName(String category) {
    final categoryNames = {
      'socket': 'CPU Socket Compatibility',
      'memory': 'RAM Compatibility',
      'power': 'Power Supply',
      'form_factor': 'Form Factor',
      'clearance': 'Physical Clearance',
      'cooler': 'CPU Cooler Compatibility',
      'storage': 'Storage Interface',
    };

    return categoryNames[category] ?? category.toUpperCase();
  }

  /// Show the dialog with the given issues
  static Future<bool?> show(
    BuildContext context, {
    required List<CompatibilityIssue> issues,
    VoidCallback? onProceed,
    VoidCallback? onFixIssues,
    String? title,
    String? proceedButtonText,
    String? fixButtonText,
    bool showProceedButton = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CompatibilityWarningDialog(
        issues: issues,
        onProceed: onProceed,
        onFixIssues: onFixIssues,
        title: title,
        proceedButtonText: proceedButtonText,
        fixButtonText: fixButtonText,
        showProceedButton: showProceedButton,
      ),
    );
  }
}
