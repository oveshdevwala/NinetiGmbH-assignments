import 'dart:developer';
import 'package:objectbox/objectbox.dart';
import '../models/todo_entity.dart';
import '../../domain/entities/todo.dart';

abstract class TodoLocalDataSource {
  Future<List<Todo>> getAllTodos();
  Future<Todo?> getTodoById(int id);
  Future<List<Todo>> getTodosByUserId(int userId);
  Future<void> saveTodos(List<Todo> todos);
  Future<void> saveTodo(Todo todo);
  Future<void> deleteTodo(int id);
  Future<void> clearAllTodos();
  Future<List<Todo>> getUnsyncedTodos();
  Future<void> markTodoAsSynced(int id);
  Future<int> getTodosCount();
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Box<TodoEntity> _todoBox;

  TodoLocalDataSourceImpl({required Box<TodoEntity> todoBox})
      : _todoBox = todoBox;

  @override
  Future<List<Todo>> getAllTodos() async {
    try {
      final entities = _todoBox.getAll();
      final activeEntities =
          entities.where((entity) => !entity.isDeleted).toList();

      // Sort by updated date
      activeEntities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return activeEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting all todos from local storage: $e');
      return [];
    }
  }

  @override
  Future<Todo?> getTodoById(int id) async {
    try {
      final entity = _todoBox.get(id);

      if (entity != null && !entity.isDeleted) {
        return entity.toDomain();
      }
      return null;
    } catch (e) {
      log('Error getting todo by id from local storage: $e');
      return null;
    }
  }

  @override
  Future<List<Todo>> getTodosByUserId(int userId) async {
    try {
      final entities = _todoBox.getAll();
      final userTodos = entities
          .where((entity) => entity.userId == userId && !entity.isDeleted)
          .toList();

      // Sort by updated date
      userTodos.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return userTodos.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting todos by user id from local storage: $e');
      return [];
    }
  }

  @override
  Future<void> saveTodos(List<Todo> todos) async {
    try {
      final entities =
          todos.map((todo) => TodoEntity.fromDomain(todo)).toList();

      // Update existing or insert new
      for (final entity in entities) {
        final existing = _todoBox.get(entity.id);

        if (existing != null) {
          // Update existing entity
          final updated = existing.copyWith(
            todo: entity.todo,
            completed: entity.completed,
            userId: entity.userId,
            updatedAt: DateTime.now(),
            isSynced: true,
          );
          _todoBox.put(updated);
        } else {
          // Insert new entity
          _todoBox.put(entity);
        }
      }

      log('Saved ${todos.length} todos to local storage');
    } catch (e) {
      log('Error saving todos to local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveTodo(Todo todo) async {
    try {
      final entity = TodoEntity.fromDomain(todo);

      final existing = _todoBox.get(entity.id);

      if (existing != null) {
        // Update existing entity
        final updated = existing.copyWith(
          todo: entity.todo,
          completed: entity.completed,
          userId: entity.userId,
          updatedAt: DateTime.now(),
          isSynced: true,
        );
        _todoBox.put(updated);
      } else {
        // Insert new entity
        _todoBox.put(entity);
      }

      log('Saved todo ${todo.id} to local storage');
    } catch (e) {
      log('Error saving todo to local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      final entity = _todoBox.get(id);

      if (entity != null) {
        // Soft delete - mark as deleted instead of removing
        final updated = entity.copyWith(
          isDeleted: true,
          updatedAt: DateTime.now(),
          isSynced: false,
        );
        _todoBox.put(updated);
        log('Marked todo $id as deleted in local storage');
      }
    } catch (e) {
      log('Error deleting todo from local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllTodos() async {
    try {
      _todoBox.removeAll();
      log('Cleared all todos from local storage');
    } catch (e) {
      log('Error clearing todos from local storage: $e');
      rethrow;
    }
  }

  @override
  Future<List<Todo>> getUnsyncedTodos() async {
    try {
      final entities = _todoBox.getAll();
      final unsyncedEntities =
          entities.where((entity) => !entity.isSynced).toList();

      return unsyncedEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting unsynced todos from local storage: $e');
      return [];
    }
  }

  @override
  Future<void> markTodoAsSynced(int id) async {
    try {
      final entity = _todoBox.get(id);

      if (entity != null) {
        final updated = entity.copyWith(
          isSynced: true,
          updatedAt: DateTime.now(),
        );
        _todoBox.put(updated);
        log('Marked todo $id as synced');
      }
    } catch (e) {
      log('Error marking todo as synced: $e');
      rethrow;
    }
  }

  @override
  Future<int> getTodosCount() async {
    try {
      final entities = _todoBox.getAll();
      return entities.where((entity) => !entity.isDeleted).length;
    } catch (e) {
      log('Error getting todos count: $e');
      return 0;
    }
  }
}
