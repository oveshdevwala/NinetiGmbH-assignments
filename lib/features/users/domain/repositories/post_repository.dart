import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post.dart';

abstract class PostRepository {
  Future<Either<Failure, List<Post>>> getPostsByUser(int userId);
  Future<Either<Failure, List<Post>>> getAllPosts({
    int limit = 30,
    int skip = 0,
  });
  Future<Either<Failure, List<Post>>> getPostsPaginated({
    int limit = 30,
    int skip = 0,
  });
}
