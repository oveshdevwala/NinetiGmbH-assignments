
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/todo.dart';
import '../../../domain/repositories/todo_repository.dart';

part 'todos_event.dart';
part 'todos_state.dart';
// Bloc
class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final TodoRepository todoRepository;

  TodosBloc({required this.todoRepository}) : super(const TodosState()) {
    on<LoadInitialTodosEvent>(_onLoadInitialTodos);
    on<LoadAllTodosEvent>(_onLoadAllTodos);
    on<LoadMoreTodosEvent>(_onLoadMoreTodos);
    on<RefreshTodosEvent>(_onRefreshTodos);
    on<LoadUserTodosEvent>(_onLoadUserTodos);
  }

  Future<void> _onLoadInitialTodos(
    LoadInitialTodosEvent event,
    Emitter<TodosState> emit,
  ) async {
    if (state.isInitialized) return; // Already initialized, skip

    emit(state.copyWith(isLoading: true, error: null));

    final result = await todoRepository.getAllTodos(
      limit: state.pageSize,
      skip: 0,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
        isInitialized: true,
      )),
      (todos) => emit(state.copyWith(
        isLoading: false,
        todos: todos,
        error: null,
        isInitialized: true,
        currentPage: 1,
        hasReachedMax: todos.length < state.pageSize,
      )),
    );
  }

  Future<void> _onLoadAllTodos(
    LoadAllTodosEvent event,
    Emitter<TodosState> emit,
  ) async {
    // Use initialized data if available, otherwise load initial data
    if (!state.isInitialized) {
      add(const LoadInitialTodosEvent());
      return;
    }
  }

  Future<void> _onLoadMoreTodos(
    LoadMoreTodosEvent event,
    Emitter<TodosState> emit,
  ) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = await todoRepository.getTodosPaginated(
      limit: state.pageSize,
      skip: state.currentPage * state.pageSize,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingMore: false,
        error: failure.message,
      )),
      (newTodos) {
        final allTodos = List<Todo>.from(state.todos)..addAll(newTodos);
        emit(state.copyWith(
          isLoadingMore: false,
          todos: allTodos,
          error: null,
          currentPage: state.currentPage + 1,
          hasReachedMax: newTodos.length < state.pageSize,
        ));
      },
    );
  }

  Future<void> _onRefreshTodos(
    RefreshTodosEvent event,
    Emitter<TodosState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      error: null,
      todos: [],
      currentPage: 0,
      hasReachedMax: false,
    ));

    final result = await todoRepository.getAllTodos(
      limit: state.pageSize,
      skip: 0,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        error: failure.message,
      )),
      (todos) => emit(state.copyWith(
        isLoading: false,
        todos: todos,
        error: null,
        currentPage: 1,
        hasReachedMax: todos.length < state.pageSize,
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
