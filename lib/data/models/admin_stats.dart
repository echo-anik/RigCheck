class AdminStats {
  final int totalUsers;
  final int totalComponents;
  final int totalBuilds;
  final int totalPosts;
  final int publicBuilds;
  final int featuredComponents;
  final int bannedUsers;
  final int newUsersThisMonth;
  final Map<String, int> componentsByCategory;

  AdminStats({
    required this.totalUsers,
    required this.totalComponents,
    required this.totalBuilds,
    required this.totalPosts,
    required this.publicBuilds,
    required this.featuredComponents,
    required this.bannedUsers,
    required this.newUsersThisMonth,
    required this.componentsByCategory,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    final componentsData = json['components_by_category'] as List<dynamic>? ?? [];
    final categoryMap = <String, int>{};
    
    for (var item in componentsData) {
      final category = item['category'] as String;
      final count = item['count'] as int;
      categoryMap[category] = count;
    }

    return AdminStats(
      totalUsers: json['total_users'] as int? ?? 0,
      totalComponents: json['total_components'] as int? ?? 0,
      totalBuilds: json['total_builds'] as int? ?? 0,
      totalPosts: json['total_posts'] as int? ?? 0,
      publicBuilds: json['public_builds'] as int? ?? 0,
      featuredComponents: json['featured_components'] as int? ?? 0,
      bannedUsers: json['banned_users'] as int? ?? 0,
      newUsersThisMonth: json['new_users_this_month'] as int? ?? 0,
      componentsByCategory: categoryMap,
    );
  }
}
