import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Shared widgets
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/page_transitions.dart';

// Features imports
import '../../../features/users/presentation/pages/home_page.dart';
import '../../../features/users/presentation/pages/full_user_profile_page.dart';
import '../../../features/users/presentation/pages/profile_page.dart';
import '../../../features/users/presentation/pages/users_list_page.dart';
import '../../../features/posts/presentation/pages/post_detail_page.dart';

// Domain entities
import '../../../features/users/domain/entities/post.dart';

/// Route names used for navigation
class AppRoutes {
  // Main tab routes
  static const String home = 'home';
  static const String users = 'users';
  static const String profile = 'profile';

  // Detail routes
  static const String postDetail = 'post-detail';
  static const String userProfile = 'user-profile';
  static const String fullUserProfile = 'full-user-profile';
}

/// Path names used for routing
class AppPaths {
  // Main tab paths
  static const String home = '/home';
  static const String users = '/users';
  static const String profile = '/profile';

  // Detail paths
  static const String postDetail = '/post-detail';
  static const String userProfile = '/user-profile';
  static const String fullUserProfile = '/full-user-profile';

  /// Get path for a navigation tab
  static String getPathForTab(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.home:
        return home;
      case NavigationTab.users:
        return users;
      case NavigationTab.profile:
        return profile;
    }
  }
}

/// Observer for GoRouter with enhanced debugging
class GoRouterObserver extends NavigatorObserver {
  static const bool enableDebugPrints = kDebugMode;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (enableDebugPrints) {
      dev.log(
        'didPush: ${route.settings.name} from ${previousRoute?.settings.name}',
        name: 'GoRouterObserver',
      );
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (enableDebugPrints) {
      dev.log(
        'didPop: ${route.settings.name} to ${previousRoute?.settings.name}',
        name: 'GoRouterObserver',
      );
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (enableDebugPrints) {
      dev.log(
        'didRemove: ${route.settings.name}',
        name: 'GoRouterObserver',
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (enableDebugPrints) {
      dev.log(
        'didReplace: ${oldRoute?.settings.name} with ${newRoute?.settings.name}',
        name: 'GoRouterObserver',
      );
    }
  }
}

/// Router configuration for the app
class AppRouter {
  static final _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  static final _shellNavigatorKeyHome =
      GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  static final _shellNavigatorKeyPosts =
      GlobalKey<NavigatorState>(debugLabel: 'shellPosts');
  static final _shellNavigatorKeyProfile =
      GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  /// Initialize the router
  static GoRouter get router => _router;

  static final _router = GoRouter(
    initialLocation: AppPaths.home,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    observers: [GoRouterObserver()],

    routes: [
      // User profile detail - uses root navigator for full screen
      GoRoute(
        path: '${AppPaths.userProfile}/:userId',
        name: AppRoutes.userProfile,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final userIdParam = state.pathParameters['userId'];
          final userId = int.tryParse(userIdParam ?? '');

          if (userId == null) {
            return state.toFadeTransitionPage(
              child: Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: const Center(child: Text('Invalid user ID')),
              ),
            );
          }

          return state.toRightToLeftPage(
            child: FullUserProfilePage(userId: userId),
          );
        },
      ),

      // Post detail - uses root navigator for full screen
      GoRoute(
        path: '${AppPaths.postDetail}/:postId',
        name: AppRoutes.postDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final post = state.extra as Post?;
          final postIdParam = state.pathParameters['postId'];
          final postId = int.tryParse(postIdParam ?? '');

          if (postId == null) {
            return state.toFadeTransitionPage(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Error'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppPaths.users),
                  ),
                ),
                body: const Center(child: Text('Invalid post ID')),
              ),
            );
          }

          return state.toRightToLeftPage(
            child: PostDetailPage(
              post: post!,
            ),
          );
        },
      ),

      // Shell route for main app with bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Home branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyHome,
            routes: [
              GoRoute(
                path: AppPaths.home,
                name: AppRoutes.home,
                pageBuilder: (context, state) => state.toNoTransitionPage(
                  child: const HomePage(),
                ),
              ),
            ],
          ),

          // Posts branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyPosts,
            routes: [
              GoRoute(
                path: AppPaths.users,
                name: AppRoutes.users,
                pageBuilder: (context, state) => state.toNoTransitionPage(
                  child: const UsersListPage(),
                ),
              ),
            ],
          ),

          // Profile branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyProfile,
            routes: [
              GoRoute(
                path: AppPaths.profile,
                name: AppRoutes.profile,
                pageBuilder: (context, state) => state.toNoTransitionPage(
                  child: const ProfilePage(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],

    // Enhanced error handler for navigation issues
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Navigation Error'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go(AppPaths.home),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'The page you are looking for does not exist or an error occurred during navigation.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                Text(
                  'Error: ${state.error}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        fontFamily: 'monospace',
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Location: ${state.uri}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontFamily: 'monospace',
                      ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => context.go(AppPaths.home),
                icon: const Icon(Icons.home),
                label: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Extension methods for convenient navigation
extension GoRouterExtensions on BuildContext {
  /// Safe pop that handles edge cases
  void safePop() {
    try {
      final router = GoRouter.of(this);
      final routerDelegate = router.routerDelegate;

      // Check if we can pop using GoRouter's canPop method
      if (routerDelegate.canPop()) {
        pop();
      } else {
        // If we can't pop, go to the appropriate fallback
        final currentLocation = GoRouterState.of(this).uri.toString();

        // If we're on a detail page, go back to the appropriate tab
        if (currentLocation.contains('/post-detail')) {
          go(AppPaths.users); // Go back to users tab
        } else if (currentLocation.contains('/user-profile')) {
          go(AppPaths.users); // Go back to users tab (fixed from home)
        } else {
          // Default fallback
          go(AppPaths.home);
        }
      }
    } catch (e) {
      // Fallback in case of any navigation error
      try {
        go(AppPaths.home);
      } catch (fallbackError) {
        // Last resort - do nothing to prevent crash
        dev.log('Navigation error: $e, Fallback error: $fallbackError',
            name: 'Navigation');
      }
    }
  }

  /// Navigate to post detail using named route with error handling
  void goToPostDetail(Post post) {
    try {
      goNamed(
        AppRoutes.postDetail,
        pathParameters: {'postId': post.id.toString()},
        extra: post,
      );
    } catch (e) {
      dev.log('Error navigating to post detail: $e', name: 'Navigation');
      safePop();
    }
  }

  /// Navigate to user profile using named route with error handling
  void goToUserProfile(int userId) {
    try {
      goNamed(
        AppRoutes.userProfile,
        pathParameters: {'userId': userId.toString()},
      );
    } catch (e) {
      dev.log('Error navigating to user profile: $e', name: 'Navigation');
      safePop();
    }
  }

  /// Navigate to full user profile using named route with error handling
  void goToFullUserProfile(int userId) {
    try {
      goNamed(
        AppRoutes.fullUserProfile,
        pathParameters: {'userId': userId.toString()},
      );
    } catch (e) {
      dev.log('Error navigating to full user profile: $e', name: 'Navigation');
      safePop();
    }
  }

  /// Navigate to tabs using named routes with error handling
  void goToHome() {
    try {
      goNamed(AppRoutes.home);
    } catch (e) {
      dev.log('Error navigating to home: $e', name: 'Navigation');
      go(AppPaths.home);
    }
  }

  void goToUsers() {
    try {
      goNamed(AppRoutes.users);
    } catch (e) {
      dev.log('Error navigating to users: $e', name: 'Navigation');
      go(AppPaths.users);
    }
  }

  void goToProfile() {
    try {
      goNamed(AppRoutes.profile);
    } catch (e) {
      dev.log('Error navigating to profile: $e', name: 'Navigation');
      go(AppPaths.profile);
    }
  }

  /// Get current route name safely
  String? get currentRoute {
    try {
      return GoRouterState.of(this).name;
    } catch (e) {
      dev.log('Error getting current route: $e', name: 'Navigation');
      return null;
    }
  }

  /// Check if currently on a specific route safely
  bool isCurrentRoute(String routeName) {
    try {
      return currentRoute == routeName;
    } catch (e) {
      dev.log('Error checking current route: $e', name: 'Navigation');
      return false;
    }
  }

  /// Navigate with custom transition with error handling
  void pushWithTransition(
    String path, {
    Object? extra,
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
  }) {
    try {
      push(path, extra: extra);
    } catch (e) {
      dev.log('Error with push transition: $e', name: 'Navigation');
      safePop();
    }
  }
}
