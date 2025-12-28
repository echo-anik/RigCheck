import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/components/components_screen.dart';
import '../presentation/screens/components/search_screen.dart';
import '../presentation/screens/components/component_detail_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/settings_screen.dart';
import '../presentation/screens/profile/edit_profile_screen.dart';
import '../presentation/screens/profile/change_password_screen.dart';
import '../presentation/screens/builder/my_builds_screen.dart';
import '../presentation/screens/builder/builder_screen.dart';
import '../presentation/screens/builder/build_detail_screen.dart';
import '../presentation/screens/builder/template_selection_screen.dart';
import '../presentation/screens/gallery/gallery_screen.dart';
import '../presentation/screens/favorites/favorites_screen.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/user_management_screen.dart';
import '../presentation/screens/admin/user_form_screen.dart';
import '../presentation/screens/admin/component_management_screen.dart';
import '../presentation/screens/admin/component_form_screen.dart';
import '../presentation/screens/admin/build_management_screen.dart';
import '../presentation/screens/feed/feed_screen.dart';
import '../presentation/screens/feed/post_detail_screen.dart';
import '../presentation/screens/profile/user_profile_screen.dart';
import '../presentation/screens/notifications/notifications_screen.dart';
import '../presentation/screens/wishlist/wishlist_screen.dart';
import '../presentation/screens/compare/compare_screen.dart';
import '../data/models/component.dart';
import '../data/models/build.dart';
import '../data/models/user.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/components',
      name: 'components',
      builder: (context, state) => const ComponentsScreen(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/component/:id',
      name: 'component-detail',
      builder: (context, state) {
        final component = state.extra as Component;
        return ComponentDetailScreen(component: component);
      },
    ),
    GoRoute(
      path: '/builder',
      name: 'builder',
      builder: (context, state) => const BuilderScreen(),
    ),
    GoRoute(
      path: '/builder/new',
      name: 'builder-new',
      builder: (context, state) => const BuilderScreen(),
    ),
    GoRoute(
      path: '/builder/templates',
      name: 'builder-templates',
      builder: (context, state) => const TemplateSelectionScreen(),
    ),
    GoRoute(
      path: '/explore',
      name: 'explore',
      builder: (context, state) => const GalleryScreen(),
    ),
    GoRoute(
      path: '/my-builds',
      name: 'my-builds',
      builder: (context, state) => const MyBuildsScreen(),
    ),
    GoRoute(
      path: '/builds/:id',
      name: 'build-detail',
      builder: (context, state) {
        final build = state.extra as Build?;
        if (build == null) {
          // If build is null, show error screen or return to home
          return Scaffold(
            appBar: AppBar(title: const Text('Build Not Found')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Build data not available'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Go to Home'),
                  ),
                ],
              ),
            ),
          );
        }
        return BuildDetailScreen(build: build);
      },
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/change-password',
      name: 'change-password',
      builder: (context, state) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      name: 'wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/compare',
      name: 'compare',
      builder: (context, state) => const CompareScreen(),
    ),
    GoRoute(
      path: '/feed',
      name: 'feed',
      builder: (context, state) => const FeedScreen(),
    ),
    GoRoute(
      path: '/post/:id',
      name: 'post-detail',
      builder: (context, state) {
        final postId = int.parse(state.pathParameters['id']!);
        return PostDetailScreen(postId: postId);
      },
    ),
    GoRoute(
      path: '/user/:id',
      name: 'user-profile',
      builder: (context, state) {
        final userId = int.parse(state.pathParameters['id']!);
        return UserProfileScreen(userId: userId);
      },
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/admin/users',
      name: 'admin-users',
      builder: (context, state) => const UserManagementScreen(),
    ),
    GoRoute(
      path: '/admin/users/form',
      name: 'admin-users-form',
      builder: (context, state) {
        final user = state.extra as User?;
        return UserFormScreen(user: user);
      },
    ),
    GoRoute(
      path: '/admin/components',
      name: 'admin-components',
      builder: (context, state) => const ComponentManagementScreen(),
    ),
    GoRoute(
      path: '/admin/components/form',
      name: 'admin-components-form',
      builder: (context, state) {
        final component = state.extra as Component?;
        return ComponentFormScreen(component: component);
      },
    ),
    GoRoute(
      path: '/admin/builds',
      name: 'admin-builds',
      builder: (context, state) => const BuildManagementScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
