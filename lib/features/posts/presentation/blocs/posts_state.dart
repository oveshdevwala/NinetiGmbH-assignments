import 'package:equatable/equatable.dart';
import '../../../users/domain/entities/post.dart';

class PostsState extends Equatable {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasReachedMax;
  final int currentPage;
  final bool isOffline;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const PostsState({
    required this.posts,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasReachedMax = false,
    this.currentPage = 0,
    this.isOffline = false,
    this.isSyncing = false,
    this.lastSyncTime,
  });

  // Initial state
  factory PostsState.initial() {
    return const PostsState(
      posts: [],
      isLoading: false,
      isLoadingMore: false,
      error: null,
      hasReachedMax: false,
      currentPage: 0,
      isOffline: false,
      isSyncing: false,
      lastSyncTime: null,
    );
  }

  // Loading state
  PostsState toLoading() {
    return copyWith(
      isLoading: true,
      error: null,
    );
  }

  // Loading more state
  PostsState toLoadingMore() {
    return copyWith(
      isLoadingMore: true,
      error: null,
    );
  }

  // Success state
  PostsState toSuccess(List<Post> posts, {bool hasReachedMax = false}) {
    return copyWith(
      posts: posts,
      isLoading: false,
      isLoadingMore: false,
      error: null,
      hasReachedMax: hasReachedMax,
      currentPage: currentPage + (posts.length > this.posts.length ? 1 : 0),
    );
  }

  // Error state
  PostsState toError(String error) {
    return copyWith(
      isLoading: false,
      isLoadingMore: false,
      error: error,
    );
  }

  // Offline state
  PostsState toOffline() {
    return copyWith(
      isOffline: true,
      isLoading: false,
      isLoadingMore: false,
      error: null,
    );
  }

  // Syncing state
  PostsState toSyncing() {
    return copyWith(
      isSyncing: true,
      error: null,
    );
  }

  // Sync completed state
  PostsState toSyncCompleted() {
    return copyWith(
      isSyncing: false,
      lastSyncTime: DateTime.now(),
      isOffline: false,
    );
  }

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasReachedMax,
    int? currentPage,
    bool? isOffline,
    bool? isSyncing,
    DateTime? lastSyncTime,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentPage: currentPage ?? this.currentPage,
      isOffline: isOffline ?? this.isOffline,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  @override
  List<Object?> get props => [
        posts,
        isLoading,
        isLoadingMore,
        error,
        hasReachedMax,
        currentPage,
        isOffline,
        isSyncing,
        lastSyncTime,
      ];
}
