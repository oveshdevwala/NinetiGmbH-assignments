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

// State
class TodosState {
  final List<Todo> todos;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? error;
  final bool isInitialized;
  final int currentPage;
  final int pageSize;

  const TodosState({
    this.todos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.error,
    this.isInitialized = false,
    this.currentPage = 0,
    this.pageSize = 30,
  });

  TodosState copyWith({
    List<Todo>? todos,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? error,
    bool? isInitialized,
    int? currentPage,
    int? pageSize,
  }) {
    return TodosState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

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
