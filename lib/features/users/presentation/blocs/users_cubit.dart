import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_offline_impl.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../../../shared/services/sync_service.dart';

// Define a simple state class for the cubit
class UsersCubitState {
  final List<User> users;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasReachedMax;
  final int currentSkip;
  final bool isSearching;
  final String searchQuery;
  final bool isOffline;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const UsersCubitState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasReachedMax = false,
    this.currentSkip = 0,
    this.isSearching = false,
    this.searchQuery = '',
    this.isOffline = false,
    this.isSyncing = false,
    this.lastSyncTime,
  });

  factory UsersCubitState.initial() {
    return const UsersCubitState();
  }

  UsersCubitState toLoading() {
    return copyWith(isLoading: true, error: null);
  }

  UsersCubitState toLoadingMore() {
    return copyWith(isLoadingMore: true, error: null);
  }

  UsersCubitState toSuccess(List<User> users, {bool hasReachedMax = false}) {
    return copyWith(
      users: users,
      isLoading: false,
      isLoadingMore: false,
      error: null,
      hasReachedMax: hasReachedMax,
      currentSkip: users.length,
    );
  }

  UsersCubitState toError(String error) {
    return copyWith(isLoading: false, isLoadingMore: false, error: error);
  }

  UsersCubitState toOffline() {
    return copyWith(
        isOffline: true, isLoading: false, isLoadingMore: false, error: null);
  }

  UsersCubitState toSyncing() {
    return copyWith(isSyncing: true, error: null);
  }

  UsersCubitState toSyncCompleted() {
    return copyWith(
        isSyncing: false, lastSyncTime: DateTime.now(), isOffline: false);
  }

  UsersCubitState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasReachedMax,
    int? currentSkip,
    bool? isSearching,
    String? searchQuery,
    bool? isOffline,
    bool? isSyncing,
    DateTime? lastSyncTime,
  }) {
    return UsersCubitState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentSkip: currentSkip ?? this.currentSkip,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      isOffline: isOffline ?? this.isOffline,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}

/// Cubit for managing users with offline-first functionality and specific pagination
class UsersCubit extends Cubit<UsersCubitState> {
  final UserRepository _userRepository;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;

  late StreamSubscription<bool> _connectivitySubscription;
  bool _isDisposed = false;
  int _currentSkip = 0;
  static const int _initialBatchSize = 15;
  static const int _paginationSize = 20;

  UsersCubit({
    required UserRepository userRepository,
    required ConnectivityService connectivityService,
    required SyncService syncService,
  })  : _userRepository = userRepository,
        _connectivityService = connectivityService,
        _syncService = syncService,
        super(UsersCubitState.initial()) {
    _initialize();
  }

  /// Initialize the cubit
  void _initialize() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (!_isDisposed) {
          if (isConnected) {
            log('Users: Network connected, syncing...');
            _handleNetworkConnected();
          } else {
            log('Users: Network disconnected, switching to offline mode');
            _handleNetworkDisconnected();
          }
        }
      },
    );

    // Load initial data
    loadUsers();
  }

  /// Load initial users (15 users, stored in ObjectBox)
  Future<void> loadUsers({bool forceRefresh = false}) async {
    if (_isDisposed) return;

    emit(state.toLoading());
    _currentSkip = 0; // Reset pagination

    try {
      final result = await _userRepository.getUsers(
        limit: _initialBatchSize,
        skip: 0,
      );

      if (_isDisposed) return;

      if (result.isSuccess) {
        final users = result.data!;
        log('Loaded ${users.length} initial users successfully');

        emit(state.toSuccess(
          users,
          hasReachedMax: users.length < _initialBatchSize,
        ));

        // Set up pagination skip for next load
        _currentSkip = _initialBatchSize;

        // Check if we're offline
        _checkAndUpdateOfflineStatus();
      } else {
        log('Error loading users: ${result.failure?.message}');
        emit(state.toError(result.failure?.message ?? 'Failed to load users'));
      }
    } catch (e) {
      if (!_isDisposed) {
        log('Exception loading users: $e');
        emit(state.toError('Failed to load users: $e'));
      }
    }
  }

  /// Load more users (pagination - 20 users per page, not stored in ObjectBox)
  Future<void> loadMoreUsers() async {
    if (_isDisposed || state.isLoadingMore || state.hasReachedMax) return;

    // Skip must be at least 15 (after initial batch)
    if (_currentSkip < _initialBatchSize) {
      _currentSkip = _initialBatchSize;
    }

    emit(state.toLoadingMore());

    try {
      final result = await _userRepository.getUsers(
        limit: _paginationSize,
        skip: _currentSkip,
      );

      if (_isDisposed) return;

      if (result.isSuccess) {
        final newUsers = result.data!;
        final currentUsers = List<User>.from(state.users);

        // Filter out duplicates based on ID
        final uniqueNewUsers = newUsers
            .where(
                (newUser) => !currentUsers.any((user) => user.id == newUser.id))
            .toList();

        if (uniqueNewUsers.isEmpty) {
          log('No more users to load');
          emit(state.copyWith(
            isLoadingMore: false,
            hasReachedMax: true,
          ));
        } else {
          final allUsers = [...currentUsers, ...uniqueNewUsers];
          log('Loaded ${uniqueNewUsers.length} more users (not stored locally)');

          emit(state.toSuccess(
            allUsers,
            hasReachedMax: newUsers.length < _paginationSize,
          ));

          // Update skip for next pagination
          _currentSkip += _paginationSize;
        }
      } else {
        log('Error loading more users: ${result.failure?.message}');
        emit(state
            .toError(result.failure?.message ?? 'Failed to load more users'));
      }
    } catch (e) {
      if (!_isDisposed) {
        log('Exception loading more users: $e');
        emit(state.toError('Failed to load more users: $e'));
      }
    }
  }

  /// Refresh users (reload initial batch)
  Future<void> refreshUsers() async {
    if (_isDisposed) return;

    log('Refreshing users...');
    await loadUsers(forceRefresh: true);
  }

  /// Search users
  Future<void> searchUsers(String query) async {
    if (_isDisposed) return;

    if (query.trim().isEmpty) {
      // If query is empty, load initial users
      await loadUsers();
      return;
    }

    emit(state.toLoading());

    try {
      final result = await _userRepository.searchUsers(
        query: query.trim(),
        limit: 50, // Higher limit for search results
        skip: 0,
      );

      if (_isDisposed) return;

      if (result.isSuccess) {
        final users = result.data!;
        log('Found ${users.length} users for query "$query"');

        emit(state.toSuccess(
          users,
          hasReachedMax: true, // Disable pagination for search results
        ));
      } else {
        log('Error searching users: ${result.failure?.message}');
        emit(
            state.toError(result.failure?.message ?? 'Failed to search users'));
      }
    } catch (e) {
      if (!_isDisposed) {
        log('Exception searching users: $e');
        emit(state.toError('Failed to search users: $e'));
      }
    }
  }

  /// Get user by ID
  Future<User?> getUserById(int userId) async {
    try {
      final result = await _userRepository.getUserById(userId);

      if (result.isSuccess) {
        log('Found user: ${result.data?.username}');
        return result.data;
      } else {
        log('Error getting user $userId: ${result.failure?.message}');
        return null;
      }
    } catch (e) {
      log('Exception getting user $userId: $e');
      return null;
    }
  }

  /// Force sync with remote
  Future<void> forceSync() async {
    if (_isDisposed) return;

    emit(state.toSyncing());

    try {
      await _syncService.forceSyncNow();

      if (!_isDisposed) {
        emit(state.toSyncCompleted());
        // Reload users after sync
        await loadUsers();
      }
    } catch (e) {
      if (!_isDisposed) {
        log('Force sync failed: $e');
        emit(state.toError('Sync failed: $e'));
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

  /// Get cache information
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      // Check if repository has this method (for offline implementation)
      if (_userRepository is UserRepositoryOfflineImpl) {
        final repo = _userRepository as dynamic;
        return await repo.getCacheInfo();
      }
      return {};
    } catch (e) {
      log('Error getting cache info: $e');
      return {};
    }
  }

  /// Clear all users (useful for logout)
  void clearUsers() {
    if (!_isDisposed) {
      _currentSkip = 0;
      emit(UsersCubitState.initial());
    }
  }

  /// Reset pagination
  void resetPagination() {
    _currentSkip = 0;
  }

  /// Get current pagination info
  Map<String, dynamic> getPaginationInfo() {
    return {
      'currentSkip': _currentSkip,
      'initialBatchSize': _initialBatchSize,
      'paginationSize': _paginationSize,
      'totalUsersLoaded': state.users.length,
      'hasReachedMax': state.hasReachedMax,
      'isLoadingMore': state.isLoadingMore,
    };
  }

  @override
  Future<void> close() async {
    _isDisposed = true;
    await _connectivitySubscription.cancel();
    return super.close();
  }
}
