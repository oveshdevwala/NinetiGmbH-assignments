
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/my_post.dart';
import '../../domain/repositories/my_post_repository.dart';
import 'package:equatable/equatable.dart';
part 'my_posts_state.dart';
/// Cubit for managing user's personal posts
class MyPostsCubit extends Cubit<MyPostsState> {
  final MyPostRepository repository;

  MyPostsCubit({required this.repository}) : super(const MyPostsState());

  /// Load all user's posts
  Future<void> loadMyPosts() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final posts = await repository.getAllMyPosts();
      emit(state.copyWith(
        posts: posts,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load posts: ${e.toString()}',
      ));
    }
  }

  /// Create a new post
  Future<void> createPost({
    required String title,
    required String body,
    required String authorName,
    required List<String> tags,
  }) async {
    emit(state.copyWith(isCreating: true, error: null));

    try {
      final newPost = await repository.createMyPost(
        title: title,
        body: body,
        authorName: authorName,
        tags: tags,
      );

      final updatedPosts = [newPost, ...state.posts];
      emit(state.copyWith(
        posts: updatedPosts,
        isCreating: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        error: 'Failed to create post: ${e.toString()}',
      ));
    }
  }

  /// Update an existing post
  Future<void> updatePost(MyPost post) async {
    emit(state.copyWith(isUpdating: true, error: null));

    try {
      final updatedPost = await repository.updateMyPost(post);

      final updatedPosts = state.posts.map((p) {
        return p.id == updatedPost.id ? updatedPost : p;
      }).toList();

      emit(state.copyWith(
        posts: updatedPosts,
        isUpdating: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        error: 'Failed to update post: ${e.toString()}',
      ));
    }
  }

  /// Delete a post
  Future<void> deletePost(int postId) async {
    emit(state.copyWith(isDeleting: true, error: null));

    try {
      await repository.deleteMyPost(postId);

      final updatedPosts = state.posts.where((p) => p.id != postId).toList();
      emit(state.copyWith(
        posts: updatedPosts,
        isDeleting: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        error: 'Failed to delete post: ${e.toString()}',
      ));
    }
  }

  /// Search posts
  Future<void> searchPosts(String query) async {
    emit(state.copyWith(searchQuery: query, isLoading: true, error: null));

    try {
      final posts = query.isEmpty
          ? await repository.getAllMyPosts()
          : await repository.searchMyPosts(query);

      emit(state.copyWith(
        posts: posts,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to search posts: ${e.toString()}',
      ));
    }
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Refresh posts
  Future<void> refresh() async {
    await loadMyPosts();
  }
}
