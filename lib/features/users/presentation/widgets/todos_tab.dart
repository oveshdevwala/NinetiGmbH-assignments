import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/todos_bloc.dart';
import '../widgets/todo_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class TodosTab extends StatefulWidget {
  const TodosTab({super.key});

  @override
  State<TodosTab> createState() => _TodosTabState();
}

class _TodosTabState extends State<TodosTab> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Use preloaded data - no need to reload
    context.read<TodosBloc>().add(const LoadAllTodosEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TodosBloc>().add(const LoadMoreTodosEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9); // Load more when 90% scrolled
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
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
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.errorContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.error.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: theme.colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Oops! Something went wrong',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.error!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<TodosBloc>()
                                  .add(const RefreshTodosEvent());
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state.todos.isEmpty) {
                  return Center(
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.secondary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.checklist_outlined,
                              size: 48,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No todos available',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All tasks completed or none created yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
                                        onTap: () {
                                          // Handle todo tap
                                        },
                                        onCompletedChanged: (value) {
                                          // Handle todo completion toggle
                                          // You can add an event to update todo completion
                                        },
                                      ),
                                    );
                                  } else {
                                    // Show loading indicator at the bottom
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: state.isLoadingMore
                                            ? const CircularProgressIndicator()
                                            : const SizedBox.shrink(),
                                      ),
                                    );
                                  }
                                },
                                childCount: state.todos.length +
                                    (state.isLoadingMore ? 1 : 0),
                              ),
                            ),
                            // Add some bottom padding
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 16),
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
