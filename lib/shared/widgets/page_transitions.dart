import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for different navigation patterns
extension PageTransitions on GoRouterState {
  /// No transition - for bottom nav tabs
  Page<T> toNoTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return NoTransitionPage<T>(
      key: ValueKey(fullPath),
      name: name ?? fullPath,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
    );
  }

  /// Fade transition - for splash, login, etc.
  Page<T> toFadeTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(fullPath),
      name: name ?? fullPath,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation.drive(
            Tween(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: Curves.easeInOut),
            ),
          ),
          child: child,
        );
      },
    );
  }

  /// Right to left slide transition - for detail pages
  Page<T> toRightToLeftPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(fullPath),
      name: name ?? fullPath,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Bottom to top slide transition - for modal-style pages
  Page<T> toBottomToTopPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(fullPath),
      name: name ?? fullPath,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Scale transition - for emphasis
  Page<T> toScaleTransitionPage<T extends Object?>({
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage<T>(
      key: ValueKey(fullPath),
      name: name ?? fullPath,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation.drive(
            Tween(begin: 0.8, end: 1.0).chain(
              CurveTween(curve: Curves.easeOutBack),
            ),
          ),
          child: FadeTransition(
            opacity: animation.drive(
              Tween(begin: 0.0, end: 1.0).chain(
                CurveTween(curve: Curves.easeInOut),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Custom page with no transition
class NoTransitionPage<T> extends Page<T> {
  const NoTransitionPage({
    required this.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
    );
  }
}
