import 'package:assignments/features/home/domain/entities/post.dart';
import 'package:assignments/features/home/domain/entities/todo.dart';
import 'package:assignments/features/users/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

class UserProfileState extends Equatable {
  final User? user;
  final List<Post> posts;
  final List<Todo> todos;
  final bool isLoading;
  final bool isLoadingPosts;
  final bool isLoadingTodos;
  final String? error;

  const UserProfileState({
    this.user,
    this.posts = const [],
    this.todos = const [],
    this.isLoading = false,
    this.isLoadingPosts = false,
    this.isLoadingTodos = false,
    this.error,
  });

  UserProfileState copyWith({
    User? user,
    List<Post>? posts,
    List<Todo>? todos,
    bool? isLoading,
    bool? isLoadingPosts,
    bool? isLoadingTodos,
    String? error,
  }) {
    return UserProfileState(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      isLoadingTodos: isLoadingTodos ?? this.isLoadingTodos,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        user,
        posts,
        todos,
        isLoading,
        isLoadingPosts,
        isLoadingTodos,
        error,
      ];
}
