part of 'scroll_cubit.dart';
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
