import 'dart:developer';
import '../../features/home/data/model/user_entity.dart';
import '../../features/home/data/model/post_entity.dart';
import '../../features/home/data/model/todo_entity.dart';
import '../../features/my_posts/data/models/my_post_entity.dart';
import '../../objectbox.g.dart'; // Generated file

/// ObjectBox service for managing the database
class ObjectBoxService {
  /// The ObjectBox store of this app.
  late final Store _store;

  /// Target boxes for entities
  late final Box<UserEntity> _userBox;
  late final Box<PostEntity> _postBox;
  late final Box<TodoEntity> _todoBox;
  late final Box<MyPostEntity> _myPostBox;

  ObjectBoxService._create(this._store) {
    _userBox = Box<UserEntity>(_store);
    _postBox = Box<PostEntity>(_store);
    _todoBox = Box<TodoEntity>(_store);
    _myPostBox = Box<MyPostEntity>(_store);
  }

  /// Create ObjectBox store instance
  static Future<ObjectBoxService> create() async {
    try {
      final store = await openStore();
      log('ObjectBox initialized successfully');
      final service = ObjectBoxService._create(store);

      // Clear existing data to handle schema changes and avoid ID conflicts
      await service.clearAllData();
      log('Cleared existing data for fresh start');

      return service;
    } catch (e) {
      log('Failed to initialize ObjectBox: $e');
      rethrow;
    }
  }

  /// Getters for boxes
  Box<UserEntity> get userBox => _userBox;
  Box<PostEntity> get postBox => _postBox;
  Box<TodoEntity> get todoBox => _todoBox;
  Box<MyPostEntity> get myPostBox => _myPostBox;

  /// Clear all data (useful for testing or reset)
  Future<void> clearAllData() async {
    try {
      _userBox.removeAll();
      _postBox.removeAll();
      _todoBox.removeAll();
      // _myPostBox.removeAll();
      log('All ObjectBox data cleared');
    } catch (e) {
      log('Error clearing ObjectBox data: $e');
    }
  }

  /// Clear only remote synced data (keeps user-created posts)
  Future<void> clearSyncedData() async {
    try {
      _userBox.removeAll();
      _postBox.removeAll();
      _todoBox.removeAll();
      // Don't clear myPostBox - these are user's personal posts
      log('Synced ObjectBox data cleared (keeping user posts)');
    } catch (e) {
      log('Error clearing synced ObjectBox data: $e');
    }
  }

  /// Close the store
  void close() {
    _store.close();
    log('ObjectBox store closed');
  }

  /// Get database info
  Map<String, dynamic> getDbInfo() {
    return {
      'users_count': _userBox.count(),
      'posts_count': _postBox.count(),
      'todos_count': _todoBox.count(),
      'my_posts_count': _myPostBox.count(),
    };
  }
}
