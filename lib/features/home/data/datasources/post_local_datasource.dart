import 'dart:developer';
import '../model/post_entity.dart';
import '../../domain/entities/post.dart';
import '../../../../objectbox.g.dart'; // For PostEntity_

abstract class PostLocalDataSource {
  Future<List<Post>> getAllPosts();
  Future<Post?> getPostById(int id);
  Future<List<Post>> getPostsByUserId(int userId);
  Future<void> savePosts(List<Post> posts);
  Future<void> savePost(Post post);
  Future<void> deletePost(int id);
  Future<void> clearAllPosts();
  Future<List<Post>> getUnsyncedPosts();
  Future<void> markPostAsSynced(int id);
  Future<int> getPostsCount();
}

class PostLocalDataSourceImpl implements PostLocalDataSource {
  final Box<PostEntity> _postBox;

  PostLocalDataSourceImpl({required Box<PostEntity> postBox})
      : _postBox = postBox;

  @override
  Future<List<Post>> getAllPosts() async {
    try {
      final entities = _postBox.getAll();
      final activeEntities =
          entities.where((entity) => !entity.isDeleted).toList();

      // Sort by updated date
      activeEntities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return activeEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting all posts from local storage: $e');
      return [];
    }
  }

  @override
  Future<Post?> getPostById(int id) async {
    try {
      // Find by apiId since that's what the domain layer uses
      final entity = _findEntityByApiId(id);

      if (entity != null && !entity.isDeleted) {
        return entity.toDomain();
      }
      return null;
    } catch (e) {
      log('Error getting post by id from local storage: $e');
      return null;
    }
  }

  @override
  Future<List<Post>> getPostsByUserId(int userId) async {
    try {
      final entities = _postBox.getAll();
      final userPosts = entities
          .where((entity) => entity.userId == userId && !entity.isDeleted)
          .toList();

      // Sort by updated date
      userPosts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return userPosts.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting posts by user id from local storage: $e');
      return [];
    }
  }

  @override
  Future<void> savePosts(List<Post> posts) async {
    try {
      for (final post in posts) {
        await savePost(post);
      }

      log('Saved ${posts.length} posts to local storage');
    } catch (e) {
      log('Error saving posts to local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> savePost(Post post) async {
    try {
      // Find existing entity by apiId
      final existing = _findEntityByApiId(post.id);

      if (existing != null) {
        // Update existing entity (preserve ObjectBox id)
        final updated = existing.copyWith(
          title: post.title,
          body: post.body,
          userId: post.userId,
          tags: post.tags.join(','),
          likes: post.reactions.likes,
          dislikes: post.reactions.dislikes,
          views: post.views,
          updatedAt: DateTime.now(),
          isSynced: true,
        );
        _postBox.put(updated);
      } else {
        // Insert new entity (id = 0 for ObjectBox auto-assignment)
        final entity = PostEntity.fromDomain(post);
        _postBox.put(entity);
      }

      log('Saved post ${post.id} to local storage');
    } catch (e) {
      log('Error saving post to local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePost(int id) async {
    try {
      // Find by apiId
      final entity = _findEntityByApiId(id);

      if (entity != null) {
        // Soft delete - mark as deleted instead of removing
        final updated = entity.copyWith(
          isDeleted: true,
          updatedAt: DateTime.now(),
          isSynced: false,
        );
        _postBox.put(updated);
        log('Marked post $id as deleted in local storage');
      }
    } catch (e) {
      log('Error deleting post from local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllPosts() async {
    try {
      _postBox.removeAll();
      log('Cleared all posts from local storage');
    } catch (e) {
      log('Error clearing posts from local storage: $e');
      rethrow;
    }
  }

  @override
  Future<List<Post>> getUnsyncedPosts() async {
    try {
      final entities = _postBox.getAll();
      final unsyncedEntities =
          entities.where((entity) => !entity.isSynced).toList();

      return unsyncedEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting unsynced posts from local storage: $e');
      return [];
    }
  }

  @override
  Future<void> markPostAsSynced(int id) async {
    try {
      // Find by apiId
      final entity = _findEntityByApiId(id);

      if (entity != null) {
        final updated = entity.copyWith(
          isSynced: true,
          updatedAt: DateTime.now(),
        );
        _postBox.put(updated);
        log('Marked post $id as synced');
      }
    } catch (e) {
      log('Error marking post as synced: $e');
      rethrow;
    }
  }

  @override
  Future<int> getPostsCount() async {
    try {
      final entities = _postBox.getAll();
      return entities.where((entity) => !entity.isDeleted).length;
    } catch (e) {
      log('Error getting posts count: $e');
      return 0;
    }
  }

  // Helper method to find entity by apiId
  PostEntity? _findEntityByApiId(int apiId) {
    try {
      // Use ObjectBox query for better performance
      final query = _postBox.query(PostEntity_.apiId.equals(apiId)).build();
      final entity = query.findFirst();
      query.close();
      return entity;
    } catch (e) {
      return null;
    }
  }
}
