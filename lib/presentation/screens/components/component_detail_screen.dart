import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// AppColors removed - using theme
import '../../../data/models/component.dart';
import '../../../data/models/build.dart';
import '../../providers/build_provider.dart';
import '../../providers/active_build_provider.dart';
import '../../widgets/wishlist_button.dart';
import '../builder/builder_screen.dart';
import '../builder/component_selection_screen.dart';

class ComponentDetailScreen extends ConsumerStatefulWidget {
  final Component component;

  const ComponentDetailScreen({
    super.key,
    required this.component,
  });

  @override
  ConsumerState<ComponentDetailScreen> createState() =>
      _ComponentDetailScreenState();
}

class _ComponentDetailScreenState extends ConsumerState<ComponentDetailScreen> {
  int _currentImageIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderVisible = false;
  bool _isLoading = false;

  // Dummy related components
  late List<Component> _relatedComponents;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initializeRelatedComponents();
  }

  void _initializeRelatedComponents() {
    // Generate dummy related components
    _relatedComponents = List.generate(3, (index) {
      return Component(
        id: widget.component.id + index + 1,
        productId: 'RELATED_${widget.component.productId}_$index',
        category: widget.component.category,
        name: '${widget.component.brand} Alternative Model ${index + 1}',
        brand: widget.component.brand,
        priceBdt: (widget.component.priceBdt ?? 0) * (0.9 + (index * 0.1)),
        imageUrl: widget.component.imageUrl,
        availabilityStatus: 'in_stock',
        popularityScore: 75 - (index * 5),
        featured: false,
        specs: widget.component.specs,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200 && !_isHeaderVisible) {
      setState(() {
        _isHeaderVisible = true;
      });
    } else if (_scrollController.offset <= 200 && _isHeaderVisible) {
      setState(() {
        _isHeaderVisible = false;
      });
    }
  }

  Future<void> _addToActiveBuild() async {
    final activeBuildState = ref.read(activeBuildProvider);

    if (!activeBuildState.hasActiveBuild) {
      // Should not happen, button only shows when there's an active build
      return;
    }

    // Add component to active build
    ref.read(activeBuildProvider.notifier).replaceComponent(
      widget.component.category,
      widget.component,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.component.name} added to build'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      // Auto-progress to next component category like the web version
      final nextCategory = _getNextCategory(widget.component.category);

      if (nextCategory != null) {
        // Navigate to next category selection
        Navigator.pop(context); // Go back to builder/previous screen

        // Small delay to let the previous screen rebuild
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          // Navigate to next category selection screen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ComponentSelectionScreen(
                category: nextCategory['id'],
                categoryName: nextCategory['name'],
                currentBuild: activeBuildState.activeBuild,
              ),
            ),
          );
        }
      } else {
        // No more required categories, go back to builder
        Navigator.pop(context);
      }
    }
  }

  // Get the next category in the build progression
  Map<String, dynamic>? _getNextCategory(String currentCategory) {
    // Category order from builder_screen.dart
    final categories = [
      {'id': 'cpu', 'name': 'CPU', 'required': true},
      {'id': 'motherboard', 'name': 'Motherboard', 'required': true},
      {'id': 'video-card', 'name': 'GPU', 'required': false},
      {'id': 'memory', 'name': 'RAM', 'required': true},
      {'id': 'internal-hard-drive', 'name': 'Storage', 'required': true},
      {'id': 'power-supply', 'name': 'PSU', 'required': true},
      {'id': 'case', 'name': 'Case', 'required': true},
      {'id': 'cpu-cooler', 'name': 'Cooler', 'required': false},
    ];

    // Find current category index
    final currentIndex = categories.indexWhere((c) => c['id'] == currentCategory);

    if (currentIndex == -1 || currentIndex >= categories.length - 1) {
      return null; // No next category
    }

    // Return next category (preferably a required one)
    for (int i = currentIndex + 1; i < categories.length; i++) {
      final category = categories[i];
      final activeBuildState = ref.read(activeBuildProvider);

      // Check if this category is already filled
      final alreadyHasComponent = activeBuildState.activeBuild?.components.containsKey(category['id']) ?? false;

      // If this category is required and not filled, return it
      if (category['required'] == true && !alreadyHasComponent) {
        return category;
      }
    }

    // No more required categories to fill
    return null;
  }

  Future<void> _showAddToBuildDialog() async {
    final buildState = ref.read(buildProvider);
    final builds = buildState.myBuilds;

    if (builds.isEmpty) {
      // Show option to create new build
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No Builds Found'),
          content:
              const Text('You don\'t have any builds yet. Create a new build?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create Build'),
            ),
          ],
        ),
      );

      if (result == true && mounted) {
        // Navigate to builder screen with this component pre-selected
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BuilderScreen(
              initialComponent: widget.component,
              initialCategory: widget.component.category,
            ),
          ),
        );
      }
      return;
    }

    // Show build selection dialog
    final selectedBuild = await showDialog<Build>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Build'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: builds.length + 1, // +1 for "Create New" option
            itemBuilder: (context, index) {
              if (index == 0) {
                // Create new build option
                return ListTile(
                  leading: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text(
                    'Create New Build',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Start a new PC build'),
                  onTap: () => Navigator.pop(context, Build.empty()),
                );
              }
              
              final build = builds[index - 1];
              return ListTile(
                leading: Icon(
                  Icons.computer,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(build.name),
                subtitle: Text(
                  '${build.componentCount} components • \$${(build.totalCost / 120).toStringAsFixed(2)}',
                ),
                trailing: const Icon(Icons.add_circle_outline),
                onTap: () => Navigator.pop(context, build),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedBuild != null && mounted) {
      if (selectedBuild.id == null) {
        // Navigate to builder with this component
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BuilderScreen(
              initialComponent: widget.component,
              initialCategory: widget.component.category,
            ),
          ),
        );
      } else {
        // Add component to existing build - navigate to builder screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BuilderScreen(
              existingBuild: selectedBuild,
              initialComponent: widget.component,
              initialCategory: widget.component.category,
            ),
          ),
        );
      }
    }
  }

  Future<void> _shareComponent() async {
    await Clipboard.setData(
      ClipboardData(
        text:
            '${widget.component.name} - ${widget.component.priceBdt?.toStringAsFixed(0)} BDT\nShared from RigCheck',
      ),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Component details copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sticky Header
          SliverAppBar(
            expandedHeight: 0,
            pinned: true,
            backgroundColor:
                _isHeaderVisible ? Theme.of(context).colorScheme.surface : Colors.transparent,
            elevation: _isHeaderVisible ? 2 : 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _isHeaderVisible
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: _isHeaderVisible
                ? Text(
                    widget.component.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  )
                : null,
            actions: [
              WishlistButton(
                itemId: widget.component.id.toString(),
                type: WishlistItemType.component,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareComponent,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  _showOptionsMenu();
                },
              ),
            ],
          ),

          // Scrollable Content
          SliverList(
            delegate: SliverChildListDelegate([
              // Product Image Gallery
              _buildImageGallery(),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title & Price
                    Text(
                      widget.component.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.component.brand,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Price & Availability Section
                    _buildPriceSection(),
                    const SizedBox(height: 24),

                    // Quick Specs
                    if (widget.component.specs != null) ...[
                      _buildQuickSpecs(),
                      const SizedBox(height: 32),
                    ],

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 32),

                    // Compatibility Notes Section
                    _buildCompatibilityNotes(),
                    const SizedBox(height: 32),

                    // Specifications
                    Text(
                      'Specifications',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildSpecificationsList(),
                    const SizedBox(height: 32),

                    // Related Components
                    _buildRelatedComponents(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = [
      widget.component.imageUrl ?? '',
      widget.component.imageUrl ?? '',
      widget.component.imageUrl ?? '',
    ];

    return Container(
      height: 320,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Show full screen image
                  _showFullScreenImage(index);
                },
                child: Center(
                  child: widget.component.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                            highlightColor: Colors.white,
                            child: Container(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Image not available',
                                  style: TextStyle(color: Theme.of(context).colorScheme.outline),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.computer,
                              size: 80,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No image available',
                              style: TextStyle(color: Theme.of(context).colorScheme.outline),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
          // Image Indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
          ),
          // Image counter
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.component.priceBdt != null
                            ? '${widget.component.priceBdt!.toStringAsFixed(0)} BDT'
                            : 'Price N/A',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                _buildAvailabilityBadge(),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.local_shipping, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Free shipping on orders over 5000 BDT',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    final status = widget.component.availabilityStatus ?? 'in_stock';
    Color badgeColor;
    String badgeText;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'in_stock':
        badgeColor = Colors.green;
        badgeText = 'In Stock';
        icon = Icons.check_circle;
        break;
      case 'out_of_stock':
        badgeColor = Theme.of(context).colorScheme.error;
        badgeText = 'Out of Stock';
        icon = Icons.cancel;
        break;
      case 'limited':
        badgeColor = Colors.orange;
        badgeText = 'Low Stock';
        icon = Icons.warning;
        break;
      default:
        badgeColor = Theme.of(context).colorScheme.onSurfaceVariant;
        badgeText = status;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            badgeText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSpecs() {
    final specs = widget.component.specs!;
    final quickSpecs = <Map<String, String>>[];

    // Add category-specific quick specs
    switch (widget.component.category) {
      case 'video-card':
        if (specs['memory'] != null) {
          quickSpecs.add({
            'label': 'Memory',
            'value': '${specs['memory']}',
            'unit': 'GB',
          });
        }
        if (specs['boost_clock'] != null) {
          quickSpecs.add({
            'label': 'Boost Clock',
            'value': '${specs['boost_clock']}',
            'unit': 'MHz',
          });
        }
        if (specs['length'] != null) {
          quickSpecs.add({
            'label': 'Length',
            'value': '${specs['length']}',
            'unit': 'mm',
          });
        }
        break;
      case 'cpu':
        if (specs['core_count'] != null) {
          quickSpecs.add({
            'label': 'Cores',
            'value': '${specs['core_count']}',
            'unit': 'cores',
          });
        }
        if (specs['boost_clock'] != null) {
          quickSpecs.add({
            'label': 'Boost Clock',
            'value': '${specs['boost_clock']}',
            'unit': 'GHz',
          });
        }
        if (specs['tdp'] != null) {
          quickSpecs.add({
            'label': 'TDP',
            'value': '${specs['tdp']}',
            'unit': 'W',
          });
        }
        break;
      case 'memory':
        if (specs['speed'] != null && specs['speed'] is List) {
          final speedList = specs['speed'] as List;
          if (speedList.length > 1) {
            quickSpecs.add({
              'label': 'Type',
              'value': 'DDR${speedList[0]}',
              'unit': '${speedList[1]}MHz',
            });
          }
        }
        if (specs['modules'] != null && specs['modules'] is List) {
          final modulesList = specs['modules'] as List;
          if (modulesList.isNotEmpty) {
            quickSpecs.add({
              'label': 'Modules',
              'value': '${modulesList[0]}',
              'unit': '${modulesList[1]}GB',
            });
          }
        }
        break;
      case 'motherboard':
        if (specs['socket'] != null) {
          quickSpecs.add({
            'label': 'Socket',
            'value': '${specs['socket']}',
            'unit': '',
          });
        }
        if (specs['form_factor'] != null) {
          quickSpecs.add({
            'label': 'Form Factor',
            'value': '${specs['form_factor']}',
            'unit': '',
          });
        }
        break;
    }

    if (quickSpecs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Specifications',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: quickSpecs.length > 2 ? 3 : 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: quickSpecs.length,
          itemBuilder: (context, index) {
            final spec = quickSpecs[index];
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      spec['label']!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      spec['value']!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (spec['unit']!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        spec['unit']!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final activeBuildState = ref.watch(activeBuildProvider);
    final hasActiveBuild = activeBuildState.hasActiveBuild;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: ElevatedButton.icon(
            onPressed: hasActiveBuild ? _addToActiveBuild : _showAddToBuildDialog,
            icon: Icon(hasActiveBuild ? Icons.add_shopping_cart : Icons.add_circle_outline),
            label: Text(
              hasActiveBuild ? 'Add to Active Build' : 'Add to Build',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasActiveBuild
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        WishlistButton(
          itemId: widget.component.id.toString(),
          type: WishlistItemType.component,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _shareComponent,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Icon(Icons.share),
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityNotes() {
    // Dummy compatibility notes
    final notes = _getCompatibilityNotes();

    if (notes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compatibility Notes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...notes.map((note) => _buildCompatibilityNote(note)),
      ],
    );
  }

  List<Map<String, dynamic>> _getCompatibilityNotes() {
    final category = widget.component.category;
    final notes = <Map<String, dynamic>>[];

    switch (category) {
      case 'cpu':
        notes.add({
          'type': 'info',
          'title': 'Socket Compatibility',
          'message':
              'Ensure your motherboard has a compatible ${widget.component.specs?['socket'] ?? 'socket'} socket.',
        });
        notes.add({
          'type': 'warning',
          'title': 'Cooling Required',
          'message':
              'This CPU requires adequate cooling. Consider a CPU cooler with at least ${widget.component.specs?['tdp'] ?? '65'}W TDP rating.',
        });
        break;
      case 'video-card':
        notes.add({
          'type': 'info',
          'title': 'PCIe Slot Required',
          'message': 'Requires a PCIe x16 slot on your motherboard.',
        });
        notes.add({
          'type': 'warning',
          'title': 'Case Clearance',
          'message':
              'Verify your case can accommodate a GPU of ${widget.component.specs?['length'] ?? '300'}mm length.',
        });
        notes.add({
          'type': 'warning',
          'title': 'Power Supply',
          'message':
              'Recommended PSU: 600W+ with appropriate PCIe power connectors.',
        });
        break;
      case 'memory':
        notes.add({
          'type': 'info',
          'title': 'RAM Compatibility',
          'message':
              'Ensure your motherboard supports this RAM type and speed.',
        });
        break;
      case 'motherboard':
        notes.add({
          'type': 'info',
          'title': 'Form Factor',
          'message':
              'Verify your case supports ${widget.component.specs?['form_factor'] ?? 'ATX'} motherboards.',
        });
        break;
    }

    return notes;
  }

  Widget _buildCompatibilityNote(Map<String, dynamic> note) {
    Color color;
    IconData icon;

    switch (note['type']) {
      case 'error':
        color = Theme.of(context).colorScheme.error;
        icon = Icons.error;
        break;
      case 'warning':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'success':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.blue;
        icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
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
                  note['title'],
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  note['message'],
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

  Widget _buildSpecificationsList() {
    final specs = widget.component.specs ?? {};

    if (specs.isEmpty) {
      return const Text('No specifications available');
    }

    return Card(
      elevation: 1,
      child: Column(
        children: specs.entries.map((entry) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formatSpecKey(entry.key),
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatSpecValue(entry.value),
                        textAlign: TextAlign.right,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              if (entry.key != specs.keys.last) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRelatedComponents() {
    if (_relatedComponents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Components',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _relatedComponents.length,
            itemBuilder: (context, index) {
              final component = _relatedComponents[index];
              return _buildRelatedComponentCard(component);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedComponentCard(Component component) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ComponentDetailScreen(
                  component: component,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4)),
                child: component.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: component.imageUrl!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Shimmer.fromColors(
                          baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          highlightColor: Colors.white,
                          child: Container(
                            height: 100,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 100,
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      )
                    : Container(
                        height: 100,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.computer,
                          color: Theme.of(context).colorScheme.outline,
                          size: 40,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      component.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (component.priceBdt != null)
                      Text(
                        '${component.priceBdt!.toStringAsFixed(0)} BDT',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
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

  String _formatSpecKey(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatSpecValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    return value.toString();
  }

  void _showFullScreenImage(int index) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: widget.component.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: widget.component.imageUrl!,
                      fit: BoxFit.contain,
                    )
                  : const Icon(
                      Icons.computer,
                      size: 100,
                      color: Colors.white,
                    ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('Compare'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Compare feature coming soon'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Price History'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Price history feature coming soon'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Report Issue'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
