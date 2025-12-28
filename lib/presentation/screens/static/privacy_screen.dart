import 'package:flutter/material.dart';
// AppColors removed - using theme

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle('Last Updated: January 2025'),
            const SizedBox(height: 20),
            
            const _SectionTitle('1. Information We Collect'),
            const SizedBox(height: 12),
            const _Paragraph(
              'RigCheck collects minimal information to provide you with our PC building services:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('Account information (email, username)'),
            const _BulletPoint('Your saved PC builds and component selections'),
            const _BulletPoint('Wishlist and comparison data'),
            const _BulletPoint('Usage analytics (anonymized)'),
            const SizedBox(height: 20),
            
            const _SectionTitle('2. How We Use Your Information'),
            const SizedBox(height: 12),
            const _Paragraph(
              'We use the collected information to:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('Provide and improve our PC building services'),
            const _BulletPoint('Save your builds and preferences'),
            const _BulletPoint('Send important service updates'),
            const _BulletPoint('Analyze app usage to improve user experience'),
            const SizedBox(height: 20),
            
            const _SectionTitle('3. Data Storage and Security'),
            const SizedBox(height: 12),
            const _Paragraph(
              'Your data is stored securely using industry-standard encryption. We store:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('Account data on our secure servers'),
            const _BulletPoint('Build data locally on your device and in cloud backup'),
            const _BulletPoint('Preferences and settings locally on your device'),
            const SizedBox(height: 20),
            
            const _SectionTitle('4. Data Sharing'),
            const SizedBox(height: 12),
            const _Paragraph(
              'We do not sell or share your personal information with third parties. We only share data:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('When you explicitly choose to share your builds publicly'),
            const _BulletPoint('With service providers who help us operate the app'),
            const _BulletPoint('When required by law or to protect our rights'),
            const SizedBox(height: 20),
            
            const _SectionTitle('5. Your Rights'),
            const SizedBox(height: 12),
            const _Paragraph(
              'You have the right to:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('Access your personal data'),
            const _BulletPoint('Request deletion of your account and data'),
            const _BulletPoint('Export your builds and data'),
            const _BulletPoint('Opt-out of analytics tracking'),
            const SizedBox(height: 20),
            
            const _SectionTitle('6. Cookies and Tracking'),
            const SizedBox(height: 12),
            const _Paragraph(
              'We use cookies and similar technologies to enhance your experience and analyze app usage. You can control cookie preferences in your device settings.'
            ),
            const SizedBox(height: 20),
            
            const _SectionTitle('7. Children\'s Privacy'),
            const SizedBox(height: 12),
            const _Paragraph(
              'RigCheck is not intended for children under 13. We do not knowingly collect information from children under 13 years of age.'
            ),
            const SizedBox(height: 20),
            
            const _SectionTitle('8. Changes to Privacy Policy'),
            const SizedBox(height: 12),
            const _Paragraph(
              'We may update this privacy policy from time to time. We will notify you of any significant changes through the app or via email.'
            ),
            const SizedBox(height: 20),
            
            const _SectionTitle('9. Contact Us'),
            const SizedBox(height: 12),
            const _Paragraph(
              'If you have questions about this privacy policy or your data, please contact us at:'
            ),
            const SizedBox(height: 8),
            const _Paragraph('Email: privacy@rigcheck.app'),
            const _Paragraph('Website: https://rigcheck.app/privacy'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;
  
  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
