import '../../../../core/utils/typedef.dart';
import '../entities/user.dart';
import '../../../home/domain/entities/post.dart';
import '../../../home/domain/entities/todo.dart';

abstract class UserRepository {
  ResultFuture<List<User>> getUsers({
    int limit = 20,
    int skip = 0,
  });

  ResultFuture<List<User>> searchUsers({
    required String query,
    int limit = 20,
    int skip = 0,
  });

  ResultFuture<User> getUserById(int id);

  ResultFuture<List<Post>> getUserPosts(int userId);

  ResultFuture<List<Todo>> getUserTodos(int userId);

  ResultFuture<Post> createPost({
    required String title,
    required String body,
    required int userId,
  });
}
