import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Shared widgets
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/page_transitions.dart';

// Features imports
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/full_user_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../../features/users/presentation/pages/users_list_page.dart';
import '../../features/home/presentation/pages/post_detail_page.dart';
import '../../features/my_posts/presentation/pages/my_posts_page.dart';
import '../../features/home/presentation/pages/create_edit_post_page.dart';

// Domain entities
import '../../features/home/domain/entities/post.dart';
import '../../features/my_posts/domain/entities/my_post.dart';

/// Route names used for navigation
class AppRoutes {
  // Main tab routes
  static const String home = 'home';
  static const String users = 'users';
  static const String myPosts = 'my-posts';
  static const String profile = 'profile';

  // Detail routes
  static const String postDetail = 'post-detail';
  static const String userProfile = 'user-profile';
  static const String fullUserProfile = 'full-user-profile';

  // My Posts routes
  static const String myPostDetail = 'my-post-detail';
  static const String createMyPost = 'create-my-post';
  static const String editMyPost = 'edit-my-post';
}

/// Path names used for routing
class AppPaths {
  // Main tab paths
  static const String home = '/home';
  static const String users = '/users';
  static const String myPosts = '/my-posts';
  static const String profile = '/profile';

  // Detail paths
  static const String postDetail = '/post-detail';
  static const String userProfile = '/user-profile';
  static const String fullUserProfile = '/full-user-profile';

  // My Posts paths
  static const String myPostDetail = '/my-posts/detail';
  static const String createMyPost = '/my-posts/create';
  static const String editMyPost = '/my-posts/edit';

  /// Get path for a navigation tab
  static String getPathForTab(NavigationTab tab) {
    switch (tab) {
      case NavigationTab.home:
        return home;
      case NavigationTab.users:
        return users;
      case NavigationTab.myPosts:
        return myPosts;
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
  static final _shellNavigatorKeyUsers =
      GlobalKey<NavigatorState>(debugLabel: 'shellUsers');
  static final _shellNavigatorKeyMyPosts =
      GlobalKey<NavigatorState>(debugLabel: 'shellMyPosts');
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

      // My Post Detail - uses root navigator for full screen
      GoRoute(
        path: '${AppPaths.myPostDetail}/:postId',
        name: AppRoutes.myPostDetail,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final post = state.extra as MyPost?;
          final postIdParam = state.pathParameters['postId'];
          final postId = int.tryParse(postIdParam ?? '');

          if (postId == null || post == null) {
            return state.toFadeTransitionPage(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Error'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppPaths.myPosts),
                  ),
                ),
                body: const Center(child: Text('Invalid post ID')),
              ),
            );
          }

          return state.toRightToLeftPage(
            child: CreateEditPostPage(post: post),
          );
        },
      ),

      // Create My Post - uses root navigator for full screen
      GoRoute(
        path: AppPaths.createMyPost,
        name: AppRoutes.createMyPost,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => state.toRightToLeftPage(
          child: const CreateEditPostPage(),
        ),
      ),

      // Edit My Post - uses root navigator for full screen
      GoRoute(
        path: '${AppPaths.editMyPost}/:postId',
        name: AppRoutes.editMyPost,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final post = state.extra as MyPost?;
          final postIdParam = state.pathParameters['postId'];
          final postId = int.tryParse(postIdParam ?? '');

          if (postId == null || post == null) {
            return state.toFadeTransitionPage(
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Error'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(AppPaths.myPosts),
                  ),
                ),
                body: const Center(child: Text('Post not found')),
              ),
            );
          }

          return state.toRightToLeftPage(
            child: CreateEditPostPage(post: post),
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

          // Users branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyUsers,
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

          // My Posts branch
          StatefulShellBranch(
            navigatorKey: _shellNavigatorKeyMyPosts,
            routes: [
              GoRoute(
                path: AppPaths.myPosts,
                name: AppRoutes.myPosts,
                pageBuilder: (context, state) => state.toNoTransitionPage(
                  child: const MyPostsPage(),
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
  /// Enhanced safe pop that properly handles navigation stack
  void safePop() {
    try {
      final router = GoRouter.of(this);
      final routerDelegate = router.routerDelegate;
      final currentLocation = GoRouterState.of(this).uri.toString();

      dev.log('SafePop called from: $currentLocation', name: 'Navigation');

      // Check if we can pop using the navigator's canPop method
      final navigator = Navigator.of(this);
      if (navigator.canPop()) {
        dev.log('Using Navigator.pop()', name: 'Navigation');
        // Use Flutter's Navigator.pop() for proper stack management
        navigator.pop();
      } else {
        // If we can't pop, check if we can use GoRouter's canPop
        if (routerDelegate.canPop()) {
          dev.log('Using GoRouter.pop()', name: 'Navigation');
          pop();
        } else {
          // As a last resort, navigate to appropriate fallback based on current context
          dev.log('Using fallback navigation', name: 'Navigation');
          _handleFallbackNavigation();
        }
      }
    } catch (e) {
      dev.log('Primary navigation failed: $e', name: 'Navigation');
      _handleFallbackNavigation();
    }
  }

  /// Handle fallback navigation when normal pop fails
  void _handleFallbackNavigation() {
    try {
      final currentLocation = GoRouterState.of(this).uri.toString();

      // Navigate to appropriate fallback based on current location
      if (currentLocation.contains('/user-profile')) {
        // If we're on user profile, go back to users tab
        go(AppPaths.users);
      } else if (currentLocation.contains('/post-detail')) {
        // If we're on post detail, go back to users tab (where posts are shown)
        go(AppPaths.users);
      } else if (currentLocation.contains('/my-posts')) {
        // If we're on my posts detail/edit, go back to my posts tab
        go(AppPaths.myPosts);
      } else {
        // Default fallback to home
        go(AppPaths.home);
      }
    } catch (fallbackError) {
      dev.log('Fallback navigation failed: $fallbackError', name: 'Navigation');
      // Last resort - try to go to home
      try {
        go(AppPaths.home);
      } catch (e) {
        dev.log('Final fallback to home failed: $e', name: 'Navigation');
        // Do nothing to prevent crash
      }
    }
  }

  /// Navigate to post detail using push for proper stack management
  void goToPostDetail(Post post) {
    try {
      // Check if we're currently on a profile page - if so, don't navigate to post
      final currentLocation = GoRouterState.of(this).uri.toString();
      if (currentLocation.contains('/user-profile/')) {
        // On a profile page, don't navigate to post details
        dev.log('On profile page, preventing post detail navigation',
            name: 'Navigation');
        return;
      }

      // Check if we're already on the same post detail page
      if (currentLocation.contains('/post-detail/${post.id}')) {
        // Already on this post's detail page, don't push again
        dev.log('Already on post detail ${post.id}, skipping navigation',
            name: 'Navigation');
        return;
      }

      pushNamed(
        AppRoutes.postDetail,
        pathParameters: {'postId': post.id.toString()},
        extra: post,
      );
    } catch (e) {
      dev.log('Error navigating to post detail: $e', name: 'Navigation');
      safePop();
    }
  }

  /// Navigate to user profile using push for proper stack management
  void goToUserProfile(int userId) {
    try {
      // Check if we're already on the same user profile page
      final currentLocation = GoRouterState.of(this).uri.toString();
      if (currentLocation.contains('/user-profile/$userId')) {
        // Already on this user's profile page, don't push again
        dev.log('Already on user profile $userId, skipping navigation',
            name: 'Navigation');
        return;
      }

      pushNamed(
        AppRoutes.userProfile,
        pathParameters: {'userId': userId.toString()},
      );
    } catch (e) {
      dev.log('Error navigating to user profile: $e', name: 'Navigation');
      safePop();
    }
  }

  /// Navigate to full user profile using push for proper stack management
  void goToFullUserProfile(int userId) {
    try {
      // Check if we're already on the same full user profile page
      final currentLocation = GoRouterState.of(this).uri.toString();
      if (currentLocation.contains('/full-user-profile/$userId')) {
        // Already on this user's full profile page, don't push again
        dev.log('Already on full user profile $userId, skipping navigation',
            name: 'Navigation');
        return;
      }

      pushNamed(
        AppRoutes.fullUserProfile,
        pathParameters: {'userId': userId.toString()},
      );
    } catch (e) {
      dev.log('Error navigating to full user profile: $e', name: 'Navigation');
      safePop();
    }
  }

  /// Navigate to tabs using go (replace navigation)
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

  /// Check if currently on a specific user profile route
  bool isOnUserProfile(int userId) {
    try {
      final currentLocation = GoRouterState.of(this).uri.toString();
      return currentLocation.contains('/user-profile/$userId');
    } catch (e) {
      dev.log('Error checking user profile route: $e', name: 'Navigation');
      return false;
    }
  }

  /// Check if currently on a specific post detail route
  bool isOnPostDetail(int postId) {
    try {
      final currentLocation = GoRouterState.of(this).uri.toString();
      return currentLocation.contains('/post-detail/$postId');
    } catch (e) {
      dev.log('Error checking post detail route: $e', name: 'Navigation');
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

  /// Check if we can go back in the navigation stack
  bool canGoBack() {
    try {
      final navigator = Navigator.of(this);
      return navigator.canPop();
    } catch (e) {
      dev.log('Error checking if can go back: $e', name: 'Navigation');
      return false;
    }
  }

  /// Get the number of routes in the navigation stack
  int get routeStackLength {
    try {
      final navigator = Navigator.of(this);
      return (navigator as dynamic).widget.pages?.length ?? 0;
    } catch (e) {
      dev.log('Error getting route stack length: $e', name: 'Navigation');
      return 0;
    }
  }
}
