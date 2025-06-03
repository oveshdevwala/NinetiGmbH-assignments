import '../models/my_post_entity.dart';
import '../../../../objectbox.g.dart';

abstract class MyPostLocalDataSource {
  Future<List<MyPostEntity>> getAllMyPosts();
  Future<MyPostEntity?> getMyPostById(int id);
  Future<MyPostEntity> createMyPost(MyPostEntity post);
  Future<MyPostEntity> updateMyPost(MyPostEntity post);
  Future<void> deleteMyPost(int id);
  Future<List<MyPostEntity>> searchMyPosts(String query);
}

class MyPostLocalDataSourceImpl implements MyPostLocalDataSource {
  final Box<MyPostEntity> myPostBox;

  MyPostLocalDataSourceImpl({required this.myPostBox});

  @override
  Future<List<MyPostEntity>> getAllMyPosts() async {
    return myPostBox
        .query(MyPostEntity_.isDeleted.equals(false))
        .order(MyPostEntity_.createdAt, flags: Order.descending)
        .build()
        .find();
  }

  @override
  Future<MyPostEntity?> getMyPostById(int id) async {
    return myPostBox.get(id);
  }

  @override
  Future<MyPostEntity> createMyPost(MyPostEntity post) async {
    final id = myPostBox.put(post);
    return myPostBox.get(id)!;
  }

  @override
  Future<MyPostEntity> updateMyPost(MyPostEntity post) async {
    final updatedPost = post.copyWith(updatedAt: DateTime.now());
    myPostBox.put(updatedPost);
    return updatedPost;
  }

  @override
  Future<void> deleteMyPost(int id) async {
    final post = myPostBox.get(id);
    if (post != null) {
      final deletedPost = post.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      myPostBox.put(deletedPost);
    }
  }

  @override
  Future<List<MyPostEntity>> searchMyPosts(String query) async {
    final titleCondition =
        MyPostEntity_.title.contains(query, caseSensitive: false);
    final bodyCondition =
        MyPostEntity_.body.contains(query, caseSensitive: false);

    return myPostBox
        .query(MyPostEntity_.isDeleted.equals(false) &
            (titleCondition | bodyCondition))
        .order(MyPostEntity_.createdAt, flags: Order.descending)
        .build()
        .find();
  }
}
