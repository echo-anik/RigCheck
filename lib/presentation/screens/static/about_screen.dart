import 'package:flutter/material.dart';
// AppColors removed - using theme

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About RigCheck'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App icon and name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.computer,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'RigCheck',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PC Builder & Compatibility Checker',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Mission
            _buildSection(
              context,
              'My Mission',
              'RigCheck aims to simplify the PC building process by providing '
              'an intuitive platform that helps users design, validate, and share '
              'their custom PC builds. We combine comprehensive component databases '
              'with powerful compatibility checking to ensure your dream build works perfectly.',
            ),

            // Features
            _buildSection(
              context,
              'Key Features',
              '',
              children: [
                _buildFeatureItem(Icons.build, 'Interactive PC Builder'),
                _buildFeatureItem(Icons.check_circle, 'Real-time Compatibility Checking'),
                _buildFeatureItem(Icons.compare, 'Component Comparison'),
                _buildFeatureItem(Icons.favorite, 'Wishlist Management'),
                _buildFeatureItem(Icons.view_module, 'Pre-configured Templates'),
                _buildFeatureItem(Icons.share, 'Build Sharing'),
                _buildFeatureItem(Icons.offline_bolt, 'Offline Support'),
                _buildFeatureItem(Icons.cloud_sync, 'Cloud Sync'),
              ],
            ),

            // Technology
            _buildSection(
              context,
              'Built With',
              'RigCheck is built using cutting-edge technologies including '
              'Flutter for cross-platform mobile development, ensuring a smooth '
              'and responsive experience on both Android and iOS devices.',
            ),

            // Contact
            _buildSection(
              context,
              'Get in Touch',
              'Have questions, suggestions, or feedback? We\'d love to hear from you!',
              children: [
                const SizedBox(height: 12),
                _buildContactItem(Icons.email, 'support@rigcheck.com'),
                _buildContactItem(Icons.language, 'www.rigcheck.com'),
                _buildContactItem(Icons.bug_report, 'Report an Issue'),
              ],
            ),

            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  const Text(
                    'Made with ❤️ for PC Enthusiasts',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© ${DateTime.now().year} RigCheck. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
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

  Widget _buildSection(
    BuildContext context,
    String title,
    String content, {
    List<Widget>? children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          if (content.isNotEmpty)
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          if (children != null) ...children,
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
