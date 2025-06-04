import '../entities/my_post.dart';

abstract class MyPostRepository {
  /// Get all my posts
  Future<List<MyPost>> getAllMyPosts();

  /// Get a specific post by ID
  Future<MyPost?> getMyPostById(int id);

  /// Create a new post
  Future<MyPost> createMyPost({
    required String title,
    required String body,
    required String authorName,
    required List<String> tags,
  });

  /// Update an existing post
  Future<MyPost> updateMyPost(MyPost post);

  /// Delete a post
  Future<void> deleteMyPost(int id);

  /// Search posts by title or body
  Future<List<MyPost>> searchMyPosts(String query);
}
