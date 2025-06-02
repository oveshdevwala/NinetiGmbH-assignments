part of 'users_bloc.dart';

class UsersState extends Equatable {
  final List<User> users;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasReachedMax;
  final String? error;
  final bool isSearching;
  final String searchQuery;
  final int currentSkip;

  const UsersState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedMax = false,
    this.error,
    this.isSearching = false,
    this.searchQuery = '',
    this.currentSkip = 0,
  });

  UsersState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasReachedMax,
    String? error,
    bool? isSearching,
    String? searchQuery,
    int? currentSkip,
  }) {
    return UsersState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      error: error ?? this.error,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      currentSkip: currentSkip ?? this.currentSkip,
    );
  }

  @override
  List<Object?> get props => [
        users,
        isLoading,
        isLoadingMore,
        hasReachedMax,
        error,
        isSearching,
        searchQuery,
        currentSkip,
      ];
}
