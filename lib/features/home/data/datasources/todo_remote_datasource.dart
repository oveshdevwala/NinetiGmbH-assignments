import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/typedef.dart';
import '../model/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodosByUser(int userId);
  Future<List<TodoModel>> getAllTodos({
    int limit = 30,
    int skip = 0,
  });
  Future<List<TodoModel>> getTodosPaginated({
    int limit = 30,
    int skip = 0,
  });
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final Dio dio;

  const TodoRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TodoModel>> getTodosByUser(int userId) async {
    try {
      final response = await dio.get('/todos/user/$userId');

      if (response.statusCode == 200) {
        final data = response.data as DataMap;
        final todos = data['todos'] as List<dynamic>;
        return todos
            .map((todo) => TodoModel.fromJson(todo as DataMap))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch user todos',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<TodoModel>> getAllTodos({
    int limit = 30,
    int skip = 0,
  }) async {
    try {
      final response = await dio.get('/todos', queryParameters: {
        'limit': limit,
        'skip': skip,
      });

      if (response.statusCode == 200) {
        final data = response.data as DataMap;
        final todos = data['todos'] as List<dynamic>;
        return todos
            .map((todo) => TodoModel.fromJson(todo as DataMap))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch todos',
          statusCode: response.statusCode!,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Network error occurred',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Unexpected error occurred: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<TodoModel>> getTodosPaginated({
    int limit = 30,
    int skip = 0,
  }) async {
    return getAllTodos(limit: limit, skip: skip);
  }
}
