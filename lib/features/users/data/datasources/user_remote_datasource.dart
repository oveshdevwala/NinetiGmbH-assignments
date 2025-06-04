import 'package:dio/dio.dart';
import 'dart:developer';
import '../../../../core/config/app_config.dart';
import '../models/user_model.dart';
import '../../../home/data/model/post_model.dart';
import '../../../home/data/model/todo_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getInitialUsers(); // Get first 15 users
  Future<List<UserModel>> getUsersPaginated({
    int limit = 20,
    int skip = 0,
  });
  Future<List<UserModel>> getAllUsers({
    int limit = 30,
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
  Future<List<UserModel>> getInitialUsers() async {
    try {
      log('Fetching initial 15 users from API');
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.usersEndpoint}',
        queryParameters: {
          'limit': 15, // Initial fetch is 15 users
          'skip': 0,
        },
      );

      final List<dynamic> users = response.data['users'];
      final userModels = users.map((user) => UserModel.fromJson(user)).toList();

      log('Successfully fetched ${userModels.length} initial users');
      return userModels;
    } catch (e) {
      log('Error fetching initial users: $e');
      throw Exception('Failed to fetch initial users: $e');
    }
  }

  @override
  Future<List<UserModel>> getUsersPaginated({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      log('Fetching paginated users: limit=$limit, skip=$skip');
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.usersEndpoint}',
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      final List<dynamic> users = response.data['users'];
      final userModels = users.map((user) => UserModel.fromJson(user)).toList();

      log('Successfully fetched ${userModels.length} paginated users');
      return userModels;
    } catch (e) {
      log('Error fetching paginated users: $e');
      throw Exception('Failed to fetch paginated users: $e');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers({
    int limit = 30,
    int skip = 0,
  }) async {
    try {
      log('Fetching all users: limit=$limit, skip=$skip');
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.usersEndpoint}',
        queryParameters: {
          'limit': limit,
          'skip': skip,
        },
      );

      final List<dynamic> users = response.data['users'];
      final userModels = users.map((user) => UserModel.fromJson(user)).toList();

      log('Successfully fetched ${userModels.length} users');
      return userModels;
    } catch (e) {
      log('Error fetching all users: $e');
      throw Exception('Failed to fetch all users: $e');
    }
  }

  @override
  Future<List<UserModel>> searchUsers({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      log('Searching users: query="$query", limit=$limit, skip=$skip');
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.usersEndpoint}/search',
        queryParameters: {
          'q': query,
          'limit': limit,
          'skip': skip,
        },
      );

      final List<dynamic> users = response.data['users'];
      final userModels = users.map((user) => UserModel.fromJson(user)).toList();

      log('Successfully found ${userModels.length} users for query "$query"');
      return userModels;
    } catch (e) {
      log('Error searching users: $e');
      throw Exception('Failed to search users: $e');
    }
  }

  @override
  Future<UserModel> getUserById(int id) async {
    try {
      log('Fetching user by id: $id');
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.usersEndpoint}/$id',
      );

      final userModel = UserModel.fromJson(response.data);
      log('Successfully fetched user: ${userModel.username}');
      return userModel;
    } catch (e) {
      log('Error fetching user by id: $e');
      throw Exception('Failed to fetch user: $e');
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(int userId) async {
    try {
      log('Fetching posts for user: $userId');
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.postsEndpoint}/user/$userId',
      );

      final List<dynamic> posts = response.data['posts'];
      final postModels = posts.map((post) => PostModel.fromJson(post)).toList();

      log('Successfully fetched ${postModels.length} posts for user $userId');
      return postModels;
    } catch (e) {
      log('Error fetching user posts: $e');
      throw Exception('Failed to fetch user posts: $e');
    }
  }

  @override
  Future<List<TodoModel>> getUserTodos(int userId) async {
    try {
      log('Fetching todos for user: $userId');
      final response = await dio.get(
        '${AppConfig.baseUrl}${AppConfig.todosEndpoint}/user/$userId',
      );

      final List<dynamic> todos = response.data['todos'];
      final todoModels = todos.map((todo) => TodoModel.fromJson(todo)).toList();

      log('Successfully fetched ${todoModels.length} todos for user $userId');
      return todoModels;
    } catch (e) {
      log('Error fetching user todos: $e');
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
      log('Creating post for user: $userId');
      final response = await dio.post(
        '${AppConfig.baseUrl}${AppConfig.postsEndpoint}/add',
        data: {
          'title': title,
          'body': body,
          'userId': userId,
        },
      );

      final postModel = PostModel.fromJson(response.data);
      log('Successfully created post: ${postModel.title}');
      return postModel;
    } catch (e) {
      log('Error creating post: $e');
      throw Exception('Failed to create post: $e');
    }
  }
}
