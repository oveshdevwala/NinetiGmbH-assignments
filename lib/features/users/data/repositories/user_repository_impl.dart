import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/post.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  ResultFuture<List<User>> getUsers({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final users = await remoteDataSource.getAllUsers(
        limit: limit,
        skip: skip,
      );
      return Result.success(users);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<User>> searchUsers({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final users = await remoteDataSource.searchUsers(
        query: query,
        limit: limit,
        skip: skip,
      );
      return Result.success(users);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<User> getUserById(int id) async {
    try {
      final user = await remoteDataSource.getUserById(id);
      return Result.success(user);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Post>> getUserPosts(int userId) async {
    try {
      final posts = await remoteDataSource.getUserPosts(userId);
      return Result.success(posts);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<List<Todo>> getUserTodos(int userId) async {
    try {
      final todos = await remoteDataSource.getUserTodos(userId);
      return Result.success(todos);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }

  @override
  ResultFuture<Post> createPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    try {
      final post = await remoteDataSource.createPost(
        title: title,
        body: body,
        userId: userId,
      );
      return Result.success(post);
    } catch (e) {
      return Result.failure(ServerFailure(e.toString()));
    }
  }
}
