import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/typedef.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPostsByUser(int userId);
  Future<List<PostModel>> getAllPosts({
    int limit = 30,
    int skip = 0,
  });
  Future<List<PostModel>> getPostsPaginated({
    int limit = 30,
    int skip = 0,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  const PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PostModel>> getPostsByUser(int userId) async {
    try {
      final response = await dio.get('/posts/user/$userId');

      if (response.statusCode == 200) {
        final data = response.data as DataMap;
        final posts = data['posts'] as List<dynamic>;
        return posts
            .map((post) => PostModel.fromJson(post as DataMap))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch user posts',
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
  Future<List<PostModel>> getAllPosts({
    int limit = 30,
    int skip = 0,
  }) async {
    try {
      final response = await dio.get('/posts', queryParameters: {
        'limit': limit,
        'skip': skip,
      });

      if (response.statusCode == 200) {
        final data = response.data as DataMap;
        final posts = data['posts'] as List<dynamic>;
        return posts
            .map((post) => PostModel.fromJson(post as DataMap))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch posts',
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
  Future<List<PostModel>> getPostsPaginated({
    int limit = 30,
    int skip = 0,
  }) async {
    return getAllPosts(limit: limit, skip: skip);
  }
}
