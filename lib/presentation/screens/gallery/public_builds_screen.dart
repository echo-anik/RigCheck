import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// AppColors removed - using theme
import '../../../data/models/build.dart';
import '../../providers/build_provider.dart';
import '../../widgets/build_card.dart';

/// Provider for public builds
final publicBuildsProvider = FutureProvider.family<List<Build>, PublicBuildsParams>((ref, params) async {
  final repository = ref.read(buildRepositoryProvider);
  return repository.getPublicBuilds(
    useCase: params.useCase,
    page: params.page,
    perPage: params.perPage,
  );
});

class PublicBuildsParams {
  final String? useCase;
  final int page;
  final int perPage;

  PublicBuildsParams({
    this.useCase,
    this.page = 1,
    this.perPage = 20,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PublicBuildsParams &&
          runtimeType == other.runtimeType &&
          useCase == other.useCase &&
          page == other.page &&
          perPage == other.perPage;

  @override
  int get hashCode => useCase.hashCode ^ page.hashCode ^ perPage.hashCode;
}

class PublicBuildsScreen extends ConsumerStatefulWidget {
  const PublicBuildsScreen({super.key});

  @override
  ConsumerState<PublicBuildsScreen> createState() => _PublicBuildsScreenState();
}

class _PublicBuildsScreenState extends ConsumerState<PublicBuildsScreen> {
  String? _selectedUseCase;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  bool _isLoadingMore = false;

  static const List<String> _useCases = [
    'All',
    'Gaming',
    'Workstation',
    'Budget',
    'Office',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      _currentPage++;
    });

    // Load more builds
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 1;
    });
    ref.invalidate(publicBuildsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final params = PublicBuildsParams(
      useCase: _selectedUseCase == 'All' ? null : _selectedUseCase,
      page: _currentPage,
    );

    final buildsAsync = ref.watch(publicBuildsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Builds'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search builds',
            onPressed: () {
              // TODO: Navigate to search
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Use case filter chips
          _buildFilterChips(),

          // Builds list
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: buildsAsync.when(
                data: (builds) => _buildBuildsList(builds),
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _useCases.length,
        itemBuilder: (context, index) {
          final useCase = _useCases[index];
          final isSelected = useCase == (_selectedUseCase ?? 'All');

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(useCase),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedUseCase = useCase == 'All' ? null : useCase;
                  _currentPage = 1;
                });
                ref.invalidate(publicBuildsProvider);
              },
              selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              labelStyle: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBuildsList(List<Build> builds) {
    if (builds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.computer_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No public builds found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share a build!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: builds.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == builds.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final build = builds[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BuildCard(
            buildModel: build,
            showActions: false,
            showUser: true,
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          height: 200,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load builds',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
