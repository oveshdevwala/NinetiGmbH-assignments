import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';

// Events
abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialPostsEvent extends PostsEvent {
  const LoadInitialPostsEvent();
}

class LoadAllPostsEvent extends PostsEvent {
  const LoadAllPostsEvent();
}

class LoadMorePostsEvent extends PostsEvent {
  const LoadMorePostsEvent();
}

class RefreshPostsEvent extends PostsEvent {
  const RefreshPostsEvent();
}

class LoadUserPostsEvent extends PostsEvent {
  final int userId;

  const LoadUserPostsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// State
class PostsState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? error;
  final bool isInitialized;
  final int currentPage;
  final int pageSize;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.error,
    this.isInitialized = false,
    this.currentPage = 0,
    this.pageSize = 30,
  });

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? error,
    bool? isInitialized,
    int? currentPage,
    int? pageSize,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

// Bloc
class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final PostRepository postRepository;

  PostsBloc({required this.postRepository}) : super(const PostsState()) {
    on<LoadInitialPostsEvent>(_onLoadInitialPosts);
    on<LoadAllPostsEvent>(_onLoadAllPosts);
    on<LoadMorePostsEvent>(_onLoadMorePosts);
    on<RefreshPostsEvent>(_onRefreshPosts);
    on<LoadUserPostsEvent>(_onLoadUserPosts);
  }

  Future<void> _onLoadInitialPosts(
    LoadInitialPostsEvent event,
    Emitter<PostsState> emit,
  ) async {
    if (state.isInitialized) return; // Already initialized, skip

    emit(state.copyWith(isLoading: true, error: null));

    final result = await postRepository.getAllPosts(
      limit: state.pageSize,
      skip: 0,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
        isInitialized: true,
      )),
      (posts) => emit(state.copyWith(
        isLoading: false,
        posts: posts,
        error: null,
        isInitialized: true,
        currentPage: 1,
        hasReachedMax: posts.length < state.pageSize,
      )),
    );
  }

  Future<void> _onLoadAllPosts(
    LoadAllPostsEvent event,
    Emitter<PostsState> emit,
  ) async {
    // Use initialized data if available, otherwise load initial data
    if (!state.isInitialized) {
      add(const LoadInitialPostsEvent());
      return;
    }
  }

  Future<void> _onLoadMorePosts(
    LoadMorePostsEvent event,
    Emitter<PostsState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await postRepository.getPostsPaginated(
      limit: state.pageSize,
      skip: state.currentPage * state.pageSize,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMore: false,
        error: failure.message,
      )),
      (newPosts) {
        final allPosts = List<Post>.from(state.posts)..addAll(newPosts);
        emit(state.copyWith(
          isLoadingMore: false,
          posts: allPosts,
          error: null,
          currentPage: state.currentPage + 1,
          hasReachedMax: newPosts.length < state.pageSize,
        ));
      },
    );
  }

  Future<void> _onRefreshPosts(
    RefreshPostsEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      posts: [],
      currentPage: 0,
      hasReachedMax: false,
    ));

    final result = await postRepository.getAllPosts(
      limit: state.pageSize,
      skip: 0,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (posts) => emit(state.copyWith(
        isLoading: false,
        posts: posts,
        error: null,
        currentPage: 1,
        hasReachedMax: posts.length < state.pageSize,
      )),
    );
  }

  Future<void> _onLoadUserPosts(
    LoadUserPostsEvent event,
    Emitter<PostsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await postRepository.getPostsByUser(event.userId);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (posts) => emit(state.copyWith(
        isLoading: false,
        posts: posts,
        error: null,
      )),
    );
  }
}
