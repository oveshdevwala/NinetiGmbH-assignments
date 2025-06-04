import 'dart:async';
import 'dart:developer';
import '../../features/home/data/datasources/post_local_datasource.dart';
import '../../features/home/data/datasources/post_remote_datasource.dart';
import '../../features/home/data/datasources/todo_local_datasource.dart';
import '../../features/home/data/datasources/todo_remote_datasource.dart';
import 'connectivity_service.dart';

/// Service responsible for synchronizing data between local and remote sources
class SyncService {
  final PostLocalDataSource _postLocalDataSource;
  final PostRemoteDataSource _postRemoteDataSource;
  final TodoLocalDataSource _todoLocalDataSource;
  final TodoRemoteDataSource _todoRemoteDataSource;
  final ConnectivityService _connectivityService;

  Timer? _syncTimer;
  bool _isSyncing = false;
  late StreamSubscription<bool> _connectivitySubscription;

  SyncService({
    required PostLocalDataSource postLocalDataSource,
    required PostRemoteDataSource postRemoteDataSource,
    required TodoLocalDataSource todoLocalDataSource,
    required TodoRemoteDataSource todoRemoteDataSource,
    required ConnectivityService connectivityService,
  })  : _postLocalDataSource = postLocalDataSource,
        _postRemoteDataSource = postRemoteDataSource,
        _todoLocalDataSource = todoLocalDataSource,
        _todoRemoteDataSource = todoRemoteDataSource,
        _connectivityService = connectivityService;

  /// Initialize sync service
  Future<void> initialize() async {
    // Listen to connectivity changes and sync when connected
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (isConnected && !_isSyncing) {
          log('Network connected, starting sync...');
          syncAll();
        }
      },
    );

    // Initial data load - always load from local first
    await _loadFromLocal();

    // Check if connected and sync if needed
    final isConnected = await _connectivityService.isConnected;
    if (isConnected) {
      syncAll();
    }

    // Setup periodic sync when connected
    _setupPeriodicSync();
  }

  /// Load initial data from local storage (offline-first approach)
  Future<void> _loadFromLocal() async {
    try {
      final postsCount = await _postLocalDataSource.getPostsCount();
      final todosCount = await _todoLocalDataSource.getTodosCount();

      log('Loaded from local storage: $postsCount posts, $todosCount todos');

      // If no local data exists, we'll fetch from remote when connected
      if (postsCount == 0 && todosCount == 0) {
        log('No local data found, will fetch from remote when connected');
      }
    } catch (e) {
      log('Error loading from local storage: $e');
    }
  }

  /// Setup periodic sync every 5 minutes when connected
  void _setupPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      final isConnected = await _connectivityService.isConnected;
      if (isConnected && !_isSyncing) {
        log('Periodic sync triggered');
        syncAll();
      }
    });
  }

  /// Sync all data (posts and todos)
  Future<void> syncAll() async {
    if (_isSyncing) {
      log('Sync already in progress, skipping...');
      return;
    }

    _isSyncing = true;
    log('Starting full sync...');

    try {
      await Future.wait([
        _syncPosts(),
        _syncTodos(),
      ]);
      log('Full sync completed successfully');
    } catch (e) {
      log('Error during full sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync posts between local and remote
  Future<void> _syncPosts() async {
    try {
      // First, push any unsynced local changes to remote
      await _pushUnsyncedPosts();

      // Then, fetch latest data from remote and update local
      await _fetchAndSavePostsFromRemote();
    } catch (e) {
      log('Error syncing posts: $e');
      rethrow;
    }
  }

  /// Sync todos between local and remote
  Future<void> _syncTodos() async {
    try {
      // First, push any unsynced local changes to remote
      await _pushUnsyncedTodos();

      // Then, fetch latest data from remote and update local
      await _fetchAndSaveTodosFromRemote();
    } catch (e) {
      log('Error syncing todos: $e');
      rethrow;
    }
  }

  /// Push unsynced posts to remote
  Future<void> _pushUnsyncedPosts() async {
    try {
      final unsyncedPosts = await _postLocalDataSource.getUnsyncedPosts();

      for (final post in unsyncedPosts) {
        try {
          // Note: This is a simplified example
          // In a real app, you'd need to handle create/update/delete operations differently
          await _postLocalDataSource.markPostAsSynced(post.id);
          log('Marked post ${post.id} as synced');
        } catch (e) {
          log('Failed to sync post ${post.id}: $e');
        }
      }

      if (unsyncedPosts.isNotEmpty) {
        log('Pushed ${unsyncedPosts.length} unsynced posts to remote');
      }
    } catch (e) {
      log('Error pushing unsynced posts: $e');
    }
  }

  /// Push unsynced todos to remote
  Future<void> _pushUnsyncedTodos() async {
    try {
      final unsyncedTodos = await _todoLocalDataSource.getUnsyncedTodos();

      for (final todo in unsyncedTodos) {
        try {
          // Note: This is a simplified example
          // In a real app, you'd need to handle create/update/delete operations differently
          await _todoLocalDataSource.markTodoAsSynced(todo.id);
          log('Marked todo ${todo.id} as synced');
        } catch (e) {
          log('Failed to sync todo ${todo.id}: $e');
        }
      }

      if (unsyncedTodos.isNotEmpty) {
        log('Pushed ${unsyncedTodos.length} unsynced todos to remote');
      }
    } catch (e) {
      log('Error pushing unsynced todos: $e');
    }
  }

  /// Fetch posts from remote and save to local
  Future<void> _fetchAndSavePostsFromRemote() async {
    try {
      final remotePosts = await _postRemoteDataSource.getAllPosts();
      await _postLocalDataSource.savePosts(remotePosts);
      log('Fetched and saved ${remotePosts.length} posts from remote');
    } catch (e) {
      log('Error fetching posts from remote: $e');
      rethrow;
    }
  }

  /// Fetch todos from remote and save to local
  Future<void> _fetchAndSaveTodosFromRemote() async {
    try {
      final remoteTodos = await _todoRemoteDataSource.getAllTodos();
      await _todoLocalDataSource.saveTodos(remoteTodos);
      log('Fetched and saved ${remoteTodos.length} todos from remote');
    } catch (e) {
      log('Error fetching todos from remote: $e');
      rethrow;
    }
  }

  /// Force sync now (manual trigger)
  Future<void> forceSyncNow() async {
    log('Force sync triggered');
    await syncAll();
  }

  /// Check sync status
  bool get isSyncing => _isSyncing;

  /// Get sync info
  Future<Map<String, dynamic>> getSyncInfo() async {
    try {
      final postsCount = await _postLocalDataSource.getPostsCount();
      final todosCount = await _todoLocalDataSource.getTodosCount();
      final unsyncedPosts = await _postLocalDataSource.getUnsyncedPosts();
      final unsyncedTodos = await _todoLocalDataSource.getUnsyncedTodos();
      final isConnected = await _connectivityService.isConnected;

      return {
        'posts_count': postsCount,
        'todos_count': todosCount,
        'unsynced_posts_count': unsyncedPosts.length,
        'unsynced_todos_count': unsyncedTodos.length,
        'is_connected': isConnected,
        'is_syncing': _isSyncing,
      };
    } catch (e) {
      log('Error getting sync info: $e');
      return {};
    }
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription.cancel();
    log('SyncService disposed');
  }
}
