
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/my_posts_cubit.dart';
import '../widgets/my_post_card.dart';
import '../../../home/presentation/widgets/empty_posts_widget.dart';
import '../../../../shared/widgets/app_search_bar.dart';
import '../../../../core/router/app_router.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load posts when page is initialized
    context.read<MyPostsCubit>().loadMyPosts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MyPostsCubit>().refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppSearchBar(
              controller: _searchController,
              hintText: 'Search my posts...',
              onChanged: (query) {
                context.read<MyPostsCubit>().searchPosts(query);
              },
              onClear: () {
                _searchController.clear();
                context.read<MyPostsCubit>().searchPosts('');
              },
            ),
          ),

          // Posts List
          Expanded(
            child: BlocConsumer<MyPostsCubit, MyPostsState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      action: SnackBarAction(
                        label: 'Dismiss',
                        onPressed: () =>
                            context.read<MyPostsCubit>().clearError(),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.isLoading && state.posts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.posts.isEmpty) {
                  return EmptyPostsWidget(
                    searchQuery: state.searchQuery,
                    onCreatePost: () => _navigateToCreatePost(context),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => context.read<MyPostsCubit>().refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: state.posts.length,
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return MyPostCard(
                        post: post,
                        onTap: () => _navigateToPostDetail(context, post.id),
                        onEdit: () => _navigateToEditPost(context, post),
                        onDelete: () => _showDeleteDialog(context, post),
                        isDeleting: state.isDeleting,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<MyPostsCubit, MyPostsState>(
        builder: (context, state) {
          return FloatingActionButton(
            onPressed:
                state.isCreating ? null : () => _navigateToCreatePost(context),
            tooltip: 'Create New Post',
            child: state.isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.add),
          );
        },
      ),
    );
  }

  void _navigateToCreatePost(BuildContext context) {
    context.push(AppPaths.createMyPost);
  }

  void _navigateToEditPost(BuildContext context, dynamic post) {
    context.push('${AppPaths.editMyPost}/${post.id}', extra: post);
  }

  void _navigateToPostDetail(BuildContext context, int postId) {
    // Find the post object from the current state
    final state = context.read<MyPostsCubit>().state;
    final post = state.posts.where((p) => p.id == postId).firstOrNull;

    if (post == null) {
      // Show error if post not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.push('${AppPaths.myPostDetail}/$postId', extra: post);
  }

  void _showDeleteDialog(BuildContext context, dynamic post) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: Text('Are you sure you want to delete "${post.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<MyPostsCubit>().deletePost(post.id);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
