import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../blocs/posts_bloc.dart';
import '../blocs/todos_bloc.dart';
import '../blocs/scroll_cubit.dart';
import '../widgets/posts_tab.dart';
import '../widgets/todos_tab.dart';
import '../../domain/entities/post.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PostsBloc>().add(const LoadInitialPostsEvent());
        context.read<TodosBloc>().add(const LoadInitialTodosEvent());
        context.read<ScrollCubit>().setCurrentTab(TabType.posts);
      }
    });

    // Start header animation
    _headerAnimationController.forward();

    // Tab controller listener
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!mounted) return;

    if (_tabController.index != _selectedIndex) {
      setState(() {
        _selectedIndex = _tabController.index;
      });

      // Update scroll cubit with new tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            final scrollCubit = context.read<ScrollCubit>();
            if (_selectedIndex == 0) {
              scrollCubit.setCurrentTab(TabType.posts);
            } else {
              scrollCubit.setCurrentTab(TabType.todos);
            }
          } catch (e) {
            // Ignore errors if widget is disposed
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
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
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     // Demo navigation to post detail page
      //     const demoPost = Post(
      //       id: 1,
      //       title: 'Demo Post Title',
      //       body:
      //           'This is a demo post body with some content to demonstrate the post detail page functionality.',
      //       userId: 1,
      //       tags: ['demo', 'flutter', 'example'],
      //       reactions: PostReactions(likes: 42, dislikes: 3),
      //       views: 1234,
      //     );
      //     context.goToPostDetail(demoPost);
      //   },
      //   icon: const Icon(Icons.preview),
      //   label: const Text('Demo Post'),
      // ),
    );
  }

  Widget _buildCompactHeader(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              // App icon
              Container(
                padding: const EdgeInsets.all(10),
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.apps_rounded,
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

          // Material TabBar
          _buildMaterialTabBar(theme),
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

  Widget _buildMaterialTabBar(ThemeData theme) {
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
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text('Posts'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.checklist_outlined,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text('Todos'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
