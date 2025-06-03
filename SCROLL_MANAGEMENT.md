# Advanced Scroll Management System

## Overview

This implementation provides a robust scroll management system for Flutter applications using Bloc pattern (without Freezed). The system includes:

1. **Scroll Position Storage**: Automatically saves and restores scroll positions when switching between tabs
2. **Floating Action Buttons**: Smart floating buttons for scroll-to-top and scroll-to-bottom functionality
3. **Tab-Aware Scrolling**: Different scroll positions maintained for different tabs
4. **Smooth Animations**: All scroll operations include smooth animations

## Architecture

### Core Components

#### 1. ScrollCubit (`lib/features/users/presentation/blocs/scroll_cubit.dart`)

**Single State Class with copyWith method:**
```dart
class ScrollState {
  final Map<TabType, double> scrollPositions;
  final ScrollDirection scrollDirection;
  final bool isAtTop;
  final bool isAtBottom;
  final bool showFloatingButtons;
  final double currentScrollOffset;
  final TabType currentTab;
  final bool canScrollToTop;
  final bool canScrollToBottom;
}
```

**Key Features:**
- ✅ Single state class (no Freezed)
- ✅ Manual copyWith implementation
- ✅ Tab-specific position storage
- ✅ Real-time scroll state tracking
- ✅ Direction detection
- ✅ Floating button visibility logic

#### 2. FloatingScrollButtons (`lib/shared/widgets/floating_scroll_buttons.dart`)

**Reusable Widget Features:**
- ✅ Animated slide-in/slide-out
- ✅ Pulse animations for visual feedback
- ✅ Theme-aware styling
- ✅ Tooltip support
- ✅ Conditional visibility (show only when needed)
- ✅ Smooth scroll animations

#### 3. Tab Integration

**PostsTab & TodosTab:**
- ✅ Automatic scroll controller attachment
- ✅ Position saving on disposal
- ✅ Integrated with ScrollCubit
- ✅ Proper memory management

## Implementation Details

### Tab Switching & Position Storage

```dart
// HomePage handles tab switching
_tabController.addListener(() {
  if (_tabController.index != _selectedIndex) {
    final scrollCubit = context.read<ScrollCubit>();
    if (_selectedIndex == 0) {
      scrollCubit.setCurrentTab(TabType.posts);
    } else {
      scrollCubit.setCurrentTab(TabType.todos);
    }
  }
});
```

### Scroll Position Restoration

```dart
// ScrollCubit automatically restores position
void setCurrentTab(TabType tab) {
  emit(state.copyWith(currentTab: tab));
  
  final savedPosition = state.getScrollPositionForTab(tab);
  if (_currentScrollController != null && savedPosition > 0) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currentScrollController!.hasClients) {
        _currentScrollController!.animateTo(
          savedPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
```

### Floating Button Logic

```dart
// Smart visibility based on scroll position and content
final showFloatingButtons = currentOffset > 100 && maxScrollExtent > 0;
final canScrollToTop = currentOffset > 50;
final canScrollToBottom = currentOffset < maxScrollExtent - 50;
```

## Usage Guide

### 1. Basic Setup

The ScrollCubit is provided at the app level in `bootstrap.dart`:

```dart
MultiBlocProvider(
  providers: [
    BlocProvider<ScrollCubit>(
      create: (context) => ScrollCubit(),
    ),
    // ... other blocs
  ],
  // ...
)
```

### 2. Tab Integration

Each scrollable tab needs to:

```dart
class _YourTabState extends State<YourTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Attach to ScrollCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScrollCubit>().attachScrollController(_scrollController);
    });
  }

  @override
  void dispose() {
    // Save position before disposing
    context.read<ScrollCubit>().saveScrollPosition();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Your scrollable content
        CustomScrollView(
          controller: _scrollController,
          // ... your slivers
        ),
        
        // Add floating buttons
        const FloatingScrollButtons(),
      ],
    );
  }
}
```

### 3. Tab Controller Integration

```dart
_tabController.addListener(() {
  if (_tabController.index != _selectedIndex) {
    setState(() {
      _selectedIndex = _tabController.index;
    });
    
    // Update ScrollCubit with new tab
    final scrollCubit = context.read<ScrollCubit>();
    if (_selectedIndex == 0) {
      scrollCubit.setCurrentTab(TabType.posts);
    } else {
      scrollCubit.setCurrentTab(TabType.todos);
    }
  }
});
```

## Features Demonstrated

### ✅ Advanced Scroll Position Management
- **Multiple Tab Support**: Each tab maintains its own scroll position
- **Automatic Saving**: Positions saved when switching tabs or disposing widgets
- **Smooth Restoration**: Animated scroll to previous position when returning to tab
- **Memory Efficient**: Proper cleanup of scroll controllers

### ✅ Floating Navigation Buttons
- **Smart Visibility**: Only show when user has scrolled and content is scrollable
- **Conditional Display**: Show top button when scrolled down, bottom button when not at bottom
- **Smooth Animations**: Elastic slide-in/out animations with pulse effects
- **Theme Integration**: Buttons adapt to app theme and color scheme

### ✅ Real-time Scroll State Tracking
- **Direction Detection**: Track whether user is scrolling up or down
- **Position Awareness**: Know if at top, bottom, or middle of content
- **Performance Optimized**: Efficient state updates without unnecessary rebuilds

### ✅ Robust State Management
- **Single State Class**: Following Flutter Bloc guidelines without Freezed
- **Manual copyWith**: Clean, readable state updates
- **Proper Error Handling**: Graceful handling of edge cases
- **Memory Management**: Automatic cleanup of resources

## Customization

### FloatingScrollButtons Customization

```dart
const FloatingScrollButtons(
  margin: EdgeInsets.only(right: 20, bottom: 100),
  buttonSize: 56.0,
  primaryColor: Colors.blue,
  backgroundColor: Colors.white,
)
```

### Scroll Behavior Customization

```dart
// In ScrollCubit, modify these values:
final showFloatingButtons = currentOffset > 150; // Custom threshold
final canScrollToTop = currentOffset > 75; // Custom sensitivity
```

## Testing

The implementation includes:
- ✅ Real-time scroll position tracking
- ✅ Tab switching with position retention
- ✅ Floating button visibility logic
- ✅ Smooth animations for all scroll operations
- ✅ Proper memory management
- ✅ Theme integration

## Performance Considerations

1. **Efficient Updates**: ScrollCubit only emits when scroll state actually changes
2. **Memory Management**: Proper disposal of controllers and listeners
3. **Animation Optimization**: Uses efficient animation controllers
4. **Selective Rebuilds**: BlocBuilder used strategically to minimize rebuilds

## File Structure

```
lib/
├── features/users/presentation/blocs/
│   └── scroll_cubit.dart                 # Core scroll management
├── shared/widgets/
│   └── floating_scroll_buttons.dart     # Reusable floating buttons
├── features/users/presentation/widgets/
│   ├── posts_tab.dart                   # Posts tab with scroll integration
│   └── todos_tab.dart                   # Todos tab with scroll integration
└── features/users/presentation/pages/
    └── home_page.dart                   # Tab controller integration
```

This implementation provides a production-ready, robust scroll management system that enhances user experience while maintaining clean architecture and following Flutter best practices.

# Scroll Management & Tab Switching Error Fix

## Problem Analysis

The error "Looking up a deactivated widget's ancestor is unsafe" was occurring during tab switching because:

1. **Widget Disposal Order**: When switching tabs, the old tab widget (PostsTab or TodosTab) gets disposed
2. **Context Access During Disposal**: During disposal, the widgets were calling `context.read<ScrollCubit>().saveScrollPosition()`
3. **Invalid Context**: By disposal time, the widget's context is deactivated/invalid, causing the error
4. **Async Operations**: Some operations were happening in `WidgetsBinding.instance.addPostFrameCallback` after disposal

## Root Causes

### 1. Direct Context Access in dispose()
```dart
// ❌ PROBLEMATIC CODE
@override
void dispose() {
  context.read<ScrollCubit>().saveScrollPosition(); // This causes the error!
  _scrollController.dispose();
  super.dispose();
}
```

### 2. Missing Widget Lifecycle Checks
- No checks for `mounted` property
- No try-catch blocks for disposal edge cases
- Missing null checks for scroll controllers

### 3. ScrollController Management Issues
- Not properly detaching scroll controllers
- Not removing listeners before disposal

## Solution Implementation

### 1. Safe Widget Reference Pattern
```dart
class _PostsTabState extends State<PostsTab> {
  late ScrollController _scrollController;
  ScrollCubit? _scrollCubit; // ✅ Keep direct reference

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // ✅ Check mounted state
        _scrollCubit = context.read<ScrollCubit>(); // ✅ Store reference
        _scrollCubit?.attachScrollController(_scrollController);
      }
    });
  }

  @override
  void dispose() {
    // ✅ Safe disposal pattern
    if (mounted && _scrollCubit != null) {
      try {
        _scrollCubit!.saveScrollPosition();
        _scrollCubit!.detachScrollController();
      } catch (e) {
        // Ignore errors during disposal
      }
    }
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }
}
```

### 2. Defensive ScrollCubit Implementation
```dart
class ScrollCubit extends Cubit<ScrollState> {
  ScrollController? _currentScrollController;

  void _updateScrollState() {
    if (_currentScrollController == null ||
        !_currentScrollController!.hasClients) {
      return;
    }

    try {
      // ✅ Wrap in try-catch for safety
      final position = _currentScrollController!.position;
      // ... update logic
    } catch (e) {
      // Ignore errors during state updates if widget is disposed
    }
  }

  void scrollToTop() {
    if (_currentScrollController != null &&
        _currentScrollController!.hasClients &&
        state.canScrollToTop) {
      try {
        // ✅ Safe scroll animation
        _currentScrollController!.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } catch (e) {
        // Ignore errors during animation if widget is disposed
      }
    }
  }
}
```

### 3. Protected Context Access
```dart
// ✅ Safe context access in event handlers
void _handleTabChange() {
  if (!mounted) return;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      try {
        final scrollCubit = context.read<ScrollCubit>();
        scrollCubit.setCurrentTab(TabType.posts);
      } catch (e) {
        // Ignore errors if widget is disposed
      }
    }
  });
}
```

## Best Practices

### 1. Widget Lifecycle Management
- **Always check `mounted`** before accessing context in async operations
- **Store direct references** to BLoCs/Cubits when needed during disposal
- **Use try-catch blocks** around context access during cleanup

### 2. ScrollController Management
- **Remove listeners** before disposing controllers
- **Detach controllers** from state management before disposal
- **Check `hasClients`** before performing scroll operations

### 3. Async Operation Safety
- **Wrap PostFrameCallback operations** in mounted checks
- **Handle disposal gracefully** in all async operations
- **Use defensive programming** for edge cases

### 4. Error Handling Pattern
```dart
// ✅ Standard error handling pattern for widget disposal
try {
  // Operation that might fail during disposal
  context.read<SomeCubit>().someMethod();
} catch (e) {
  // Ignore errors during disposal - widget lifecycle is ending
}
```

## Fixed Files

1. **`lib/features/users/presentation/widgets/posts_tab.dart`**
   - Added safe ScrollCubit reference management
   - Protected disposal with mounted checks and try-catch

2. **`lib/features/users/presentation/widgets/todos_tab.dart`**
   - Applied same disposal safety pattern
   - Added proper scroll controller cleanup

3. **`lib/features/users/presentation/blocs/scroll_cubit.dart`**
   - Added defensive programming throughout
   - Protected all scroll operations with try-catch blocks

4. **`lib/features/users/presentation/pages/home_page.dart`**
   - Protected tab change handling
   - Added safety checks for async operations

5. **`lib/shared/widgets/floating_scroll_buttons.dart`**
   - Added try-catch around ScrollCubit method calls
   - Protected against disposal edge cases

## Result

- ✅ **Tab switching now works without errors**
- ✅ **Scroll position is preserved between tabs**
- ✅ **Floating scroll buttons work correctly**
- ✅ **No more "deactivated widget's ancestor" errors**
- ✅ **Robust error handling during widget disposal**

## Testing Recommendations

1. **Tab Switching**: Rapidly switch between tabs multiple times
2. **Scroll State**: Scroll in one tab, switch to another, then back
3. **Edge Cases**: Test during app backgrounding/foregrounding
4. **Performance**: Ensure no memory leaks from retained references

This fix follows Flutter best practices for widget lifecycle management and provides a robust foundation for scroll state management across tab-based navigation. 