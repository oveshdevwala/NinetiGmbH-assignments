import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UserRepository userRepository;

  UsersBloc({required this.userRepository}) : super(const UsersState()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<SearchUsersEvent>(_onSearchUsers);
    on<LoadMoreUsersEvent>(_onLoadMoreUsers);
    on<RefreshUsersEvent>(_onRefreshUsers);
  }

  Future<void> _onLoadUsers(
      LoadUsersEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    final result = await userRepository.getUsers(
      limit: event.limit,
      skip: 0,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        isLoading: false,
        users: result.data!,
        hasReachedMax: result.data!.length < event.limit,
        currentSkip: result.data!.length,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.failure!.toString(),
      ));
    }
  }

  Future<void> _onSearchUsers(
      SearchUsersEvent event, Emitter<UsersState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    if (event.query.isEmpty) {
      add(const LoadUsersEvent());
      return;
    }

    final result = await userRepository.searchUsers(
      query: event.query,
      limit: event.limit,
      skip: 0,
    );

    if (result.isSuccess) {
      emit(state.copyWith(
        isLoading: false,
        users: result.data!,
        isSearching: true,
        searchQuery: event.query,
        hasReachedMax: result.data!.length < event.limit,
        currentSkip: result.data!.length,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: result.failure!.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreUsers(
      LoadMoreUsersEvent event, Emitter<UsersState> emit) async {
    if (state.hasReachedMax || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));

    final result = state.isSearching
        ? await userRepository.searchUsers(
            query: state.searchQuery,
            limit: event.limit,
            skip: state.currentSkip,
          )
        : await userRepository.getUsers(
            limit: event.limit,
            skip: state.currentSkip,
          );

    if (result.isSuccess) {
      final newUsers = result.data!;
      emit(state.copyWith(
        isLoadingMore: false,
        users: [...state.users, ...newUsers],
        hasReachedMax: newUsers.length < event.limit,
        currentSkip: state.currentSkip + newUsers.length,
      ));
    } else {
      emit(state.copyWith(
        isLoadingMore: false,
        error: result.failure!.toString(),
      ));
    }
  }

  Future<void> _onRefreshUsers(
      RefreshUsersEvent event, Emitter<UsersState> emit) async {
    emit(const UsersState());
    add(const LoadUsersEvent());
  }
}
