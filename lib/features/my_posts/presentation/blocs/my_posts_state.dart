import 'package:assignments/features/my_posts/domain/entities/my_post.dart';
import 'package:equatable/equatable.dart';

/// State for MyPostsCubit
class MyPostsState extends Equatable {
  final List<MyPost> posts;
  final bool isLoading;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;
  final String? error;
  final String searchQuery;

  const MyPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
    this.error,
    this.searchQuery = '',
  });

  MyPostsState copyWith({
    List<MyPost>? posts,
    bool? isLoading,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    String? error,
    String? searchQuery,
  }) {
    return MyPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        posts,
        isLoading,
        isCreating,
        isUpdating,
        isDeleting,
        error,
        searchQuery,
      ];
}
