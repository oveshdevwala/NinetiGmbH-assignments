part of 'todos_bloc.dart';
abstract class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialTodosEvent extends TodosEvent {
  const LoadInitialTodosEvent();
}

class LoadAllTodosEvent extends TodosEvent {
  const LoadAllTodosEvent();
}

class LoadMoreTodosEvent extends TodosEvent {
  const LoadMoreTodosEvent();
}

class RefreshTodosEvent extends TodosEvent {
  const RefreshTodosEvent();
}

class LoadUserTodosEvent extends TodosEvent {
  final int userId;

  const LoadUserTodosEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
