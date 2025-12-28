class ApiConstants {
  // Base URL - Production API
  // Production: https://yellow-dinosaur-111977.hostingersite.com/api/v1
  // For local testing use: http://10.0.2.2:8000/api/v1
  static const String baseUrl = 'https://yellow-dinosaur-111977.hostingersite.com/api/v1';

  // Authentication endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String user = '/user';
  static const String userProfile = '/user/profile';
  static const String userAvatar = '/user/avatar';
  static const String changePassword = '/user/change-password';
  static const String deleteAccount = '/user/account';
  static const String userPreferences = '/user/preferences';
  static const String userStats = '/user/stats';

  // Components endpoints
  static const String components = '/components';
  static String componentById(String productId) => '/components/$productId';

  // Builds endpoints
  static const String builds = '/builds';
  static const String publicBuilds = '/builds/public';
  static const String myBuilds = '/builds/my';
  static String buildById(int id) => '/builds/$id';
  static String buildLike(int id) => '/builds/$id/like';
  static String buildComment(int id) => '/builds/$id/comment';
  static String buildComments(int id) => '/builds/$id/comments';

  // Compatibility endpoints
  static const String validateBuild = '/builds/validate';
  static const String compatibilityRules = '/rules';

  // Admin endpoints
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
  static String adminUserById(int userId) => '/admin/users/$userId';
  static const String adminComponents = '/admin/components';
  static String adminComponentById(int componentId) => '/admin/components/$componentId';
  static const String adminBuilds = '/admin/builds';
  static String adminBuildById(int buildId) => '/admin/builds/$buildId';

  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
