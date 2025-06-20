import 'package:assignments/features/profile/presentation/blocs/user_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../home/domain/entities/post.dart';
import '../../../home/domain/entities/todo.dart';
import '../../../users/domain/repositories/user_repository.dart';

// Cubit
class UserProfileCubit extends Cubit<UserProfileState> {
  final UserRepository _userRepository;
  bool _isDisposed = false;

  UserProfileCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const UserProfileState());

  Future<void> loadUserProfile(int userId) async {
    if (_isDisposed) return;

    try {
      emit(state.copyWith(isLoading: true, error: null));

      final userResult = await _userRepository.getUserById(userId);

      if (_isDisposed) return;

      if (userResult.isSuccess) {
        emit(state.copyWith(
          user: userResult.data,
          isLoading: false,
        ));

        // Load posts and todos in parallel
        await _loadUserContent(userId);
      } else {
        if (!_isDisposed) {
          emit(state.copyWith(
            isLoading: false,
            error: userResult.failure?.message ?? 'Failed to load user',
          ));
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load user profile: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> _loadUserContent(int userId) async {
    if (_isDisposed) return;

    try {
      emit(state.copyWith(
        isLoadingPosts: true,
        isLoadingTodos: true,
      ));

      // Load posts and todos in parallel
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
            posts: (postsResult.data as List<Post>?) ?? [],
            todos: (todosResult.data as List<Todo>?) ?? [],
            isLoadingPosts: false,
            isLoadingTodos: false,
          ));
        }
      } else {
        if (!_isDisposed) {
          final errorMessage = postsResult.failure?.message ??
              todosResult.failure?.message ??
              'Failed to load user content';
          emit(state.copyWith(
            isLoadingPosts: false,
            isLoadingTodos: false,
            error: errorMessage,
          ));
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        emit(state.copyWith(
          isLoadingPosts: false,
          isLoadingTodos: false,
          error: 'Failed to load user content: ${e.toString()}',
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
