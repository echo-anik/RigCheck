import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// AppColors removed - using theme
import '../../../data/models/user.dart';
import '../../providers/social_provider.dart';
import '../../providers/auth_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final int userId;
  final User? user; // Optional for when we have user data already

  const UserProfileScreen({
    super.key,
    required this.userId,
    this.user,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    
    // Load follow status and counts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(socialProvider.notifier).loadFollowStatus(widget.userId);
      ref.read(socialProvider.notifier).loadFollowCounts(widget.userId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleFollow() async {
    await ref.read(socialProvider.notifier).toggleFollow(widget.userId);
  }

  Widget _buildStatCard(String label, int count, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    final isOwnProfile = currentUser?.id == widget.userId;
    final isFollowing = ref.watch(isFollowingProvider(widget.userId));
    final followCounts = ref.watch(followCountsProvider(widget.userId));
    
    final displayUser = widget.user ?? currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(displayUser?.username ?? 'User Profile'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: displayUser == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Profile header
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: displayUser.avatarUrl != null
                            ? ClipOval(
                                child: Image.network(
                                  displayUser.avatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person,
                                          color: Colors.white, size: 50),
                                ),
                              )
                            : const Icon(Icons.person,
                                color: Colors.white, size: 50),
                      ),
                      const SizedBox(height: 16),

                      // Username
                      Text(
                        displayUser.username,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayUser.email,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                      ),
                      const SizedBox(height: 24),

                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard('Builds', 0),
                          _buildStatCard(
                            'Followers',
                            followCounts['followers'] ?? 0,
                          ),
                          _buildStatCard(
                            'Following',
                            followCounts['following'] ?? 0,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Follow button (only show if not own profile)
                      if (!isOwnProfile) ...[
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).colorScheme.primary,
                              foregroundColor: isFollowing
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: isFollowing
                                  ? BorderSide(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant
                                          .withOpacity(0.3))
                                  : null,
                            ),
                            icon: Icon(
                              isFollowing ? Icons.person_remove : Icons.person_add,
                              size: 20,
                            ),
                            label: Text(isFollowing ? 'Unfollow' : 'Follow'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Builds'),
                  ],
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Builds tab
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.computer_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isOwnProfile
                                  ? 'You haven\'t created any builds yet'
                                  : 'No builds yet',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
