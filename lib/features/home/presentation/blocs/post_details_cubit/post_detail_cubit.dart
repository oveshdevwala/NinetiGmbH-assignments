import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/post.dart';
import '../../../domain/entities/todo.dart';
import '../../../domain/repositories/post_repository.dart';
import '../../../../users/domain/repositories/user_repository.dart';
import '../../../domain/repositories/todo_repository.dart';
import 'package:assignments/features/users/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

part 'post_detail_state.dart';
// Cubit
class PostDetailCubit extends Cubit<PostDetailState> {

  final UserRepository _userRepository;
  
  bool _isDisposed = false;

  PostDetailCubit({
    required PostRepository postRepository,
    required UserRepository userRepository,
    required TodoRepository todoRepository,
  })  :
        _userRepository = userRepository,
        super(const PostDetailState());

  Future<void> loadPostData(Post post) async {
    if (_isDisposed) return;

    try {
      emit(state.copyWith(
        post: post,
        isLoading: false,
        error: null,
      ));

      // Load user data after post is set
      await _loadUserData(post.userId);
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load post data: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> _loadUserData(int userId) async {
    if (_isDisposed) return;

    try {
      emit(state.copyWith(isLoadingUserData: true));

      final result = await _userRepository.getUserById(userId);

      if (_isDisposed) return;

      if (result.isSuccess) {
        if (!_isDisposed) {
          emit(state.copyWith(
            user: result.data,
            isLoadingUserData: false,
          ));
        }
      } else {
        if (!_isDisposed) {
          emit(state.copyWith(
            isLoadingUserData: false,
            error: result.failure?.message ?? 'Failed to load user data',
          ));
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(
          isLoadingUserData: false,
          error: 'Failed to load user data: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> loadUserProfile(int userId) async {
    if (_isDisposed) return;

    try {
      emit(state.copyWith(
        isLoadingUserPosts: true,
        isLoadingUserTodos: true,
      ));

      // Load user posts and todos in parallel
      final futures = await Future.wait([
        _userRepository.getUserPosts(userId),
        _userRepository.getUserTodos(userId),
      ]);

      if (_isDisposed) return;

      final postsResult = futures[0];
      final todosResult = futures[1];

      if (postsResult.isSuccess && todosResult.isSuccess) {
        if (!_isDisposed) {
          emit(state.copyWith(
            userPosts: (postsResult.data as List<Post>?) ?? [],
            userTodos: (todosResult.data as List<Todo>?) ?? [],
            isLoadingUserPosts: false,
            isLoadingUserTodos: false,
          ));
        }
      } else {
        if (!_isDisposed) {
          final errorMessage = postsResult.failure?.message ??
              todosResult.failure?.message ??
              'Failed to load user profile';
          emit(state.copyWith(
            isLoadingUserPosts: false,
            isLoadingUserTodos: false,
            error: errorMessage,
          ));
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(
          isLoadingUserPosts: false,
          isLoadingUserTodos: false,
          error: 'Failed to load user profile: ${e.toString()}',
        ));
      }
    }
  }

  void clearError() {
    if (!_isDisposed) {
      emit(state.copyWith(error: null));
    }
  }

  @override
  Future<void> close() async {
    _isDisposed = true;
    return super.close();
  }
}
