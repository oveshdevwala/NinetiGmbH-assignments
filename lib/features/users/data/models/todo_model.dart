import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/todo.dart';
import '../../../../core/utils/typedef.dart';

part 'todo_model.g.dart';

@JsonSerializable()
class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.todo,
    required super.completed,
    required super.userId,
  });

  factory TodoModel.fromJson(DataMap json) => _$TodoModelFromJson(json);

  DataMap toJson() => _$TodoModelToJson(this);

  TodoModel copyWith({
    int? id,
    String? todo,
    bool? completed,
    int? userId,
  }) {
    return TodoModel(
      id: id ?? this.id,
      todo: todo ?? this.todo,
      completed: completed ?? this.completed,
      userId: userId ?? this.userId,
    );
  }
}
