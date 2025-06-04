import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodosByUser(int userId);
  Future<Either<Failure, List<Todo>>> getAllTodos({
    int limit = 30,
    int skip = 0,
  });
  Future<Either<Failure, List<Todo>>> getTodosPaginated({
    int limit = 30,
    int skip = 0,
  });
}
