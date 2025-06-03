import 'package:assignments/features/users/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/posts_bloc.dart';
import '../blocs/scroll_cubit.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/floating_scroll_buttons.dart';
import '../../../../core/router/app_router.dart';

class PostsTab extends StatefulWidget {
  const PostsTab({super.key});

  @override
  State<PostsTab> createState() => _PostsTabState();
}

class _PostsTabState extends State<PostsTab>
    with AutomaticKeepAliveClientMixin {
  ScrollController? _scrollController;

  @override
  bool get wantKeepAlive => true; // Keep tab alive to preserve scroll position

  @override
  void initState() {
    super.initState();

    // Get the scroll controller for posts tab from ScrollCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final scrollCubit = context.read<ScrollCubit>();
        _scrollController = scrollCubit.getScrollController(TabType.posts);

        // Set this as the current tab
        scrollCubit.setCurrentTab(TabType.posts);

        // Add pagination listener
        _scrollController?.addListener(_onScroll);
      }
    });

    // Load posts data
    if (mounted) {
      context.read<PostsBloc>().add(const LoadAllPostsEvent());
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
      context.read<PostsBloc>().add(const LoadMorePostsEvent());
    }
  }

  bool get _isBottom {
    if (_scrollController == null || !_scrollController!.hasClients)
      return false;
    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.offset;
    return currentScroll >= (maxScroll * 0.9); // Load more when 90% scrolled
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      children: [
        Container(
          color: colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Posts list
              Expanded(
                child: BlocBuilder<PostsBloc, PostsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.posts.isEmpty) {
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 6,
                        itemBuilder: (context, index) => Container(
                          height: 140,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHighest
                                .withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const LoadingIndicator(useShimmer: true),
                        ),
                      );
                    }

                    if (state.error != null && state.posts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: colorScheme.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading posts',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: () {
                                context
                                    .read<PostsBloc>()
                                    .add(const LoadAllPostsEvent());
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context
                            .read<PostsBloc>()
                            .add(const RefreshPostsEvent());
                      },
                      color: colorScheme.primary,
                      child: CustomScrollView(
                        key: ScrollCubit.getPageKeyForTab(
                            TabType.posts), // Page storage key
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: _postHeaderRow(colorScheme, theme),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index < state.posts.length) {
                                  final post = state.posts[index];
                                  return Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 12),
                                    child: PostCard(
                                      post: post,
                                      onTap: () {
                                        // Navigate to post detail page
                                        context.goToPostDetail(post);
                                      },
                                    ),
                                  );
                                } else if (index == state.posts.length &&
                                    state.isLoadingMore) {
                                  return Container(
                                    height: 140,
                                    margin: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 12),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const LoadingIndicator(
                                        useShimmer: true),
                                  );
                                }
                                return null;
                              },
                              childCount: state.posts.length +
                                  (state.isLoadingMore ? 1 : 0),
                            ),
                          ),
                          // Add some bottom padding
                          const SliverToBoxAdapter(
                            child: SizedBox(
                                height: 80), // Extra space for floating buttons
                          ),
                        ],
                      ),
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

  Container _postHeaderRow(ColorScheme colorScheme, ThemeData theme) {
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
                  colorScheme.primary.withOpacity(0.8),
                  colorScheme.tertiary.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.article,
              color: colorScheme.onPrimary,
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
                  'All Posts',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.1,
                  ),
                ),
                Text(
                  'Discover amazing content',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Posts count indicator
          BlocBuilder<PostsBloc, PostsState>(
            builder: (context, state) {
              if (state.posts.isNotEmpty) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.article_outlined,
                        size: 12,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${state.posts.length}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
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
