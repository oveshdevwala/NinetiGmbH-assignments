part of 'todos_bloc.dart';
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
