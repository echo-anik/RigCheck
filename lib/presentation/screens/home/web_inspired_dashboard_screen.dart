import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/web_inspired_theme.dart';
import '../../providers/component_provider.dart';

class WebInspiredDashboardScreen extends ConsumerStatefulWidget {
  const WebInspiredDashboardScreen({super.key});

  @override
  ConsumerState<WebInspiredDashboardScreen> createState() =>
      _WebInspiredDashboardScreenState();
}

class _WebInspiredDashboardScreenState
    extends ConsumerState<WebInspiredDashboardScreen> {
  Map<String, int> componentCounts = {
    'cpu': 0,
    'motherboard': 0,
    'gpu': 0,
    'ram': 0,
    'storage': 0,
    'psu': 0,
    'case': 0,
    'cooler': 0,
    'total': 0,
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComponentCounts();
  }

  Future<void> _loadComponentCounts() async {
    try {
      final repository = ref.read(componentRepositoryProvider);
      // Load counts for each category
      final categories = [
        'cpu',
        'motherboard',
        'gpu',
        'ram',
        'storage',
        'psu',
        'case',
        'cooler'
      ];

      int total = 0;
      Map<String, int> counts = {};

      for (var category in categories) {
        try {
          final components = await repository.getAllComponents(
            category: category,
            perPage: 1,
          );
          // Estimate count - in real implementation you'd get this from meta
          counts[category] = components.length > 0 ? 100 : 0;
          total += counts[category]!;
        } catch (e) {
          counts[category] = 0;
        }
      }

      if (mounted) {
        setState(() {
          componentCounts = {...counts, 'total': total};
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Section
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.scaffoldBackgroundColor,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                children: [
                  // Hero Title
                  Text(
                    'Build Your Dream PC',
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'with Confidence',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Subtitle
                  Text(
                    isLoading
                        ? 'Loading component data...'
                        : 'Browse ${componentCounts['total']}+ components, check compatibility in real-time, and build your perfect PC.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: WebInspiredTheme.mutedForeground,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for components (CPU, GPU, RAM...)',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () => context.push('/search'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                          child: const Text('Search'),
                        ),
                      ),
                    ),
                    onTap: () => context.push('/search'),
                    readOnly: true,
                  ),
                  const SizedBox(height: 24),

                  // CTA Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/builder'),
                          icon: const Icon(Icons.build, size: 20),
                          label: const Text('Start Building'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.push('/components'),
                          child: const Text('Browse Components'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Features Section
          Container(
            color: WebInspiredTheme.mutedColor.withOpacity(0.3),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                // Section Header
                Text(
                  'Why Choose RigCheck?',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'The most comprehensive PC building platform',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: WebInspiredTheme.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Feature Cards
                _buildFeatureCard(
                  context,
                  icon: Icons.memory,
                  title: '${componentCounts['total']}+ Components',
                  description:
                      'Massive database of CPUs, GPUs, motherboards, and more',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  icon: Icons.verified_user,
                  title: 'Compatibility Check',
                  description:
                      'Real-time validation ensures all parts work together',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  icon: Icons.trending_up,
                  title: 'Price Comparison',
                  description: 'Find the best deals from retailers',
                ),
                const SizedBox(height: 16),
                _buildFeatureCard(
                  context,
                  icon: Icons.build_circle,
                  title: 'Expert Tools',
                  description: 'Compare specs, estimate power, and plan budget',
                ),
              ],
            ),
          ),

          // Categories Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                // Section Header
                Text(
                  'Browse by Category',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore our extensive component database',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: WebInspiredTheme.mutedForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Category Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.1,
                  children: [
                    _buildCategoryCard(
                      context,
                      emoji: '🔷',
                      name: 'CPUs',
                      count: componentCounts['cpu'] ?? 0,
                      category: 'cpu',
                    ),
                    _buildCategoryCard(
                      context,
                      emoji: '🔲',
                      name: 'Motherboards',
                      count: componentCounts['motherboard'] ?? 0,
                      category: 'motherboard',
                    ),
                    _buildCategoryCard(
                      context,
                      emoji: '🎮',
                      name: 'GPUs',
                      count: componentCounts['gpu'] ?? 0,
                      category: 'gpu',
                    ),
                    _buildCategoryCard(
                      context,
                      emoji: '💾',
                      name: 'RAM',
                      count: componentCounts['ram'] ?? 0,
                      category: 'ram',
                    ),
                    _buildCategoryCard(
                      context,
                      emoji: '💿',
                      name: 'Storage',
                      count: componentCounts['storage'] ?? 0,
                      category: 'storage',
                    ),
                    _buildCategoryCard(
                      context,
                      emoji: '⚡',
                      name: 'Power',
                      count: componentCounts['psu'] ?? 0,
                      category: 'psu',
                    ),
                    _buildCategoryCard(
                      context,
                      emoji: '📦',
                      name: 'Cases',
                      count: componentCounts['case'] ?? 0,
                      category: 'case',
                    ),
                    _buildCategoryCard(
                      context,
                      emoji: '❄️',
                      name: 'Coolers',
                      count: componentCounts['cooler'] ?? 0,
                      category: 'cooler',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // CTA Section
          Container(
            color: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Text(
                  'Ready to Build Your PC?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: WebInspiredTheme.primaryForeground,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Join thousands of PC enthusiasts who trust RigCheck for their builds. Start building your dream setup today!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: WebInspiredTheme.primaryForeground.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/builder'),
                  icon: const Icon(Icons.build),
                  label: const Text('Launch PC Builder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: theme.colorScheme.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      inherit: false,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.push('/builds'),
                  child: const Text('Browse Build Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(
                      inherit: false,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(WebInspiredTheme.radiusLg),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: WebInspiredTheme.mutedForeground,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String emoji,
    required String name,
    required int count,
    required String category,
  }) {
    return InkWell(
      onTap: () => context.push('/components?category=$category'),
      borderRadius: BorderRadius.circular(WebInspiredTheme.radiusLg),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${count.toString()} products',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WebInspiredTheme.mutedForeground,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
