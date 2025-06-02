import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

// Events
abstract class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllTodosEvent extends TodosEvent {
  const LoadAllTodosEvent();
}

class LoadUserTodosEvent extends TodosEvent {
  final int userId;

  const LoadUserTodosEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

// State
class TodosState {
  final List<Todo> todos;
  final bool isLoading;
  final String? error;

  const TodosState({
    this.todos = const [],
    this.isLoading = false,
    this.error,
  });

  TodosState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    String? error,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Bloc
class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodoRepository todoRepository;

  TodosBloc({required this.todoRepository}) : super(const TodosState()) {
    on<LoadAllTodosEvent>(_onLoadAllTodos);
    on<LoadUserTodosEvent>(_onLoadUserTodos);
  }

  Future<void> _onLoadAllTodos(
    LoadAllTodosEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await todoRepository.getAllTodos();
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (todos) => emit(state.copyWith(
        isLoading: false,
        todos: todos,
        error: null,
      )),
    );
  }

  Future<void> _onLoadUserTodos(
    LoadUserTodosEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await todoRepository.getTodosByUser(event.userId);
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (todos) => emit(state.copyWith(
        isLoading: false,
        todos: todos,
        error: null,
      )),
    );
  }
}
