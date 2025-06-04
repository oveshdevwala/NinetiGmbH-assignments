import 'package:objectbox/objectbox.dart';
import '../../domain/entities/todo.dart';

@Entity()
class TodoEntity {
  @Id()
  int id;

  String todo;
  bool completed;
  int userId;

  // Sync related fields
  DateTime createdAt;
  DateTime updatedAt;
  bool isSynced;
  bool isDeleted;

  TodoEntity({
    this.id = 0,
    required this.todo,
    required this.completed,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  // Convert to domain entity
  Todo toDomain() {
    return Todo(
      id: id,
      todo: todo,
      completed: completed,
      userId: userId,
    );
  }

  // Convert from domain entity
  static TodoEntity fromDomain(Todo todo) {
    final now = DateTime.now();
    return TodoEntity(
      id: todo.id,
      todo: todo.todo,
      completed: todo.completed,
      userId: todo.userId,
      createdAt: now,
      updatedAt: now,
      isSynced: true,
    );
  }

  // Convert from JSON (API response)
  static TodoEntity fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return TodoEntity(
      id: json['id'] ?? 0,
      todo: json['todo'] ?? '',
      completed: json['completed'] ?? false,
      userId: json['userId'] ?? 0,
      createdAt: now,
      updatedAt: now,
      isSynced: true,
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'todo': todo,
      'completed': completed,
      'userId': userId,
    };
  }

  TodoEntity copyWith({
    int? id,
    String? todo,
    bool? completed,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
