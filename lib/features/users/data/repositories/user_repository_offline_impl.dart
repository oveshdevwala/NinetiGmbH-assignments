import 'dart:developer';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../shared/services/connectivity_service.dart';
import '../../domain/entities/user.dart';
import '../../../home/domain/entities/post.dart';
import '../../../home/domain/entities/todo.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../datasources/user_local_datasource.dart';

class UserRepositoryOfflineImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  UserRepositoryOfflineImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  ResultFuture<List<User>> getUsers({
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      // Check if this is the initial load (skip = 0)
      if (skip == 0) {
        return await _getInitialUsers();
      } else {
        return await _getPaginatedUsers(limit: limit, skip: skip);
      }
    } catch (e) {
      log('Error in getUsers: $e');
      return Result.failure(const CacheFailure('Failed to load users'));
    }
  }

  /// Handle initial load - fetch 15 users and store only first 20 in ObjectBox
  ResultFuture<List<User>> _getInitialUsers() async {
    try {
      // Try to get initial batch from local storage first
      final localUsers = await localDataSource.getInitialBatchUsers();

      if (localUsers.isNotEmpty) {
        log('Returning ${localUsers.length} users from initial batch in local storage');

        // Background sync if connected
        _backgroundSync();

        return Result.success(localUsers);
      }

      // If no local data and connected, fetch from remote
      final isConnected = await connectivityService.isConnected;
      if (isConnected) {
        try {
          log('Fetching initial 15 users from remote API');
          final remoteUsers = await remoteDataSource.getInitialUsers();

          // Convert UserModel to User domain entities
          final users = remoteUsers
              .map((userModel) => User(
                    id: userModel.id,
                    firstName: userModel.firstName,
                    lastName: userModel.lastName,
                    username: userModel.username,
                    email: userModel.email,
                    phone: userModel.phone,
                    image: userModel.image,
                    gender: userModel.gender,
                    birthDate: userModel.birthDate,
                    address: userModel.address,
                    company: userModel.company,
                  ))
              .toList();

          // Save to local as initial batch
          await localDataSource.saveUsers(users, isInitialBatch: true);

          log('Fetched and saved ${users.length} initial users');
          return Result.success(users);
        } catch (e) {
          log('Error fetching initial users from remote: $e');
          return Result.failure(
              const ServerFailure('Failed to fetch initial users from server'));
        }
      }

      // No local data and offline
      return Result.success(<User>[]);
    } catch (e) {
      log('Error in _getInitialUsers: $e');
      return Result.failure(const CacheFailure('Failed to load initial users'));
    }
  }

  /// Handle pagination - fetch from API but don't store in ObjectBox
  ResultFuture<List<User>> _getPaginatedUsers({
    required int limit,
    required int skip,
  }) async {
    try {
      final isConnected = await connectivityService.isConnected;

      if (!isConnected) {
        log('No internet connection for pagination');
        return Result.failure(const NetworkFailure('No internet connection'));
      }

      try {
        log('Fetching paginated users: limit=$limit, skip=$skip');
        final remoteUsers = await remoteDataSource.getUsersPaginated(
          limit: limit,
          skip: skip,
        );

        // Convert UserModel to User domain entities
        final users = remoteUsers
            .map((userModel) => User(
                  id: userModel.id,
                  firstName: userModel.firstName,
                  lastName: userModel.lastName,
                  username: userModel.username,
                  email: userModel.email,
                  phone: userModel.phone,
                  image: userModel.image,
                  gender: userModel.gender,
                  birthDate: userModel.birthDate,
                  address: userModel.address,
                  company: userModel.company,
                ))
            .toList();

        log('Successfully fetched ${users.length} paginated users (not saving to local)');
        return Result.success(users);
      } catch (e) {
        log('Error fetching paginated users from remote: $e');
        return Result.failure(
            const ServerFailure('Failed to fetch paginated users'));
      }
    } catch (e) {
      log('Error in _getPaginatedUsers: $e');
      return Result.failure(
          const CacheFailure('Failed to load paginated users'));
    }
  }

  @override
  ResultFuture<List<User>> searchUsers({
    required String query,
    int limit = 20,
    int skip = 0,
  }) async {
    try {
      final isConnected = await connectivityService.isConnected;

      if (!isConnected) {
        // When offline, search only in local initial batch
        final localUsers = await localDataSource.getInitialBatchUsers();
        final filteredUsers = localUsers
            .where((user) =>
                user.firstName.toLowerCase().contains(query.toLowerCase()) ||
                user.lastName.toLowerCase().contains(query.toLowerCase()) ||
                user.username.toLowerCase().contains(query.toLowerCase()) ||
                user.email.toLowerCase().contains(query.toLowerCase()))
            .toList();

        log('Found ${filteredUsers.length} users locally for query "$query"');
        return Result.success(filteredUsers);
      }

      try {
        final remoteUsers = await remoteDataSource.searchUsers(
          query: query,
          limit: limit,
          skip: skip,
        );

        // Convert UserModel to User domain entities
        final users = remoteUsers
            .map((userModel) => User(
                  id: userModel.id,
                  firstName: userModel.firstName,
                  lastName: userModel.lastName,
                  username: userModel.username,
                  email: userModel.email,
                  phone: userModel.phone,
                  image: userModel.image,
                  gender: userModel.gender,
                  birthDate: userModel.birthDate,
                  address: userModel.address,
                  company: userModel.company,
                ))
            .toList();

        log('Found ${users.length} users remotely for query "$query"');
        return Result.success(users);
      } catch (e) {
        log('Error searching users remotely: $e');
        return Result.failure(const ServerFailure('Failed to search users'));
      }
    } catch (e) {
      log('Error in searchUsers: $e');
      return Result.failure(const CacheFailure('Failed to search users'));
    }
  }

  @override
  ResultFuture<User> getUserById(int id) async {
    try {
      // Try local first
      final localUser = await localDataSource.getUserById(id);
      if (localUser != null) {
        log('Returning user $id from local storage');
        return Result.success(localUser);
      }

      // If not in local and connected, fetch from remote
      final isConnected = await connectivityService.isConnected;
      if (isConnected) {
        try {
          final remoteUser = await remoteDataSource.getUserById(id);

          // Convert UserModel to User domain entity
          final user = User(
            id: remoteUser.id,
            firstName: remoteUser.firstName,
            lastName: remoteUser.lastName,
            username: remoteUser.username,
            email: remoteUser.email,
            phone: remoteUser.phone,
            image: remoteUser.image,
            gender: remoteUser.gender,
            birthDate: remoteUser.birthDate,
            address: remoteUser.address,
            company: remoteUser.company,
          );

          // Don't save individual users to local (only initial batch is saved)
          log('Fetched user $id from remote');
          return Result.success(user);
        } catch (e) {
          log('Error fetching user $id from remote: $e');
          return Result.failure(
              const ServerFailure('Failed to fetch user from server'));
        }
      }

      // User not found locally and offline
      return Result.failure(const CacheFailure('User not found'));
    } catch (e) {
      log('Error in getUserById: $e');
      return Result.failure(const CacheFailure('Failed to load user'));
    }
  }

  @override
  ResultFuture<List<Post>> getUserPosts(int userId) async {
    try {
      final isConnected = await connectivityService.isConnected;

      if (!isConnected) {
        return Result.failure(const NetworkFailure('No internet connection'));
      }

      try {
        final remotePosts = await remoteDataSource.getUserPosts(userId);

        // Convert PostModel to Post domain entities
        final posts = remotePosts
            .map((postModel) => Post(
                  id: postModel.id,
                  title: postModel.title,
                  body: postModel.body,
                  userId: postModel.userId,
                  tags: postModel.tags,
                  reactions: postModel.reactions,
                  views: postModel.views,
                ))
            .toList();

        log('Fetched ${posts.length} posts for user $userId');
        return Result.success(posts);
      } catch (e) {
        log('Error fetching posts for user $userId: $e');
        return Result.failure(
            const ServerFailure('Failed to fetch user posts'));
      }
    } catch (e) {
      log('Error in getUserPosts: $e');
      return Result.failure(const CacheFailure('Failed to load user posts'));
    }
  }

  @override
  ResultFuture<List<Todo>> getUserTodos(int userId) async {
    try {
      final isConnected = await connectivityService.isConnected;

      if (!isConnected) {
        return Result.failure(const NetworkFailure('No internet connection'));
      }

      try {
        final remoteTodos = await remoteDataSource.getUserTodos(userId);

        // Convert TodoModel to Todo domain entities
        final todos = remoteTodos
            .map((todoModel) => Todo(
                  id: todoModel.id,
                  todo: todoModel.todo,
                  completed: todoModel.completed,
                  userId: todoModel.userId,
                ))
            .toList();

        log('Fetched ${todos.length} todos for user $userId');
        return Result.success(todos);
      } catch (e) {
        log('Error fetching todos for user $userId: $e');
        return Result.failure(
            const ServerFailure('Failed to fetch user todos'));
      }
    } catch (e) {
      log('Error in getUserTodos: $e');
      return Result.failure(const CacheFailure('Failed to load user todos'));
    }
  }

  @override
  ResultFuture<Post> createPost({
    required String title,
    required String body,
    required int userId,
  }) async {
    try {
      final isConnected = await connectivityService.isConnected;

      if (!isConnected) {
        return Result.failure(const NetworkFailure('No internet connection'));
      }

      try {
        final newPostModel = await remoteDataSource.createPost(
          title: title,
          body: body,
          userId: userId,
        );

        // Convert PostModel to Post domain entity
        final newPost = Post(
          id: newPostModel.id,
          title: newPostModel.title,
          body: newPostModel.body,
          userId: newPostModel.userId,
          tags: newPostModel.tags,
          reactions: newPostModel.reactions,
          views: newPostModel.views,
        );

        log('Created post: ${newPost.title}');
        return Result.success(newPost);
      } catch (e) {
        log('Error creating post: $e');
        return Result.failure(const ServerFailure('Failed to create post'));
      }
    } catch (e) {
      log('Error in createPost: $e');
      return Result.failure(const CacheFailure('Failed to create post'));
    }
  }

  /// Background sync when network is available
  void _backgroundSync() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        final isConnected = await connectivityService.isConnected;
        if (isConnected) {
          log('Performing background sync of initial users');
          final remoteUsers = await remoteDataSource.getInitialUsers();

          // Convert UserModel to User domain entities
          final users = remoteUsers
              .map((userModel) => User(
                    id: userModel.id,
                    firstName: userModel.firstName,
                    lastName: userModel.lastName,
                    username: userModel.username,
                    email: userModel.email,
                    phone: userModel.phone,
                    image: userModel.image,
                    gender: userModel.gender,
                    birthDate: userModel.birthDate,
                    address: userModel.address,
                    company: userModel.company,
                  ))
              .toList();

          await localDataSource.saveUsers(users, isInitialBatch: true);
          log('Background sync completed');
        }
      } catch (e) {
        log('Background sync failed: $e');
      }
    });
  }

  /// Force refresh of initial batch
  ResultFuture<List<User>> forceRefreshInitialBatch() async {
    try {
      final isConnected = await connectivityService.isConnected;

      if (!isConnected) {
        return Result.failure(const NetworkFailure('No internet connection'));
      }

      try {
        log('Force refreshing initial batch');
        final remoteUsers = await remoteDataSource.getInitialUsers();

        // Convert UserModel to User domain entities
        final users = remoteUsers
            .map((userModel) => User(
                  id: userModel.id,
                  firstName: userModel.firstName,
                  lastName: userModel.lastName,
                  username: userModel.username,
                  email: userModel.email,
                  phone: userModel.phone,
                  image: userModel.image,
                  gender: userModel.gender,
                  birthDate: userModel.birthDate,
                  address: userModel.address,
                  company: userModel.company,
                ))
            .toList();

        // Clear old initial batch and save new one
        await localDataSource.clearAllUsers();
        await localDataSource.saveUsers(users, isInitialBatch: true);

        log('Force refresh completed with ${users.length} users');
        return Result.success(users);
      } catch (e) {
        log('Error force refreshing initial batch: $e');
        return Result.failure(const ServerFailure('Failed to refresh users'));
      }
    } catch (e) {
      log('Error in forceRefreshInitialBatch: $e');
      return Result.failure(const CacheFailure('Failed to refresh users'));
    }
  }

  /// Get local cache info
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final count = await localDataSource.getUsersCount();
      final initialBatchUsers = await localDataSource.getInitialBatchUsers();

      return {
        'total_cached_users': count,
        'initial_batch_count': initialBatchUsers.length,
        'has_initial_batch': initialBatchUsers.isNotEmpty,
      };
    } catch (e) {
      log('Error getting cache info: $e');
      return {};
    }
  }
}
