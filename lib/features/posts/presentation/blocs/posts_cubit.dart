import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'posts_state.dart';
import '../../../users/domain/entities/post.dart';
import '../../../users/domain/repositories/post_repository.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../../../shared/services/sync_service.dart';

/// Cubit for managing posts with offline-first functionality
class PostsCubit extends Cubit<PostsState> {
  final PostRepository _postRepository;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  late StreamSubscription<bool> _connectivitySubscription;
  bool _isDisposed = false;

  PostsCubit({
    required PostRepository postRepository,
    required ConnectivityService connectivityService,
    required SyncService syncService,
  })  : _postRepository = postRepository,
        _connectivityService = connectivityService,
        _syncService = syncService,
        super(PostsState.initial()) {
    _initialize();
  }

  /// Initialize the cubit
  void _initialize() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (!_isDisposed) {
          if (isConnected) {
            log('Posts: Network connected, syncing...');
            _handleNetworkConnected();
          } else {
            log('Posts: Network disconnected, switching to offline mode');
            _handleNetworkDisconnected();
          }
        }
      },
    );

    // Load initial data
    loadPosts();
  }

  /// Load posts (offline-first approach)
  Future<void> loadPosts({bool forceRefresh = false}) async {
    if (_isDisposed) return;

    emit(state.toLoading());

    try {
      final result = await _postRepository.getAllPosts();

      if (_isDisposed) return;

      result.fold(
        (failure) {
          log('Error loading posts: ${failure.message}');
          emit(state.toError(failure.message));
        },
        (posts) {
          log('Loaded ${posts.length} posts successfully');
          emit(state.toSuccess(posts));

          // Check if we're offline
          _checkAndUpdateOfflineStatus();
        },
      );
    } catch (e) {
      if (!_isDisposed) {
        log('Exception loading posts: $e');
        emit(state.toError('Failed to load posts: $e'));
      }
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMorePosts() async {
    if (_isDisposed || state.isLoadingMore || state.hasReachedMax) return;

    emit(state.toLoadingMore());

    try {
      final result = await _postRepository.getAllPosts();

      if (_isDisposed) return;

      result.fold(
        (failure) {
          log('Error loading more posts: ${failure.message}');
          emit(state.toError(failure.message));
        },
        (newPosts) {
          final currentPosts = List<Post>.from(state.posts);

          // Filter out duplicates
          final uniqueNewPosts = newPosts
              .where((newPost) =>
                  !currentPosts.any((post) => post.id == newPost.id))
              .toList();

          if (uniqueNewPosts.isEmpty) {
            log('No more posts to load');
            emit(state.copyWith(
              isLoadingMore: false,
              hasReachedMax: true,
            ));
          } else {
            final allPosts = [...currentPosts, ...uniqueNewPosts];
            log('Loaded ${uniqueNewPosts.length} more posts');
            emit(state.toSuccess(allPosts));
          }
        },
      );
    } catch (e) {
      if (!_isDisposed) {
        log('Exception loading more posts: $e');
        emit(state.toError('Failed to load more posts: $e'));
      }
    }
  }

  /// Refresh posts
  Future<void> refreshPosts() async {
    if (_isDisposed) return;

    log('Refreshing posts...');
    await loadPosts(forceRefresh: true);
  }

  /// Force sync with remote
  Future<void> forceSync() async {
    if (_isDisposed) return;

    emit(state.toSyncing());

    try {
      await _syncService.forceSyncNow();

      if (!_isDisposed) {
        emit(state.toSyncCompleted());
        // Reload posts after sync
        await loadPosts();
      }
    } catch (e) {
      if (!_isDisposed) {
        log('Force sync failed: $e');
        emit(state.toError('Sync failed: $e'));
      }
    }
  }

  /// Get posts by user ID
  Future<void> getPostsByUserId(int userId) async {
    if (_isDisposed) return;

    emit(state.toLoading());

    try {
      final result = await _postRepository.getPostsByUser(userId);

      if (_isDisposed) return;

      result.fold(
        (failure) {
          log('Error loading posts for user $userId: ${failure.message}');
          emit(state.toError(failure.message));
        },
        (posts) {
          log('Loaded ${posts.length} posts for user $userId');
          emit(state.toSuccess(posts));
        },
      );
    } catch (e) {
      if (!_isDisposed) {
        log('Exception loading posts for user $userId: $e');
        emit(state.toError('Failed to load posts for user: $e'));
      }
    }
  }

  /// Handle network connected
  void _handleNetworkConnected() {
    if (_isDisposed) return;

    emit(state.copyWith(isOffline: false));

    // Trigger sync in background
    if (_syncService.isSyncing == false) {
      _syncService.syncAll();
    }
  }

  /// Handle network disconnected
  void _handleNetworkDisconnected() {
    if (_isDisposed) return;

    emit(state.copyWith(isOffline: true));
  }

  /// Check and update offline status
  Future<void> _checkAndUpdateOfflineStatus() async {
    if (_isDisposed) return;

    try {
      final isConnected = await _connectivityService.isConnected;
      if (!_isDisposed) {
        emit(state.copyWith(isOffline: !isConnected));
      }
    } catch (e) {
      log('Error checking connectivity: $e');
    }
  }

  /// Get sync information
  Future<Map<String, dynamic>> getSyncInfo() async {
    try {
      return await _syncService.getSyncInfo();
    } catch (e) {
      log('Error getting sync info: $e');
      return {};
    }
  }

  /// Clear all posts (useful for logout)
  void clearPosts() {
    if (!_isDisposed) {
      emit(PostsState.initial());
    }
  }

  @override
  Future<void> close() async {
    _isDisposed = true;
    await _connectivitySubscription.cancel();
    return super.close();
  }
}
