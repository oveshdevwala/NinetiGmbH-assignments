

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/todos_bloc/todos_bloc.dart';
import '../blocs/scroll_cubit/scroll_cubit.dart';
import 'todo_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import 'floating_scroll_buttons.dart';

class TodosTab extends StatefulWidget {
  const TodosTab({super.key});

  @override
  State<TodosTab> createState() => _TodosTabState();
}

class _TodosTabState extends State<TodosTab>
    with AutomaticKeepAliveClientMixin {
  ScrollController? _scrollController;

  @override
  bool get wantKeepAlive => true; // Keep tab alive to preserve scroll position

  @override
  void initState() {
    super.initState();

    // Get the scroll controller for todos tab from ScrollCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final scrollCubit = context.read<ScrollCubit>();
        _scrollController = scrollCubit.getScrollController(TabType.todos);

        // Add pagination listener
        _scrollController?.addListener(_onScroll);
      }
    });

    // Load todos data
    if (mounted) {
      context.read<TodosBloc>().add(const LoadAllTodosEvent());
    }
  }

  @override
  void dispose() {
    // Remove pagination listener but keep the scroll controller
    // as it's managed by ScrollCubit
    _scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TodosBloc>().add(const LoadMoreTodosEvent());
    }
  }

  bool get _isBottom {
    if (_scrollController == null || !_scrollController!.hasClients) {
      return false;
    }
    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.offset;
    return currentScroll >= (maxScroll * 0.9); // Load more when 90% scrolled
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          color: theme.colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BlocBuilder<TodosBloc, TodosState>(
                  builder: (context, state) {
                    if (state.isLoading && state.todos.isEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 8,
                        itemBuilder: (context, index) => Container(
                          height: 60,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const LoadingIndicator(useShimmer: true),
                        ),
                      );
                    }

                    if (state.error != null && state.todos.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: theme.colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading todos',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: () {
                                context
                                    .read<TodosBloc>()
                                    .add(const LoadAllTodosEvent());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<TodosBloc>()
                                  .add(const RefreshTodosEvent());
                            },
                            color: theme.colorScheme.secondary,
                            child: CustomScrollView(
                              key: ScrollCubit.getPageKeyForTab(
                                  TabType.todos), // Page storage key
                              controller: _scrollController,
                              slivers: [
                                SliverToBoxAdapter(
                                  child: _todosHeaderWidget(theme),
                                ),
                                SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      if (index < state.todos.length) {
                                        final todo = state.todos[index];
                                        return Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 0, 16, 8),
                                          child: TodoCard(
                                            todo: todo,
                                            onCompletedChanged: (completed) {
                                              // Handle todo completion toggle
                                              // Note: This would require implementing
                                              // a toggle event in TodosBloc if needed
                                            },
                                          ),
                                        );
                                      } else if (index == state.todos.length &&
                                          state.isLoadingMore) {
                                        return Container(
                                          height: 60,
                                          margin: const EdgeInsets.fromLTRB(
                                              16, 0, 16, 8),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme
                                                .surfaceContainerHighest
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const LoadingIndicator(
                                              useShimmer: true),
                                        );
                                      }
                                      return null;
                                    },
                                    childCount: state.todos.length +
                                        (state.isLoadingMore ? 1 : 0),
                                  ),
                                ),
                                // Add some bottom padding
                                const SliverToBoxAdapter(
                                  child: SizedBox(
                                      height:
                                          80), // Extra space for floating buttons
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // Floating scroll buttons
        const FloatingScrollButtons(),
      ],
    );
  }

  Container _todosHeaderWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          // Icon with gradient background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.secondary.withOpacity(0.8),
                  theme.colorScheme.tertiary.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.checklist,
              color: theme.colorScheme.onSecondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Todos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Track tasks & productivity',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Quick completion stats
          BlocBuilder<TodosBloc, TodosState>(
            builder: (context, state) {
              if (state.todos.isNotEmpty) {
                final completedCount =
                    state.todos.where((todo) => todo.completed).length;
                final totalCount = state.todos.length;
                final completionPercentage = totalCount > 0
                    ? (completedCount / totalCount * 100).round()
                    : 0;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.secondaryContainer.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.secondary.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 12,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$completionPercentage%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
