import 'dart:developer';
import 'package:dartz/dartz.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/post_local_datasource.dart';
import '../datasources/post_remote_datasource.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/services/connectivity_service.dart';

class PostRepositoryOfflineImpl implements PostRepository {
  final PostLocalDataSource localDataSource;
  final PostRemoteDataSource remoteDataSource;
  final ConnectivityService connectivityService;

  PostRepositoryOfflineImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivityService,
  });

  @override
  Future<Either<Failure, List<Post>>> getAllPosts({
    int limit = 30,
    int skip = 0,
  }) async {
    try {
      // Always try to get data from local storage first (offline-first)
      final localPosts = await localDataSource.getAllPosts();

      // If we have local data, return it immediately
      if (localPosts.isNotEmpty) {
        log('Returning ${localPosts.length} posts from local storage');

        // In background, try to sync with remote if connected
        _backgroundSync();

        return Right(localPosts);
      }

      // If no local data and we're connected, fetch from remote
      final isConnected = await connectivityService.isConnected;
      if (isConnected) {
        return await _fetchFromRemoteAndSave();
      }

      // If no local data and offline, return empty list
      log('No local data and offline, returning empty list');
      return const Right([]);
    } catch (e) {
      log('Error in getAllPosts: $e');
      return const Left(
          CacheFailure('Failed to load posts from local storage'));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getPostsByUser(int userId) async {
    try {
      // Try local first
      final localPosts = await localDataSource.getPostsByUserId(userId);

      if (localPosts.isNotEmpty) {
        log('Returning ${localPosts.length} posts for user $userId from local storage');

        // Background sync if connected
        _backgroundSync();

        return Right(localPosts);
      }

      // If no local data and connected, fetch from remote
      final isConnected = await connectivityService.isConnected;
      if (isConnected) {
        try {
          final remotePosts = await remoteDataSource.getPostsByUser(userId);
          // Save to local
          await localDataSource.savePosts(remotePosts);
          log('Fetched ${remotePosts.length} posts for user $userId from remote');
          return Right(remotePosts);
        } catch (e) {
          log('Error fetching posts from remote: $e');
          return const Left(ServerFailure('Failed to fetch posts from server'));
        }
      }

      // No local data and offline
      return const Right([]);
    } catch (e) {
      log('Error in getPostsByUser: $e');
      return const Left(CacheFailure('Failed to load posts for user'));
    }
  }

  @override
  Future<Either<Failure, List<Post>>> getPostsPaginated({
    int limit = 30,
    int skip = 0,
  }) async {
    try {
      log('PostRepository: Pagination requested - limit: $limit, skip: $skip');

      // For pagination, we need to fetch from remote to get more data
      final isConnected = await connectivityService.isConnected;
      if (isConnected) {
        log('PostRepository: Connected - fetching paginated posts from remote');
        try {
          final remotePosts = await remoteDataSource.getPostsPaginated(
            limit: limit,
            skip: skip,
          );

          // Save new posts to local storage
          await localDataSource.savePosts(remotePosts);
          log('PostRepository: Fetched and saved ${remotePosts.length} posts via pagination');

          return Right(remotePosts);
        } catch (e) {
          log('PostRepository: Error fetching paginated posts from remote: $e');
          // Fall back to local data with pagination
          return _getLocalPostsPaginated(limit, skip);
        }
      } else {
        log('PostRepository: Offline - using local paginated posts');
        // If offline, get paginated data from local storage
        return _getLocalPostsPaginated(limit, skip);
      }
    } catch (e) {
      log('Error in getPostsPaginated: $e');
      return const Left(CacheFailure('Failed to load paginated posts'));
    }
  }

  /// Get paginated posts from local storage
  Future<Either<Failure, List<Post>>> _getLocalPostsPaginated(
    int limit,
    int skip,
  ) async {
    try {
      final allLocalPosts = await localDataSource.getAllPosts();

      // Apply pagination to local data
      final startIndex = skip;
      final endIndex = skip + limit;

      if (startIndex >= allLocalPosts.length) {
        // No more data available
        log('PostRepository: No more local posts available (skip: $skip, total: ${allLocalPosts.length})');
        return const Right([]);
      }

      final paginatedPosts = allLocalPosts.sublist(
        startIndex,
        endIndex > allLocalPosts.length ? allLocalPosts.length : endIndex,
      );

      log('PostRepository: Returning ${paginatedPosts.length} local posts from pagination');
      return Right(paginatedPosts);
    } catch (e) {
      log('Error getting paginated local posts: $e');
      return const Left(CacheFailure('Failed to get paginated local posts'));
    }
  }

  /// Get post by ID
  Future<Either<Failure, Post>> getPostById(int id) async {
    try {
      // Try local first
      final localPost = await localDataSource.getPostById(id);
      if (localPost != null) {
        log('Returning post $id from local storage');
        return Right(localPost);
      }

      // If not found locally and connected, try remote
      final isConnected = await connectivityService.isConnected;
      if (isConnected) {
        try {
          final remotePosts = await remoteDataSource.getAllPosts();
          final remotePost = remotePosts.where((p) => p.id == id).firstOrNull;

          if (remotePost != null) {
            // Save to local for future offline access
            await localDataSource.savePost(remotePost);
            log('Fetched post $id from remote and saved locally');
            return Right(remotePost);
          }
        } catch (e) {
          log('Error fetching post from remote: $e');
          return const Left(ServerFailure('Failed to fetch post from server'));
        }
      }

      // Not found locally and offline
      return const Left(CacheFailure('Post not found'));
    } catch (e) {
      log('Error in getPostById: $e');
      return const Left(CacheFailure('Failed to load post'));
    }
  }

  /// Background sync with remote when connected
  void _backgroundSync() async {
    try {
      final isConnected = await connectivityService.isConnected;
      if (isConnected) {
        log('Starting background sync for posts...');
        await _fetchFromRemoteAndSave();
      }
    } catch (e) {
      log('Background sync failed: $e');
    }
  }

  /// Fetch from remote and save to local
  Future<Either<Failure, List<Post>>> _fetchFromRemoteAndSave() async {
    try {
      final remotePosts = await remoteDataSource.getAllPosts();
      await localDataSource.savePosts(remotePosts);
      log('Fetched and saved ${remotePosts.length} posts from remote');
      return Right(remotePosts);
    } catch (e) {
      log('Error fetching from remote: $e');
      return const Left(ServerFailure('Failed to fetch from server'));
    }
  }
}
