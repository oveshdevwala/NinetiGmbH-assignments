part of 'users_cubit.dart';

class UsersCubitState {
  final List<User> users;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasReachedMax;
  final int currentSkip;
  final bool isSearching;
  final String searchQuery;
  final bool isOffline;
  final bool isSyncing;
  final DateTime? lastSyncTime;

  const UsersCubitState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasReachedMax = false,
    this.currentSkip = 0,
    this.isSearching = false,
    this.searchQuery = '',
    this.isOffline = false,
    this.isSyncing = false,
    this.lastSyncTime,
  });

  factory UsersCubitState.initial() {
    return const UsersCubitState();
  }

  UsersCubitState toLoading() {
    return copyWith(isLoading: true, error: null);
  }

  UsersCubitState toLoadingMore() {
    return copyWith(isLoadingMore: true, error: null);
  }

  UsersCubitState toSuccess(List<User> users, {bool hasReachedMax = false}) {
    return copyWith(
      users: users,
      isLoading: false,
      isLoadingMore: false,
      error: null,
      hasReachedMax: hasReachedMax,
      currentSkip: users.length,
    );
  }

  UsersCubitState toError(String error) {
    return copyWith(isLoading: false, isLoadingMore: false, error: error);
  }

  UsersCubitState toOffline() {
    return copyWith(
        isOffline: true, isLoading: false, isLoadingMore: false, error: null);
  }

  UsersCubitState toSyncing() {
    return copyWith(isSyncing: true, error: null);
  }

  UsersCubitState toSyncCompleted() {
    return copyWith(
        isSyncing: false, lastSyncTime: DateTime.now(), isOffline: false);
  }

  UsersCubitState copyWith({
    List<User>? users,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasReachedMax,
    int? currentSkip,
    bool? isSearching,
    String? searchQuery,
    bool? isOffline,
    bool? isSyncing,
    DateTime? lastSyncTime,
  }) {
    return UsersCubitState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentSkip: currentSkip ?? this.currentSkip,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      isOffline: isOffline ?? this.isOffline,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }
}
