import 'dart:async';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/repositories/user_repository_offline_impl.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../../../shared/services/sync_service.dart';
import '../../../../shared/services/user_stats_service.dart';

// Enhanced state class that includes user stats
class EnhancedUsersCubitState {
  final List<User> users;
  final Map<int, UserStats> userStats;
  final Set<int> loadingStats;
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

  const EnhancedUsersCubitState({
    this.users = const [],
    this.userStats = const {},
    this.loadingStats = const {},
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

  factory EnhancedUsersCubitState.initial() {
    return const EnhancedUsersCubitState();
  }

  EnhancedUsersCubitState toLoading() {
    return copyWith(isLoading: true, error: null);
  }

  EnhancedUsersCubitState toLoadingMore() {
    return copyWith(isLoadingMore: true, error: null);
  }

  EnhancedUsersCubitState toSuccess(List<User> users,
      {bool hasReachedMax = false}) {
    return copyWith(
      users: users,
      isLoading: false,
      isLoadingMore: false,
      error: null,
      hasReachedMax: hasReachedMax,
      currentSkip: users.length,
    );
  }

  EnhancedUsersCubitState toError(String error) {
    return copyWith(isLoading: false, isLoadingMore: false, error: error);
  }

  EnhancedUsersCubitState toOffline() {
    return copyWith(
        isOffline: true, isLoading: false, isLoadingMore: false, error: null);
  }

  EnhancedUsersCubitState toSyncing() {
    return copyWith(isSyncing: true, error: null);
  }

  EnhancedUsersCubitState toSyncCompleted() {
    return copyWith(
        isSyncing: false, lastSyncTime: DateTime.now(), isOffline: false);
  }

  EnhancedUsersCubitState copyWith({
    List<User>? users,
    Map<int, UserStats>? userStats,
    Set<int>? loadingStats,
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
    return EnhancedUsersCubitState(
      users: users ?? this.users,
      userStats: userStats ?? this.userStats,
      loadingStats: loadingStats ?? this.loadingStats,
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

  // Helper methods for stats
  UserStats? getStatsForUser(int userId) => userStats[userId];
  bool isLoadingStatsForUser(int userId) => loadingStats.contains(userId);
}

/// Enhanced Cubit for managing users with stats
class EnhancedUsersCubit extends Cubit<EnhancedUsersCubitState> {
  final UserRepository _userRepository;
  final ConnectivityService _connectivityService;
  final SyncService _syncService;
  final UserStatsService _userStatsService;

  late StreamSubscription<bool> _connectivitySubscription;
  bool _isDisposed = false;
  int _currentSkip = 0;
  static const int _initialBatchSize = 15;
  static const int _paginationSize = 20;

  EnhancedUsersCubit({
    required UserRepository userRepository,
    required ConnectivityService connectivityService,
    required SyncService syncService,
    required UserStatsService userStatsService,
  })  : _userRepository = userRepository,
        _connectivityService = connectivityService,
        _syncService = syncService,
        _userStatsService = userStatsService,
        super(EnhancedUsersCubitState.initial()) {
    _initialize();
  }

  /// Initialize the cubit
  void _initialize() {
    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (!_isDisposed) {
          if (isConnected) {
            log('Enhanced Users: Network connected, syncing...');
            _handleNetworkConnected();
          } else {
            log('Enhanced Users: Network disconnected, switching to offline mode');
            _handleNetworkDisconnected();
          }
        }
      },
    );

    // Load initial data
    loadUsers();
  }

  /// Load initial users
  Future<void> loadUsers({bool forceRefresh = false}) async {
    if (_isDisposed) return;

    emit(state.toLoading());
    _currentSkip = 0;

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

        _currentSkip = _initialBatchSize;

        // Load stats for visible users
        _loadStatsForUsers(users);

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

  /// Load more users
  Future<void> loadMoreUsers() async {
    if (_isDisposed || state.isLoadingMore || state.hasReachedMax) return;

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
          log('Loaded ${uniqueNewUsers.length} more users');

          emit(state.toSuccess(
            allUsers,
            hasReachedMax: newUsers.length < _paginationSize,
          ));

          _currentSkip += _paginationSize;

          // Load stats for new users
          _loadStatsForUsers(uniqueNewUsers);
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

  /// Load stats for a list of users
  Future<void> _loadStatsForUsers(List<User> users) async {
    if (_isDisposed || users.isEmpty) return;

    final userIds = users.map((user) => user.id).toList();

    // Mark as loading
    final currentLoadingStats = Set<int>.from(state.loadingStats);
    currentLoadingStats.addAll(userIds);

    emit(state.copyWith(loadingStats: currentLoadingStats));

    try {
      // Load stats in background
      final statsMap = await _userStatsService.getUsersStats(userIds);

      if (_isDisposed) return;

      // Update state with new stats
      final currentStats = Map<int, UserStats>.from(state.userStats);
      currentStats.addAll(statsMap);

      // Remove from loading set
      final updatedLoadingStats = Set<int>.from(state.loadingStats);
      updatedLoadingStats.removeAll(userIds);

      emit(state.copyWith(
        userStats: currentStats,
        loadingStats: updatedLoadingStats,
      ));

      log('Loaded stats for ${statsMap.length} users');
    } catch (e) {
      if (!_isDisposed) {
        log('Error loading user stats: $e');

        // Remove from loading set on error
        final updatedLoadingStats = Set<int>.from(state.loadingStats);
        updatedLoadingStats.removeAll(userIds);

        emit(state.copyWith(loadingStats: updatedLoadingStats));
      }
    }
  }

  /// Load stats for a specific user
  Future<void> loadStatsForUser(int userId) async {
    if (_isDisposed || state.loadingStats.contains(userId)) return;

    // Mark as loading
    final currentLoadingStats = Set<int>.from(state.loadingStats);
    currentLoadingStats.add(userId);
    emit(state.copyWith(loadingStats: currentLoadingStats));

    try {
      final stats = await _userStatsService.getUserStats(userId);

      if (_isDisposed) return;

      if (stats != null) {
        final currentStats = Map<int, UserStats>.from(state.userStats);
        currentStats[userId] = stats;

        final updatedLoadingStats = Set<int>.from(state.loadingStats);
        updatedLoadingStats.remove(userId);

        emit(state.copyWith(
          userStats: currentStats,
          loadingStats: updatedLoadingStats,
        ));
      } else {
        // Remove from loading set on failure
        final updatedLoadingStats = Set<int>.from(state.loadingStats);
        updatedLoadingStats.remove(userId);
        emit(state.copyWith(loadingStats: updatedLoadingStats));
      }
    } catch (e) {
      if (!_isDisposed) {
        log('Error loading stats for user $userId: $e');

        final updatedLoadingStats = Set<int>.from(state.loadingStats);
        updatedLoadingStats.remove(userId);
        emit(state.copyWith(loadingStats: updatedLoadingStats));
      }
    }
  }

  /// Refresh users and their stats
  Future<void> refreshUsers() async {
    if (_isDisposed) return;

    log('Refreshing users and stats...');
    _userStatsService.clearCache();
    await loadUsers(forceRefresh: true);
  }

  /// Search users
  Future<void> searchUsers(String query) async {
    if (_isDisposed) return;

    if (query.trim().isEmpty) {
      await loadUsers();
      return;
    }

    emit(state.toLoading());

    try {
      final result = await _userRepository.searchUsers(
        query: query.trim(),
        limit: 50,
        skip: 0,
      );

      if (_isDisposed) return;

      if (result.isSuccess) {
        final users = result.data!;
        log('Found ${users.length} users for query "$query"');

        emit(state.toSuccess(
          users,
          hasReachedMax: true,
        ));

        // Load stats for search results
        _loadStatsForUsers(users);
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
        _userStatsService.clearCache();
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

  /// Clear all users and stats
  void clearUsers() {
    if (!_isDisposed) {
      _currentSkip = 0;
      _userStatsService.clearCache();
      emit(EnhancedUsersCubitState.initial());
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
