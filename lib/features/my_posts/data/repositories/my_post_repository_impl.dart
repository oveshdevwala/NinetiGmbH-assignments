import '../../domain/entities/my_post.dart';
import '../../domain/repositories/my_post_repository.dart';
import '../datasources/my_post_local_datasource.dart';
import '../models/my_post_entity.dart';

class MyPostRepositoryImpl implements MyPostRepository {
  final MyPostLocalDataSource localDataSource;

  MyPostRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MyPost>> getAllMyPosts() async {
    final entities = await localDataSource.getAllMyPosts();
    return entities.map((entity) => entity.toDomain()).toList();
  }

  @override
  Future<MyPost?> getMyPostById(int id) async {
    final entity = await localDataSource.getMyPostById(id);
    return entity?.toDomain();
  }

  @override
  Future<MyPost> createMyPost({
    required String title,
    required String body,
    required String authorName,
    required List<String> tags,
  }) async {
    final entity = MyPostEntity.create(
      title: title,
      body: body,
      authorName: authorName,
      tags: tags,
    );

    final createdEntity = await localDataSource.createMyPost(entity);
    return createdEntity.toDomain();
  }

  @override
  Future<MyPost> updateMyPost(MyPost post) async {
    final entity = MyPostEntity.fromDomain(post);
    final updatedEntity = await localDataSource.updateMyPost(entity);
    return updatedEntity.toDomain();
  }

  @override
  Future<void> deleteMyPost(int id) async {
    await localDataSource.deleteMyPost(id);
  }

  @override
  Future<List<MyPost>> searchMyPosts(String query) async {
    final entities = await localDataSource.searchMyPosts(query);
    return entities.map((entity) => entity.toDomain()).toList();
  }
}
