import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/todo_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getUsers({
    int limit = 20,
    int skip = 0,
  });

  Future<List<UserModel>> searchUsers({
    required String query,
    int limit = 20,
    int skip = 0,
  });

  Future<UserModel> getUserById(int id);

  Future<List<PostModel>> getUserPosts(int userId);

  Future<List<TodoModel>> getUserTodos(int userId);

  Future<PostModel> createPost({
    required String title,
    required String body,
    required int userId,
  });
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserModel>> getUsers({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.usersEndpoint}',
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      final List<dynamic> users = response.data['users'];
      return users.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.usersEndpoint}/search',
        queryParameters: {
          'q': query,
          'limit': limit,
          'skip': skip,
        },
      );

      final List<dynamic> users = response.data['users'];
      return users.map((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    try {
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.usersEndpoint}/$id',
      );

      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(int userId) async {
    try {
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.postsEndpoint}/user/$userId',
      );

      final List<dynamic> posts = response.data['posts'];
      return posts.map((post) => PostModel.fromJson(post)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  @override
  Future<List<TodoModel>> getUserTodos(int userId) async {
    try {
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.todosEndpoint}/user/$userId',
      );

      final List<dynamic> todos = response.data['todos'];
      return todos.map((todo) => TodoModel.fromJson(todo)).toList();
    } catch (e) {
      throw Exception('Failed to fetch user todos: $e');
    }
  }

  @override
  Future<PostModel> createPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    try {
      final response = await dio.post(
        '${AppConfig.baseUrl}${AppConfig.postsEndpoint}/add',
        data: {
          'title': title,
          'body': body,
          'userId': userId,
        },
      );

      return PostModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }
}
