import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/build.dart';
import 'admin_dashboard_screen.dart';

final adminBuildsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, page) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getBuildsList(page: page, perPage: 20);
});

class BuildManagementScreen extends ConsumerStatefulWidget {
  const BuildManagementScreen({super.key});

  @override
  ConsumerState<BuildManagementScreen> createState() => _BuildManagementScreenState();
}

class _BuildManagementScreenState extends ConsumerState<BuildManagementScreen> {
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final buildsAsync = ref.watch(adminBuildsProvider(_currentPage));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Build Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(adminBuildsProvider(_currentPage)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search builds...',
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
          ),

          // Build List
          Expanded(
            child: buildsAsync.when(
              data: (data) => _buildBuildList(context, data),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading builds',
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
                      onPressed: () => ref.refresh(adminBuildsProvider(_currentPage)),
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

  Widget _buildBuildList(BuildContext context, Map<String, dynamic> data) {
    final builds = (data['data'] as List?)
            ?.map((json) => Build.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];

    // Filter builds based on search query
    final filteredBuilds = _searchQuery.isEmpty
        ? builds
        : builds.where((build) {
            return build.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (build.userName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          }).toList();

    if (filteredBuilds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_circle_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No builds found' : 'No matching builds',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBuilds.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final build = filteredBuilds[index];
        return _buildBuildCard(context, build);
      },
    );
  }

  Widget _buildBuildCard(BuildContext context, Build build) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.2),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.computer,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                build.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (build.isPublic == true)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'PUBLIC',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            if (build.userName != null)
              Text('By: ${build.userName}'),
            const SizedBox(height: 4),
            Text(
              'Components: ${build.componentCount} • Cost: \$${(build.totalCost / 120).toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Created: ${_formatDate(build.createdAt)}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBuildAction(context, value, build),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 12),
                  Text('View'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleBuildAction(BuildContext context, String action, Build build) {
    switch (action) {
      case 'view':
        if (build.id != null) {
          context.push('/builds/${build.id}', extra: build);
        }
        break;
      case 'delete':
        _confirmDelete(context, build);
        break;
    }
  }

  Future<void> _confirmDelete(BuildContext context, Build build) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Build'),
        content: Text(
            'Are you sure you want to delete "${build.name}"? This action cannot be undone.'),
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

    if (confirmed == true && mounted && build.id != null) {
      try {
        final repository = ref.read(adminRepositoryProvider);
        await repository.deleteBuild(build.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Build deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the builds list
          ref.invalidate(adminBuildsProvider(_currentPage));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete build: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
