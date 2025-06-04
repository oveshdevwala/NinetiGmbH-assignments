import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/post.dart';

import 'package:equatable/equatable.dart';
import '../../../domain/repositories/post_repository.dart';
part'posts_event.dart';
part 'posts_state.dart';
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
    log('PostsBloc: LoadMorePosts event received');
    log(
        'PostsBloc: Current state - posts: ${state.posts.length}, isLoadingMore: ${state.isLoadingMore}, hasReachedMax: ${state.hasReachedMax}');

    if (state.hasReachedMax || state.isLoadingMore) {
      log(
          'PostsBloc: Skipping pagination - hasReachedMax: ${state.hasReachedMax}, isLoadingMore: ${state.isLoadingMore}');
      return;
    }

    log('PostsBloc: Setting isLoadingMore to true');
    emit(state.copyWith(isLoadingMore: true));

    final result = await postRepository.getPostsPaginated(
      limit: state.pageSize,
      skip: state.currentPage * state.pageSize,
    );

    result.fold(
      (failure) {
        log('PostsBloc: Error loading more posts - ${failure.message}');
        emit(state.copyWith(
          isLoadingMore: false,
          error: failure.message,
        ));
      },
      (newPosts) {
        log('PostsBloc: Loaded ${newPosts.length} new posts');
        final allPosts = List<Post>.from(state.posts)..addAll(newPosts);
        final hasReachedMax = newPosts.length < state.pageSize;
        log(
            'PostsBloc: Total posts: ${allPosts.length}, hasReachedMax: $hasReachedMax');

        emit(state.copyWith(
          isLoadingMore: false,
          posts: allPosts,
          error: null,
          currentPage: state.currentPage + 1,
          hasReachedMax: hasReachedMax,
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
