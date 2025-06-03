import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main app scaffold with bottom navigation
class AppScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outlined),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

/// Enum for navigation tabs
enum NavigationTab {
  home,
  users,
  profile,
}

/// Extension to get paths for navigation tabs
extension NavigationTabExtension on NavigationTab {
  String get path {
    switch (this) {
      case NavigationTab.home:
        return '/home';
      case NavigationTab.users:
        return '/users';
      case NavigationTab.profile:
        return '/profile';
    }
  }

  String get name {
    switch (this) {
      case NavigationTab.home:
        return 'home';
      case NavigationTab.users:
        return 'users';
      case NavigationTab.profile:
        return 'profile';
    }
  }
}
