import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// AppColors removed - using theme
import '../../../data/models/build.dart';
import '../../providers/build_provider.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _scrollController = ScrollController();
  bool _isLoading = false;
  List<Build> _builds = [];
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBuilds();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMoreBuilds();
    }
  }

  Future<void> _loadBuilds() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
      _currentPage = 1;
    });

    try {
      print('🔄 Feed: Loading public builds...');
      final buildRepository = ref.read(buildRepositoryProvider);
      final builds = await buildRepository.getPublicBuilds(
        page: 1,
        perPage: 20,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );
      
      print('✅ Feed: Received ${builds.length} builds');
      if (builds.isEmpty) {
        print('⚠️ Feed: No public builds available in the database yet');
      }
      
      setState(() {
        _builds = builds;
        _hasMore = builds.length >= 20;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Feed: Error loading builds - $e');
      setState(() {
        _error = 'Failed to load builds: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreBuilds() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
      _currentPage++;
    });

    try {
      final buildRepository = ref.read(buildRepositoryProvider);
      final newBuilds = await buildRepository.getPublicBuilds(
        page: _currentPage,
        perPage: 20,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );
      
      setState(() {
        _builds.addAll(newBuilds);
        _hasMore = newBuilds.length >= 20;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _currentPage--;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshFeed() async {
    await _loadBuilds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Community Builds'),
            if (_builds.isNotEmpty)
              Text(
                '${_builds.length} builds shared',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search
              context.push('/search');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshFeed,
        child: _builds.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null && _builds.isEmpty
                ? Center(
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
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshFeed,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _builds.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.computer,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No builds shared yet',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to share a build!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.push('/builder');
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Create Build'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _builds.length + (_isLoading && _hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _builds.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final build = _builds[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () {
                                context.push('/builds/${build.id}', extra: build);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Build Image/Preview with gradient
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        // Placeholder content
                                        Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.computer,
                                                size: 48,
                                                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Build Preview',
                                                style: TextStyle(
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Compatibility badge
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: build.compatibilityStatus == 'valid'
                                                  ? Colors.green
                                                  : build.compatibilityStatus == 'warnings'
                                                      ? Colors.orange
                                                      : Theme.of(context).colorScheme.error,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              build.compatibilityStatus == 'valid'
                                                  ? 'Compatible'
                                                  : build.compatibilityStatus == 'warnings'
                                                      ? 'Minor Issues'
                                                      : 'Incompatible',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Build content
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Build title
                                        Text(
                                          build.name,
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        
                                        if (build.description != null && build.description!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            build.description!,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        
                                        const SizedBox(height: 16),
                                        
                                        // Build stats in grid
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _buildStatChip(
                                                label: 'Total Cost',
                                                value: '৳${build.totalCost.toStringAsFixed(0)}',
                                                icon: Icons.attach_money,
                                                color: Colors.green,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: _buildStatChip(
                                                label: 'Components',
                                                value: '${build.components.length}',
                                                icon: Icons.memory,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 16),
                                        const Divider(height: 1),
                                        const SizedBox(height: 8),
                                        
                                        // Social actions
                                        Row(
                                          children: [
                                            _buildActionButton(
                                              icon: build.isLikedByUser
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              label: '${build.likeCount}',
                                              color: build.isLikedByUser
                                                  ? Colors.red
                                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                                              onPressed: () {
                                                // Like functionality
                                              },
                                            ),
                                            const SizedBox(width: 4),
                                            _buildActionButton(
                                              icon: Icons.comment_outlined,
                                              label: '${build.commentCount}',
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              onPressed: () {
                                                context.push('/builds/${build.id}', extra: build);
                                              },
                                            ),
                                            const SizedBox(width: 4),
                                            _buildActionButton(
                                              icon: Icons.visibility_outlined,
                                              label: '${build.viewCount}',
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              onPressed: null,
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              icon: const Icon(Icons.share_outlined),
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              iconSize: 20,
                                              onPressed: () {
                                                // Share functionality
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/builder');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
