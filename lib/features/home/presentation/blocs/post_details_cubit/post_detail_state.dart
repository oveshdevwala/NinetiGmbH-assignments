
part of 'post_detail_cubit.dart';
class PostDetailState extends Equatable {
  final Post? post;
  final User? user;
  final List<Post> userPosts;
  final List<Todo> userTodos;
  final bool isLoading;
  final bool isLoadingUserData;
  final bool isLoadingUserPosts;
  final bool isLoadingUserTodos;
  final String? error;

  const PostDetailState({
    this.post,
    this.user,
    this.userPosts = const [],
    this.userTodos = const [],
    this.isLoading = false,
    this.isLoadingUserData = false,
    this.isLoadingUserPosts = false,
    this.isLoadingUserTodos = false,
    this.error,
  });

  PostDetailState copyWith({
    Post? post,
    User? user,
    List<Post>? userPosts,
    List<Todo>? userTodos,
    bool? isLoading,
    bool? isLoadingUserData,
    bool? isLoadingUserPosts,
    bool? isLoadingUserTodos,
    String? error,
  }) {
    return PostDetailState(
      post: post ?? this.post,
      user: user ?? this.user,
      userPosts: userPosts ?? this.userPosts,
      userTodos: userTodos ?? this.userTodos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingUserData: isLoadingUserData ?? this.isLoadingUserData,
      isLoadingUserPosts: isLoadingUserPosts ?? this.isLoadingUserPosts,
      isLoadingUserTodos: isLoadingUserTodos ?? this.isLoadingUserTodos,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        post,
        user,
        userPosts,
        userTodos,
        isLoading,
        isLoadingUserData,
        isLoadingUserPosts,
        isLoadingUserTodos,
        error,
      ];
}
