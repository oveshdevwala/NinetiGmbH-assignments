import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Enum for scroll direction
enum ScrollDirection { up, down, idle }

// Enum for tab types
enum TabType { posts, todos }

// Single state class with copyWith method
class ScrollState {
  final Map<TabType, double> scrollPositions;
  final Map<TabType, ScrollController> scrollControllers;
  final ScrollDirection scrollDirection;
  final bool isAtTop;
  final bool isAtBottom;
  final bool showFloatingButtons;
  final double currentScrollOffset;
  final TabType currentTab;
  final bool canScrollToTop;
  final bool canScrollToBottom;

  const ScrollState({
    this.scrollPositions = const {},
    this.scrollControllers = const {},
    this.scrollDirection = ScrollDirection.idle,
    this.isAtTop = true,
    this.isAtBottom = false,
    this.showFloatingButtons = false,
    this.currentScrollOffset = 0.0,
    this.currentTab = TabType.posts,
    this.canScrollToTop = false,
    this.canScrollToBottom = false,
  });

  ScrollState copyWith({
    Map<TabType, double>? scrollPositions,
    Map<TabType, ScrollController>? scrollControllers,
    ScrollDirection? scrollDirection,
    bool? isAtTop,
    bool? isAtBottom,
    bool? showFloatingButtons,
    double? currentScrollOffset,
    TabType? currentTab,
    bool? canScrollToTop,
    bool? canScrollToBottom,
  }) {
    return ScrollState(
      scrollPositions: scrollPositions ?? this.scrollPositions,
      scrollControllers: scrollControllers ?? this.scrollControllers,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      isAtTop: isAtTop ?? this.isAtTop,
      isAtBottom: isAtBottom ?? this.isAtBottom,
      showFloatingButtons: showFloatingButtons ?? this.showFloatingButtons,
      currentScrollOffset: currentScrollOffset ?? this.currentScrollOffset,
      currentTab: currentTab ?? this.currentTab,
      canScrollToTop: canScrollToTop ?? this.canScrollToTop,
      canScrollToBottom: canScrollToBottom ?? this.canScrollToBottom,
    );
  }

  // Get scroll position for specific tab
  double getScrollPositionForTab(TabType tab) {
    return scrollPositions[tab] ?? 0.0;
  }

  // Get scroll controller for specific tab
  ScrollController? getScrollControllerForTab(TabType tab) {
    return scrollControllers[tab];
  }
}

// Cubit for managing scroll state with separate controllers for each tab
class ScrollCubit extends Cubit<ScrollState> {
  // Global keys for each tab's scrollable widget
  static final GlobalKey<ScrollableState> postsScrollKey =
      GlobalKey<ScrollableState>();
  static final GlobalKey<ScrollableState> todosScrollKey =
      GlobalKey<ScrollableState>();

  // Page storage keys for preserving scroll positions
  static const PageStorageKey<String> postsPageKey =
      PageStorageKey<String>('posts_tab');
  static const PageStorageKey<String> todosPageKey =
      PageStorageKey<String>('todos_tab');

  // Current active scroll controller
  ScrollController? _currentScrollController;
  double _lastScrollOffset = 0.0;

  ScrollCubit() : super(const ScrollState()) {
    // Initialize scroll controllers for each tab
    _initializeScrollControllers();
  }

  void _initializeScrollControllers() {
    final Map<TabType, ScrollController> controllers = {
      TabType.posts: ScrollController(),
      TabType.todos: ScrollController(),
    };

    emit(state.copyWith(scrollControllers: controllers));

    // Add listeners to all controllers
    for (final entry in controllers.entries) {
      entry.value.addListener(() => _onScroll(entry.key));
    }
  }

  // Get global key for specific tab
  static GlobalKey<ScrollableState> getGlobalKeyForTab(TabType tab) {
    switch (tab) {
      case TabType.posts:
        return postsScrollKey;
      case TabType.todos:
        return todosScrollKey;
    }
  }

  // Get page storage key for specific tab
  static PageStorageKey<String> getPageKeyForTab(TabType tab) {
    switch (tab) {
      case TabType.posts:
        return postsPageKey;
      case TabType.todos:
        return todosPageKey;
    }
  }

  // Set current tab and restore scroll position
  void setCurrentTab(TabType tab) {
    // Save current tab's scroll position before switching
    _saveCurrentScrollPosition();

    emit(state.copyWith(currentTab: tab));

    // Set the active scroll controller
    _currentScrollController = state.scrollControllers[tab];

    // Restore scroll position for the new tab if available
    final savedPosition = state.getScrollPositionForTab(tab);
    if (_currentScrollController != null &&
        _currentScrollController!.hasClients &&
        savedPosition > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_currentScrollController != null &&
            _currentScrollController!.hasClients) {
          try {
            _currentScrollController!.animateTo(
              savedPosition,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } catch (e) {
            // Ignore errors during animation if widget is disposed
          }
        }
      });
    }

    // Update scroll state for the new tab
    _updateScrollState();
  }

  // Get scroll controller for specific tab (public method)
  ScrollController? getScrollController(TabType tab) {
    return state.scrollControllers[tab];
  }

  // Internal scroll listener with tab-specific handling
  void _onScroll(TabType tab) {
    // Only update if this is the current active tab
    if (tab != state.currentTab) return;

    final controller = state.scrollControllers[tab];
    if (controller == null || !controller.hasClients) {
      return;
    }

    try {
      _updateScrollState();
    } catch (e) {
      // Ignore errors during scroll updates if widget is disposed
    }
  }

  // Update scroll state based on current scroll position
  void _updateScrollState() {
    final controller = state.scrollControllers[state.currentTab];
    if (controller == null || !controller.hasClients) {
      return;
    }

    try {
      final position = controller.position;
      final currentOffset = position.pixels;
      final maxScrollExtent = position.maxScrollExtent;

      // Determine scroll direction
      ScrollDirection direction = ScrollDirection.idle;
      if (currentOffset > _lastScrollOffset) {
        direction = ScrollDirection.down;
      } else if (currentOffset < _lastScrollOffset) {
        direction = ScrollDirection.up;
      }

      // Check if at top or bottom
      final isAtTop = currentOffset <= 0;
      final isAtBottom = currentOffset >= maxScrollExtent;

      // Show floating buttons if scrolled away from top and there's content to scroll
      final showFloatingButtons = currentOffset > 50 && maxScrollExtent > 100;

      // Can scroll to top/bottom - reduced thresholds for better visibility
      final canScrollToTop = currentOffset > 30;
      final canScrollToBottom = currentOffset < maxScrollExtent - 30;

      // Update saved position for current tab
      final updatedPositions = Map<TabType, double>.from(state.scrollPositions);
      updatedPositions[state.currentTab] = currentOffset;

      emit(state.copyWith(
        scrollPositions: updatedPositions,
        scrollDirection: direction,
        isAtTop: isAtTop,
        isAtBottom: isAtBottom,
        showFloatingButtons: showFloatingButtons,
        currentScrollOffset: currentOffset,
        canScrollToTop: canScrollToTop,
        canScrollToBottom: canScrollToBottom,
      ));

      _lastScrollOffset = currentOffset;
    } catch (e) {
      // Ignore errors during state updates if widget is disposed
    }
  }

  // Save current scroll position manually
  void _saveCurrentScrollPosition() {
    final controller = state.scrollControllers[state.currentTab];
    if (controller != null && controller.hasClients) {
      try {
        final currentOffset = controller.position.pixels;
        final updatedPositions =
            Map<TabType, double>.from(state.scrollPositions);
        updatedPositions[state.currentTab] = currentOffset;

        emit(state.copyWith(scrollPositions: updatedPositions));
      } catch (e) {
        // Ignore errors during saving if widget is disposed
      }
    }
  }

  // Scroll to top with animation
  void scrollToTop() {
    final controller = state.scrollControllers[state.currentTab];
    if (controller != null && controller.hasClients && state.canScrollToTop) {
      try {
        controller.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // Ignore errors during animation if widget is disposed
      }
    }
  }

  // Scroll to bottom with animation
  void scrollToBottom() {
    final controller = state.scrollControllers[state.currentTab];
    if (controller != null &&
        controller.hasClients &&
        state.canScrollToBottom) {
      try {
        final maxScrollExtent = controller.position.maxScrollExtent;
        controller.animateTo(
          maxScrollExtent,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // Ignore errors during animation if widget is disposed
      }
    }
  }

  // Save current scroll position manually (public method)
  void saveScrollPosition() {
    _saveCurrentScrollPosition();
  }

  // Clear saved positions
  void clearScrollPositions() {
    emit(state.copyWith(scrollPositions: {}));
  }

  // Reset scroll state
  void resetScrollState() {
    // Dispose old controllers
    for (final controller in state.scrollControllers.values) {
      controller.dispose();
    }

    // Create new controllers and reset state
    _initializeScrollControllers();
    emit(const ScrollState());
    _initializeScrollControllers();
  }

  @override
  Future<void> close() {
    // Dispose all scroll controllers
    for (final controller in state.scrollControllers.values) {
      controller.dispose();
    }
    return super.close();
  }

  // Legacy methods for backward compatibility (deprecated)
  @Deprecated(
      'Use setCurrentTab instead. This method will be removed in future versions.')
  void attachScrollController(ScrollController controller) {
    // This method is kept for backward compatibility but is deprecated
    // The new implementation uses tab-specific controllers
  }

  @Deprecated(
      'Use setCurrentTab instead. This method will be removed in future versions.')
  void detachScrollController() {
    // This method is kept for backward compatibility but is deprecated
    // The new implementation uses tab-specific controllers
  }
}
