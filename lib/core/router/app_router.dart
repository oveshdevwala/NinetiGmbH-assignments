import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../features/users/presentation/pages/home_page.dart';
import '../../features/users/presentation/pages/user_profile_page.dart';

class AppRouter {
  static const String home = '/';
  static const String userProfile = '/user-profile';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/user-profile/:userId',
        name: 'user-profile',
        builder: (context, state) {
          final userIdParam = state.pathParameters['userId'];
          final userId = int.tryParse(userIdParam ?? '');

          if (userId == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Error'),
              ),
              body: const Center(
                child: Text('Invalid user ID'),
              ),
            );
          }

          return UserProfilePage(userId: userId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go(home);
              },
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
