import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/component.dart';
import '../../../data/repositories/admin_repository.dart';
import '../../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';

final adminComponentsProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getComponentsList(
    page: params['page'] as int? ?? 1,
    perPage: params['perPage'] as int? ?? 20,
    category: params['category'] as String?,
  );
});

class ComponentManagementScreen extends ConsumerStatefulWidget {
  const ComponentManagementScreen({super.key});

  @override
  ConsumerState<ComponentManagementScreen> createState() => _ComponentManagementScreenState();
}

class _ComponentManagementScreenState extends ConsumerState<ComponentManagementScreen> {
  int _currentPage = 1;
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'All',
    'cpu',
    'gpu',
    'ram',
    'storage',
    'motherboard',
    'psu',
    'case',
    'cooler',
  ];

  @override
  Widget build(BuildContext context) {
    final params = {
      'page': _currentPage,
      'perPage': 20,
      'category': _selectedCategory,
    };
    final componentsAsync = ref.watch(adminComponentsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminComponentsProvider(params)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComponentForm(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Add Component'),
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search components...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = (category == 'All' && _selectedCategory == null) ||
                          _selectedCategory == category;

                      return FilterChip(
                        label: Text(category.toUpperCase()),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category == 'All' ? null : category;
                            _currentPage = 1;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Component List
          Expanded(
            child: componentsAsync.when(
              data: (data) => _buildComponentList(context, data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading components',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => ref.refresh(adminComponentsProvider(params)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentList(BuildContext context, Map<String, dynamic> data) {
    final components = (data['data'] as List?)?.map((json) => Component.fromJson(json as Map<String, dynamic>)).toList() ?? [];

    // Filter components based on search query
    final filteredComponents = _searchQuery.isEmpty
        ? components
        : components.where((component) {
            return component.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                component.brand.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    if (filteredComponents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.memory, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No components found' : 'No matching components',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredComponents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final component = filteredComponents[index];
        return _buildComponentCard(context, component);
      },
    );
  }

  Widget _buildComponentCard(BuildContext context, Component component) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: _getCategoryColor(component.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(component.category),
            color: _getCategoryColor(component.category),
            size: 28,
          ),
        ),
        title: Text(
          component.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(component.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    component.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(component.category),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(component.brand),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '৳${component.priceBdt?.toStringAsFixed(0) ?? 'N/A'} • ID: ${component.id}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (component.featured == true)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      'Featured',
                      style: TextStyle(fontSize: 12, color: Colors.amber),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleComponentAction(context, value, component),
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
            PopupMenuItem(
              value: 'toggle_featured',
              child: Row(
                children: [
                  Icon(Icons.star, size: 20),
                  SizedBox(width: 12),
                  Text(component.featured == true ? 'Unfeature' : 'Feature'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'cpu':
        return Colors.blue;
      case 'gpu':
        return Colors.purple;
      case 'ram':
        return Colors.green;
      case 'storage':
        return Colors.orange;
      case 'motherboard':
        return Colors.red;
      case 'psu':
        return Colors.yellow[700]!;
      case 'case':
        return Colors.grey;
      case 'cooler':
        return Colors.cyan;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cpu':
        return Icons.memory;
      case 'gpu':
        return Icons.videogame_asset;
      case 'ram':
        return Icons.storage;
      case 'storage':
        return Icons.sd_storage;
      case 'motherboard':
        return Icons.developer_board;
      case 'psu':
        return Icons.power;
      case 'case':
        return Icons.computer;
      case 'cooler':
        return Icons.ac_unit;
      default:
        return Icons.hardware;
    }
  }

  void _handleComponentAction(BuildContext context, String action, Component component) {
    switch (action) {
      case 'edit':
        _showComponentForm(context, component);
        break;
      case 'toggle_featured':
        _toggleFeatured(context, component);
        break;
      case 'delete':
        _confirmDelete(context, component);
        break;
    }
  }

  void _showComponentForm(BuildContext context, Component? component) {
    context.push('/admin/components/form', extra: component);
  }

  Future<void> _toggleFeatured(BuildContext context, Component component) async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      await repository.updateComponent(component.id, {'featured': !(component.featured ?? false)});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(component.featured == true ? 'Component unfeatured' : 'Component featured'),
            backgroundColor: Colors.green,
          ),
        );
        final params = {
          'page': _currentPage,
          'perPage': 20,
          'category': _selectedCategory,
        };
        ref.refresh(adminComponentsProvider(params));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update component: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, Component component) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Component'),
        content: Text('Are you sure you want to delete ${component.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repository = ref.read(adminRepositoryProvider);
        await repository.deleteComponent(component.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Component deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          final params = {
            'page': _currentPage,
            'perPage': 20,
            'category': _selectedCategory,
          };
          ref.refresh(adminComponentsProvider(params));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete component: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
