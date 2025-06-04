import 'dart:developer';

import 'package:assignments/features/home/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/post_bloc/posts_bloc.dart';
import '../blocs/scroll_cubit/scroll_cubit.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import 'floating_scroll_buttons.dart';
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
    if (!mounted) return;

    final bloc = context.read<PostsBloc>();
    final state = bloc.state;

    // Don't trigger if already loading more or reached max
    if (state.isLoadingMore || state.hasReachedMax) {
      return;
    }

    if (_isBottom) {
      // Debug log to check if pagination is triggered
      log('PostsTab: Pagination triggered - loading more posts');
      log('PostsTab: Current posts count: ${state.posts.length}');
      log('PostsTab: Current page: ${state.currentPage}');
      log('PostsTab: Has reached max: ${state.hasReachedMax}');

      context.read<PostsBloc>().add(const LoadMorePostsEvent());
    }
  }

  bool get _isBottom {
    if (_scrollController == null || !_scrollController!.hasClients) {
      return false;
    }

    final position = _scrollController!.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;

    // More sensitive scroll detection - trigger at 80% scroll
    final threshold = maxScroll * 0.8;
    final shouldLoadMore = currentScroll >= threshold;

    // Debug log for scroll position (only when close to bottom)
    if (currentScroll >= maxScroll * 0.7) {
      log(
          'PostsTab: Scroll position: ${currentScroll.toStringAsFixed(0)} / ${maxScroll.toStringAsFixed(0)} (${(currentScroll / maxScroll * 100).toStringAsFixed(1)}%)');
      if (shouldLoadMore) {
        log('PostsTab: ✅ Threshold reached for pagination');
      }
    }

    return shouldLoadMore;
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
                                  // Enhanced loading indicator for pagination
                                  return Container(
                                    padding: const EdgeInsets.all(24),
                                    margin: const EdgeInsets.fromLTRB(
                                        16, 8, 16, 16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest
                                          .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colorScheme.primary
                                            .withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Loading more posts...',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return null;
                              },
                              childCount: state.posts.length +
                                  (state.isLoadingMore ? 1 : 0),
                            ),
                          ),
                          // Pagination footer
                          SliverToBoxAdapter(
                            child: BlocBuilder<PostsBloc, PostsState>(
                              builder: (context, state) {
                                if (state.hasReachedMax &&
                                    state.posts.isNotEmpty) {
                                  return Container(
                                    padding: const EdgeInsets.all(24),
                                    margin: const EdgeInsets.fromLTRB(
                                        16, 8, 16, 16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest
                                          .withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colorScheme.outline
                                            .withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 20,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'You\'ve reached the end!',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (!state.isLoadingMore &&
                                    state.posts.length >= 30) {
                                  // Show "scroll for more" hint only if we have a substantial number of posts
                                  return Container(
                                    padding: const EdgeInsets.all(16),
                                    margin: const EdgeInsets.fromLTRB(
                                        16, 8, 16, 16),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 20,
                                          color: colorScheme.primary
                                              .withOpacity(0.6),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Scroll down for more posts',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onSurface
                                                .withOpacity(0.5),
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox(
                                    height: 80); // Default spacing
                              },
                            ),
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
