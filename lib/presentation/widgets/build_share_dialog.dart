import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// AppColors removed - using theme
import '../../data/models/build.dart';
import '../../core/services/share_service.dart';

class BuildShareDialog extends StatelessWidget {
  final Build pcBuild;
  final ShareService shareService;

  const BuildShareDialog({
    super.key,
    required this.pcBuild,
    required this.shareService,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.share, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Share Build',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Share options
            _buildShareOption(
              context: context,
              icon: Icons.link,
              title: 'Share Link',
              subtitle: 'Copy shareable link',
              color: Theme.of(context).colorScheme.primary,
              onTap: () => _shareLink(context),
            ),
            const SizedBox(height: 12),

            _buildShareOption(
              context: context,
              icon: Icons.text_snippet,
              title: 'Share as Text',
              subtitle: 'Copy build summary',
              color: Colors.blue,
              onTap: () => _shareAsText(context),
            ),
            const SizedBox(height: 12),

            _buildShareOption(
              context: context,
              icon: Icons.share_outlined,
              title: 'Share via...',
              subtitle: 'Share using system share sheet',
              color: Colors.green,
              onTap: () => _shareVia(context),
            ),
            const SizedBox(height: 12),

            _buildShareOption(
              context: context,
              icon: Icons.download,
              title: 'Export as JSON',
              subtitle: 'Download build configuration',
              color: Theme.of(context).colorScheme.secondary,
              onTap: () => _exportJSON(context),
            ),
            const SizedBox(height: 12),

            _buildShareOption(
              context: context,
              icon: Icons.description,
              title: 'Export as Text',
              subtitle: 'Download detailed export',
              color: Colors.orange,
              onTap: () => _exportText(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareLink(BuildContext context) async {
    try {
      final link = _generateShareLink();
      await Clipboard.setData(ClipboardData(text: link));

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link copied to clipboard'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy link: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _shareAsText(BuildContext context) async {
    try {
      final summary = shareService.generateBuildSummary(pcBuild);
      await Clipboard.setData(ClipboardData(text: summary));

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Build summary copied to clipboard'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to copy summary: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _shareVia(BuildContext context) async {
    try {
      Navigator.pop(context);
      await shareService.shareBuildDetailed(pcBuild);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportJSON(BuildContext context) async {
    try {
      final json = jsonEncode(pcBuild.toJson());
      await Clipboard.setData(ClipboardData(text: json));

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('JSON copied to clipboard'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export JSON: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportText(BuildContext context) async {
    try {
      final exportText = shareService.generateBuildExportText(pcBuild);
      await Clipboard.setData(ClipboardData(text: exportText));

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export copied to clipboard'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  String _generateShareLink() {
    if (pcBuild.shareToken != null && pcBuild.shareToken!.isNotEmpty) {
      return 'https://rigcheck.app/build/${pcBuild.shareToken}';
    } else if (pcBuild.uuid != null) {
      return 'https://rigcheck.app/build/${pcBuild.uuid}';
    } else if (pcBuild.id != null) {
      return 'https://rigcheck.app/build/${pcBuild.id}';
    } else {
      return 'https://rigcheck.app';
    }
  }
}
