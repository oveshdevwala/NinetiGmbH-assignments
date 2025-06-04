import 'dart:developer';
import 'package:objectbox/objectbox.dart';
import '../../../home/data/model/user_entity.dart';
import '../../domain/entities/user.dart';
import '../../../../objectbox.g.dart'; // For UserEntity_

abstract class UserLocalDataSource {
  Future<List<User>> getAllUsers();
  Future<User?> getUserById(int id);
  Future<List<User>> getUsersPaginated({int limit = 20, int skip = 0});
  Future<void> saveUsers(List<User> users, {bool isInitialBatch = false});
  Future<void> saveUser(User user, {bool isInitialBatch = false});
  Future<void> deleteUser(int id);
  Future<void> clearAllUsers();
  Future<List<User>> getUnsyncedUsers();
  Future<void> markUserAsSynced(int id);
  Future<int> getUsersCount();
  Future<List<User>> getInitialBatchUsers(); // Get only first 20 stored users
  Future<void> markAsInitialBatch(List<int> userIds);
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final Box<UserEntity> _userBox;

  UserLocalDataSourceImpl({required Box<UserEntity> userBox})
      : _userBox = userBox;

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final entities = _userBox.getAll();
      final activeEntities =
          entities.where((entity) => !entity.isDeleted).toList();

      // Sort by updated date
      activeEntities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      return activeEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting all users from local storage: $e');
      return [];
    }
  }

  @override
  Future<User?> getUserById(int id) async {
    try {
      // Find by apiId since that's what the domain layer uses
      final entity = _findEntityByApiId(id);

      if (entity != null && !entity.isDeleted) {
        return entity.toDomain();
      }
      return null;
    } catch (e) {
      log('Error getting user by id from local storage: $e');
      return null;
    }
  }

  @override
  Future<List<User>> getUsersPaginated({int limit = 20, int skip = 0}) async {
    try {
      final entities = _userBox.getAll();
      final activeEntities =
          entities.where((entity) => !entity.isDeleted).toList();

      // Sort by updated date
      activeEntities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      // Apply pagination
      final paginatedEntities = activeEntities.skip(skip).take(limit).toList();

      return paginatedEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting paginated users from local storage: $e');
      return [];
    }
  }

  @override
  Future<List<User>> getInitialBatchUsers() async {
    try {
      // Get users that are marked as initial batch (first 20)
      final entities = _userBox.getAll();
      final initialBatchEntities = entities
          .where((entity) => entity.isInitialBatch && !entity.isDeleted)
          .toList();

      // Sort by updated date
      initialBatchEntities.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      // Limit to first 20
      final limitedEntities = initialBatchEntities.take(20).toList();

      log('Retrieved ${limitedEntities.length} users from initial batch');
      return limitedEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting initial batch users from local storage: $e');
      return [];
    }
  }

  @override
  Future<void> saveUsers(List<User> users,
      {bool isInitialBatch = false}) async {
    try {
      for (final user in users) {
        await saveUser(user, isInitialBatch: isInitialBatch);
      }

      log('Saved ${users.length} users to local storage (initial batch: $isInitialBatch)');
    } catch (e) {
      log('Error saving users to local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveUser(User user, {bool isInitialBatch = false}) async {
    try {
      // Find existing entity by apiId
      final existing = _findEntityByApiId(user.id);

      if (existing != null) {
        // Update existing entity (preserve ObjectBox id and initial batch status)
        final updated = existing.copyWith(
          firstName: user.firstName,
          lastName: user.lastName,
          username: user.username,
          email: user.email,
          phone: user.phone,
          image: user.image,
          gender: user.gender,
          birthDate: user.birthDate?.toIso8601String().split('T')[0],
          addressStreet: user.address?.address,
          addressCity: user.address?.city,
          addressState: user.address?.state,
          addressStateCode: user.address?.stateCode,
          addressPostalCode: user.address?.postalCode,
          addressCountry: user.address?.country,
          companyName: user.company?.name,
          companyDepartment: user.company?.department,
          companyTitle: user.company?.title,
          updatedAt: DateTime.now(),
          isSynced: true,
          // Keep the existing isInitialBatch unless explicitly setting it
          isInitialBatch: isInitialBatch || existing.isInitialBatch,
        );
        _userBox.put(updated);
      } else {
        // Insert new entity (id = 0 for ObjectBox auto-assignment)
        final entity =
            UserEntity.fromDomain(user, isInitialBatch: isInitialBatch);
        _userBox.put(entity);
      }

      log('Saved user ${user.id} to local storage (initial batch: $isInitialBatch)');
    } catch (e) {
      log('Error saving user to local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAsInitialBatch(List<int> userIds) async {
    try {
      for (final userId in userIds) {
        final entity = _findEntityByApiId(userId);
        if (entity != null) {
          final updated = entity.copyWith(
            isInitialBatch: true,
            updatedAt: DateTime.now(),
          );
          _userBox.put(updated);
        }
      }
      log('Marked ${userIds.length} users as initial batch');
    } catch (e) {
      log('Error marking users as initial batch: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    try {
      // Find by apiId
      final entity = _findEntityByApiId(id);

      if (entity != null) {
        // Soft delete - mark as deleted
        final updated = entity.copyWith(
          isDeleted: true,
          updatedAt: DateTime.now(),
        );
        _userBox.put(updated);
        log('Soft deleted user $id from local storage');
      }
    } catch (e) {
      log('Error deleting user from local storage: $e');
      rethrow;
    }
  }

  @override
  Future<void> clearAllUsers() async {
    try {
      _userBox.removeAll();
      log('Cleared all users from local storage');
    } catch (e) {
      log('Error clearing users from local storage: $e');
      rethrow;
    }
  }

  @override
  Future<List<User>> getUnsyncedUsers() async {
    try {
      final entities = _userBox.getAll();
      final unsyncedEntities = entities
          .where((entity) => !entity.isSynced && !entity.isDeleted)
          .toList();

      return unsyncedEntities.map((entity) => entity.toDomain()).toList();
    } catch (e) {
      log('Error getting unsynced users from local storage: $e');
      return [];
    }
  }

  @override
  Future<void> markUserAsSynced(int id) async {
    try {
      final entity = _findEntityByApiId(id);

      if (entity != null) {
        final updated = entity.copyWith(
          isSynced: true,
          updatedAt: DateTime.now(),
        );
        _userBox.put(updated);
        log('Marked user $id as synced');
      }
    } catch (e) {
      log('Error marking user as synced: $e');
      rethrow;
    }
  }

  @override
  Future<int> getUsersCount() async {
    try {
      final entities = _userBox.getAll();
      final activeEntities =
          entities.where((entity) => !entity.isDeleted).toList();
      return activeEntities.length;
    } catch (e) {
      log('Error getting users count from local storage: $e');
      return 0;
    }
  }

  // Helper method to find entity by API ID
  UserEntity? _findEntityByApiId(int apiId) {
    try {
      final entities = _userBox.getAll();
      for (final entity in entities) {
        if (entity.apiId == apiId && !entity.isDeleted) {
          return entity;
        }
      }
      return null;
    } catch (e) {
      log('Error finding entity by API ID: $e');
      return null;
    }
  }
}
