import 'dart:developer';
import '../../features/users/domain/repositories/user_repository.dart';

class UserStatsService {
  final UserRepository _userRepository;

  // Cache for user stats to avoid repeated API calls
  final Map<int, UserStats> _statsCache = {};
  // Track which users are currently being loaded
  final Set<int> _loadingStats = {};

  UserStatsService({required UserRepository userRepository})
      : _userRepository = userRepository;

  /// Get stats for a single user
  Future<UserStats?> getUserStats(int userId) async {
    // Return cached data if available
    if (_statsCache.containsKey(userId)) {
      return _statsCache[userId];
    }

    // Don't fetch if already loading
    if (_loadingStats.contains(userId)) {
      return null;
    }

    _loadingStats.add(userId);

    try {
      // Fetch posts and todos for the user
      final postsResult = await _userRepository.getUserPosts(userId);
      final todosResult = await _userRepository.getUserTodos(userId);

      int postsCount = 0;
      int todosCount = 0;

      if (postsResult.isSuccess) {
        postsCount = postsResult.data?.length ?? 0;
      }

      if (todosResult.isSuccess) {
        todosCount = todosResult.data?.length ?? 0;
      }

      final stats = UserStats(
        userId: userId,
        postsCount: postsCount,
        todosCount: todosCount,
        lastUpdated: DateTime.now(),
      );

      // Cache the stats
      _statsCache[userId] = stats;

      log('Fetched stats for user $userId: $postsCount posts, $todosCount todos');
      return stats;
    } catch (e) {
      log('Error fetching stats for user $userId: $e');
      return null;
    } finally {
      _loadingStats.remove(userId);
    }
  }

  /// Get stats for multiple users
  Future<Map<int, UserStats>> getUsersStats(List<int> userIds) async {
    final Map<int, UserStats> results = {};

    // Filter out already cached and loading users
    final usersToFetch = userIds
        .where(
            (id) => !_statsCache.containsKey(id) && !_loadingStats.contains(id))
        .toList();

    if (usersToFetch.isEmpty) {
      // Return cached results
      for (final id in userIds) {
        final cached = _statsCache[id];
        if (cached != null) {
          results[id] = cached;
        }
      }
      return results;
    }

    // Process in batches to avoid overwhelming the API
    const batchSize = 5;

    for (int i = 0; i < usersToFetch.length; i += batchSize) {
      final batch = usersToFetch.skip(i).take(batchSize).toList();

      // Fetch stats for this batch in parallel
      final futures = batch.map((userId) => getUserStats(userId));
      final batchResults = await Future.wait(futures);

      // Add non-null results to the map
      for (int j = 0; j < batch.length; j++) {
        final userId = batch[j];
        final stats = batchResults[j];
        if (stats != null) {
          results[userId] = stats;
        }
      }

      // Small delay between batches to be nice to the API
      if (i + batchSize < usersToFetch.length) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }

    return results;
  }

  /// Clear stats cache
  void clearCache() {
    _statsCache.clear();
    _loadingStats.clear();
  }

  /// Clear stats for a specific user
  void clearUserStats(int userId) {
    _statsCache.remove(userId);
    _loadingStats.remove(userId);
  }

  /// Get cached stats without fetching
  UserStats? getCachedStats(int userId) {
    return _statsCache[userId];
  }

  /// Get stats for a user (cached version for UI)
  UserStats? getStatsForUser(int userId) {
    return _statsCache[userId];
  }

  /// Check if stats are being loaded for a user
  bool isLoadingStats(int userId) {
    return _loadingStats.contains(userId);
  }

  /// Check if stats are cached and fresh (less than 5 minutes old)
  bool hasValidCache(int userId) {
    final stats = _statsCache[userId];
    if (stats == null) return false;

    final age = DateTime.now().difference(stats.lastUpdated);
    return age.inMinutes < 5;
  }
}

class UserStats {
  final int userId;
  final int postsCount;
  final int todosCount;
  final DateTime lastUpdated;

  const UserStats({
    required this.userId,
    required this.postsCount,
    required this.todosCount,
    required this.lastUpdated,
  });

  UserStats copyWith({
    int? userId,
    int? postsCount,
    int? todosCount,
    DateTime? lastUpdated,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      postsCount: postsCount ?? this.postsCount,
      todosCount: todosCount ?? this.todosCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'UserStats(userId: $userId, posts: $postsCount, todos: $todosCount)';
  }
}
