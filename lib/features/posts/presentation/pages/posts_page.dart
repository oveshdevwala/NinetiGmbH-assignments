import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../users/presentation/blocs/posts_bloc.dart';
import '../../../users/presentation/widgets/post_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedTag = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Load posts and start animation
    context.read<PostsBloc>().add(const LoadInitialPostsEvent());
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterPosts(List<dynamic> posts) {
    if (_searchQuery.isEmpty && _selectedTag.isEmpty) return posts;

    return posts.where((post) {
      final matchesSearch = _searchQuery.isEmpty ||
          post.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          post.body.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesTag = _selectedTag.isEmpty ||
          post.tags
              .any((tag) => tag.toLowerCase() == _selectedTag.toLowerCase());

      return matchesSearch && matchesTag;
    }).toList();
  }

  Set<String> _getAllTags(List<dynamic> posts) {
    final Set<String> allTags = {};
    for (var post in posts) {
      allTags.addAll(post.tags.cast<String>());
    }
    return allTags;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: FadeTransition(
        opacity: _animation,
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(theme),
            _buildSearchAndFilter(theme),
            _buildPostsList(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.primary.withOpacity(0.3),
                theme.colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.article_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Posts',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Discover amazing stories and insights',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        title: Text(
          'Posts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search posts...',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tags Filter
            BlocBuilder<PostsBloc, PostsState>(
              builder: (context, state) {
                if (state.posts.isEmpty) return const SizedBox.shrink();

                final allTags = _getAllTags(state.posts).toList()..sort();
                if (allTags.isEmpty) return const SizedBox.shrink();

                return SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: allTags.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildTagChip(
                          'All',
                          _selectedTag.isEmpty,
                          theme,
                          () {
                            setState(() {
                              _selectedTag = '';
                            });
                          },
                        );
                      }

                      final tag = allTags[index - 1];
                      return _buildTagChip(
                        '#$tag',
                        _selectedTag == tag,
                        theme,
                        () {
                          setState(() {
                            _selectedTag = _selectedTag == tag ? '' : tag;
                          });
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(
      String label, bool isSelected, ThemeData theme, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        selectedColor: theme.colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        showCheckmark: false,
      ),
    );
  }

  Widget _buildPostsList(ThemeData theme) {
    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(
                height: 200,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const LoadingIndicator(useShimmer: true),
              ),
              childCount: 6,
            ),
          );
        }

        if (state.error != null) {
          return SliverFillRemaining(
            child: Center(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load posts',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        context
                            .read<PostsBloc>()
                            .add(const RefreshPostsEvent());
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final filteredPosts = _filterPosts(state.posts);

        if (filteredPosts.isEmpty) {
          return SliverFillRemaining(
            child: Center(
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
                    Icon(
                      _searchQuery.isNotEmpty || _selectedTag.isNotEmpty
                          ? Icons.search_off_rounded
                          : Icons.article_outlined,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty || _selectedTag.isNotEmpty
                          ? 'No posts found'
                          : 'No posts available',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _searchQuery.isNotEmpty || _selectedTag.isNotEmpty
                          ? 'Try adjusting your search or filter'
                          : 'Check back later for new content',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = filteredPosts[index];
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: PostCard(
                  post: post,
                  onTap: () {
                    // Navigate to post detail
                  },
                ),
              );
            },
            childCount: filteredPosts.length,
          ),
        );
      },
    );
  }
}
