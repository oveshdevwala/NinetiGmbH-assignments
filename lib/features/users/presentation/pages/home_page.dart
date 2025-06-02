import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/posts_bloc.dart';
import '../blocs/todos_bloc.dart';
import '../widgets/posts_tab.dart';
import '../widgets/todos_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: -50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // Preload initial data only once when app starts
    context.read<PostsBloc>().add(const LoadInitialPostsEvent());
    context.read<TodosBloc>().add(const LoadInitialTodosEvent());

    // Start header animation
    _headerAnimationController.forward();

    _tabController.addListener(() {
      if (_tabController.index != _selectedIndex) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Compact Header
            AnimatedBuilder(
              animation: _headerAnimationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _headerSlideAnimation.value),
                  child: Opacity(
                    opacity: _headerFadeAnimation.value,
                    child: _buildCompactHeader(theme),
                  ),
                );
              },
            ),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  PostsTab(),
                  TodosTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Title with Stats
          Row(
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.dashboard_outlined,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feed & Tasks',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'Discover & organize',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Quick stats
              _buildQuickStats(theme),
            ],
          ),

          const SizedBox(height: 16),

          // Advanced Tab Selector
          _buildAdvancedTabSelector(theme),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, postsState) {
        return BlocBuilder<TodosBloc, TodosState>(
          builder: (context, todosState) {
            final postCount = postsState.posts.length;
            final todoCount = todosState.todos.length;
            final completedTodos =
                todosState.todos.where((todo) => todo.completed).length;

            return Row(
              children: [
                _buildStatChip(
                  icon: Icons.article_outlined,
                  count: postCount,
                  label: 'Posts',
                  color: colorScheme.primary,
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildStatChip(
                  icon: Icons.check_circle_outline,
                  count: completedTodos,
                  label: 'Done',
                  color: colorScheme.tertiary,
                  theme: theme,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedTabSelector(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(
            index: 0,
            icon: Icons.article_outlined,
            selectedIcon: Icons.article,
            label: 'Posts',
            theme: theme,
          ),
          _buildTabButton(
            index: 1,
            icon: Icons.checklist_outlined,
            selectedIcon: Icons.checklist,
            label: 'Todos',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          _tabController.animateTo(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey(isSelected),
                    size: 18,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withOpacity(0.7),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ) ??
                      const TextStyle(),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
