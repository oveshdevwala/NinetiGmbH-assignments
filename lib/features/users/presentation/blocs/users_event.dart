part of 'users_bloc.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends UsersEvent {
  final int limit;

  const LoadUsersEvent({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class SearchUsersEvent extends UsersEvent {
  final String query;
  final int limit;

  const SearchUsersEvent({
    required this.query,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, limit];
}

class LoadMoreUsersEvent extends UsersEvent {
  final int limit;

  const LoadMoreUsersEvent({this.limit = 20});

  @override
  List<Object?> get props => [limit];
}

class RefreshUsersEvent extends UsersEvent {
  const RefreshUsersEvent();
}
