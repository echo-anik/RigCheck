import 'package:flutter/material.dart';
// AppColors removed - using theme

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
            
            const _SectionTitle('1. Acceptance of Terms'),
            const SizedBox(height: 12),
            const _Paragraph(
              'By accessing and using RigCheck ("the App"), you accept and agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the App.'
            ),
            const SizedBox(height: 20),
            
            const _SectionTitle('2. Description of Service'),
            const SizedBox(height: 12),
            const _Paragraph(
              'RigCheck is a PC building and compatibility checking application that provides:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('PC component database and pricing information'),
            const _BulletPoint('Build creation and management tools'),
            const _BulletPoint('Compatibility verification between components'),
            const _BulletPoint('Build sharing and export features'),
            const _BulletPoint('Component comparison and wishlist features'),
            const SizedBox(height: 20),
            
            const _SectionTitle('3. User Responsibilities'),
            const SizedBox(height: 12),
            const _Paragraph(
              'As a user of RigCheck, you agree to:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('Provide accurate account information'),
            const _BulletPoint('Maintain the security of your account credentials'),
            const _BulletPoint('Not use the App for any illegal purposes'),
            const _BulletPoint('Not attempt to hack, reverse engineer, or disrupt the App'),
            const _BulletPoint('Respect intellectual property rights'),
            const SizedBox(height: 20),
            
            const _SectionTitle('4. Pricing and Availability'),
            const SizedBox(height: 12),
            const _Paragraph(
              'Component pricing and availability information is provided for reference only. We strive to keep information accurate, but:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('Prices may change without notice'),
            const _BulletPoint('Availability is not guaranteed'),
            const _BulletPoint('Actual prices may vary from displayed prices'),
            const _BulletPoint('We are not responsible for pricing errors'),
            const SizedBox(height: 20),
            
            const _SectionTitle('5. Compatibility Information'),
            const SizedBox(height: 12),
            const _Paragraph(
              'While we make every effort to provide accurate compatibility information:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('Compatibility checks are automated and may contain errors'),
            const _BulletPoint('You should verify compatibility before purchasing components'),
            const _BulletPoint('We are not responsible for component incompatibilities'),
            const _BulletPoint('Always consult manufacturer specifications'),
            const SizedBox(height: 20),
            
            const _SectionTitle('6. User Content'),
            const SizedBox(height: 12),
            const _Paragraph(
              'When you share builds or content through RigCheck:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('You retain ownership of your content'),
            const _BulletPoint('You grant us license to display and share your public builds'),
            const _BulletPoint('You are responsible for the content you share'),
            const _BulletPoint('We may remove inappropriate or violating content'),
            const SizedBox(height: 20),
            
            const _SectionTitle('7. Intellectual Property'),
            const SizedBox(height: 12),
            const _Paragraph(
              'The App and its original content, features, and functionality are owned by RigCheck and are protected by international copyright, trademark, and other intellectual property laws.'
            ),
            const SizedBox(height: 20),
            
            const _SectionTitle('8. Limitation of Liability'),
            const SizedBox(height: 12),
            const _Paragraph(
              'RigCheck and its affiliates shall not be liable for:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('Any indirect, incidental, or consequential damages'),
            const _BulletPoint('Loss of data or profits'),
            const _BulletPoint('Component compatibility issues'),
            const _BulletPoint('Pricing discrepancies or errors'),
            const _BulletPoint('Third-party product defects or issues'),
            const SizedBox(height: 20),
            
            const _SectionTitle('9. Disclaimer of Warranties'),
            const SizedBox(height: 12),
            const _Paragraph(
              'The App is provided "AS IS" and "AS AVAILABLE" without warranties of any kind, either express or implied. We do not warrant that the App will be uninterrupted, error-free, or secure.'
            ),
            const SizedBox(height: 20),
            
            const _SectionTitle('10. Account Termination'),
            const SizedBox(height: 12),
            const _Paragraph(
              'We reserve the right to suspend or terminate your account if:'
            ),
            const SizedBox(height: 8),
            const _BulletPoint('You violate these Terms of Service'),
            const _BulletPoint('You engage in fraudulent activities'),
            const _BulletPoint('Your account is inactive for extended periods'),
            const _BulletPoint('Required by law or regulatory authorities'),
            const SizedBox(height: 20),
            
            const _SectionTitle('11. Changes to Terms'),
            const SizedBox(height: 12),
            const _Paragraph(
              'We reserve the right to modify these terms at any time. We will notify users of significant changes. Continued use of the App after changes constitutes acceptance of the new terms.'
            ),
            const SizedBox(height: 20),
            
            const _SectionTitle('12. Governing Law'),
            const SizedBox(height: 12),
            const _Paragraph(
              'These Terms shall be governed by and construed in accordance with the laws of Bangladesh, without regard to its conflict of law provisions.'
            ),
            const SizedBox(height: 20),
            
            const _SectionTitle('13. Contact Information'),
            const SizedBox(height: 12),
            const _Paragraph(
              'For questions about these Terms of Service, contact us at:'
            ),
            const SizedBox(height: 8),
            const _Paragraph('Email: legal@rigcheck.app'),
            const _Paragraph('Website: https://rigcheck.app/terms'),
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
