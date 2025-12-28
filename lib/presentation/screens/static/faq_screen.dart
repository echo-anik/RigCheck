import 'package:flutter/material.dart';
// AppColors removed - using theme

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Frequently Asked Questions'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SectionHeader('Getting Started'),
          _FAQItem(
            question: 'What is RigCheck?',
            answer: 'RigCheck is a comprehensive PC building tool that helps you select compatible components, check pricing, and create your perfect PC build. It features compatibility checking, budget tracking, and build sharing capabilities.',
          ),
          _FAQItem(
            question: 'How do I start building a PC?',
            answer: 'Simply go to the Builder tab, select components from each category (CPU, motherboard, GPU, etc.), and RigCheck will automatically check compatibility and calculate total cost. You can save your build and share it with others.',
          ),
          _FAQItem(
            question: 'Is RigCheck free to use?',
            answer: 'Yes, RigCheck is completely free to use. All features including build creation, compatibility checking, and sharing are available at no cost.',
          ),
          
          _SectionHeader('Compatibility'),
          _FAQItem(
            question: 'How does compatibility checking work?',
            answer: 'RigCheck automatically verifies that selected components work together by checking CPU socket types, RAM compatibility, power requirements, case dimensions, and other technical specifications. Any issues are flagged with detailed explanations.',
          ),
          _FAQItem(
            question: 'What if I see compatibility warnings?',
            answer: 'Compatibility warnings indicate potential issues between components. Review the warning details carefully. Some warnings are critical (components won\'t work together), while others are recommendations (like PSU wattage).',
          ),
          _FAQItem(
            question: 'Can I override compatibility warnings?',
            answer: 'Yes, you can proceed with a build despite warnings, but we strongly recommend addressing critical compatibility issues before purchasing components.',
          ),
          
          _SectionHeader('Pricing & Availability'),
          _FAQItem(
            question: 'Are prices accurate?',
            answer: 'We update prices regularly from various retailers, but they can change frequently. Always verify current pricing and availability with the retailer before purchasing.',
          ),
          _FAQItem(
            question: 'Can I purchase components through RigCheck?',
            answer: 'RigCheck is a planning and information tool. We provide links to retailers where you can purchase components, but transactions occur on their platforms.',
          ),
          _FAQItem(
            question: 'What currency are prices shown in?',
            answer: 'Prices are primarily shown in Bangladeshi Taka (৳). You can toggle to USD in the app settings for approximate conversions.',
          ),
          
          _SectionHeader('Builds & Sharing'),
          _FAQItem(
            question: 'How do I save my builds?',
            answer: 'Builds are automatically saved to your account. You can access all your saved builds from the Profile tab or Builder history.',
          ),
          _FAQItem(
            question: 'Can I share my build with others?',
            answer: 'Yes! Use the Share button on any build to generate a shareable link. You can share via social media, messaging apps, or copy the link to share anywhere.',
          ),
          _FAQItem(
            question: 'How do I export my build?',
            answer: 'Tap the export button on any build to save it as PDF, HTML, or CSV format. You can then share the file or print it for reference.',
          ),
          _FAQItem(
            question: 'What are preset builds?',
            answer: 'Preset builds are professionally curated PC configurations for common use cases (gaming, content creation, office work, etc.). They provide a great starting point that you can customize.',
          ),
          
          _SectionHeader('Features'),
          _FAQItem(
            question: 'What is the Wishlist feature?',
            answer: 'The Wishlist lets you save components you\'re interested in for later. You can track prices, compare options, and easily add wishlisted items to your builds.',
          ),
          _FAQItem(
            question: 'How does Component Comparison work?',
            answer: 'Select multiple components of the same type to see side-by-side comparisons of specifications, prices, and performance. This helps you make informed decisions.',
          ),
          _FAQItem(
            question: 'Can I use RigCheck offline?',
            answer: 'Yes, RigCheck works offline with cached data. You can view saved builds, use the builder, and check compatibility. However, price updates and new components require an internet connection.',
          ),
          
          _SectionHeader('Account & Data'),
          _FAQItem(
            question: 'Do I need an account?',
            answer: 'You can browse and use basic features without an account, but creating an account lets you save builds, sync across devices, and access the full feature set.',
          ),
          _FAQItem(
            question: 'How do I delete my account?',
            answer: 'Go to Profile > Settings > Account Settings > Delete Account. This will permanently remove all your data from our servers.',
          ),
          _FAQItem(
            question: 'Is my data secure?',
            answer: 'Yes, we take security seriously. All data is encrypted in transit and at rest. See our Privacy Policy for complete details on data handling.',
          ),
          
          _SectionHeader('Technical Issues'),
          _FAQItem(
            question: 'The app is running slowly. What can I do?',
            answer: 'Try clearing the app cache in Settings > Clear Cache. If issues persist, ensure you have the latest version installed and sufficient storage space available.',
          ),
          _FAQItem(
            question: 'I found incorrect component information. How do I report it?',
            answer: 'Use the "Report Issue" button on the component page, or contact us at support@rigcheck.app with details about the error.',
          ),
          _FAQItem(
            question: 'The app crashed. What should I do?',
            answer: 'Please report crashes via the app\'s feedback form or email support@rigcheck.app. Include details about what you were doing when it crashed.',
          ),
          
          _SectionHeader('Contact & Support'),
          _FAQItem(
            question: 'How do I contact support?',
            answer: 'Email us at support@rigcheck.app or use the Contact form in the app. We typically respond within 24-48 hours.',
          ),
          _FAQItem(
            question: 'Where can I provide feedback or suggestions?',
            answer: 'We love feedback! Use the "Send Feedback" option in Settings or email feedback@rigcheck.app. Your suggestions help us improve RigCheck.',
          ),
          _FAQItem(
            question: 'Is there a desktop version?',
            answer: 'Yes! Visit https://rigcheck.app to access the web version with all the same features plus additional tools optimized for desktop use.',
          ),
          
          const SizedBox(height: 20),
          Card(
            color: Color(0x1A667EEA),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Still have questions?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Contact us at support@rigcheck.app',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;
  
  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 12),
                Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
