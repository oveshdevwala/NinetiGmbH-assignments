import 'package:objectbox/objectbox.dart';
import '../../domain/entities/my_post.dart';

@Entity()
class MyPostEntity {
  @Id()
  int id;

  String title;
  String body;
  String authorName;
  List<String> tags;

  // Reactions
  int likes;
  int dislikes;
  int views;

  // Metadata
  DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;

  MyPostEntity({
    this.id = 0,
    required this.title,
    required this.body,
    required this.authorName,
    required this.tags,
    this.likes = 0,
    this.dislikes = 0,
    this.views = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  // Convert to domain entity
  MyPost toDomain() {
    return MyPost(
      id: id,
      title: title,
      body: body,
      authorName: authorName,
      tags: tags,
      reactions: MyPostReactions(
        likes: likes,
        dislikes: dislikes,
      ),
      views: views,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Convert from domain entity
  static MyPostEntity fromDomain(MyPost post) {
    return MyPostEntity(
      id: post.id,
      title: post.title,
      body: post.body,
      authorName: post.authorName,
      tags: post.tags,
      likes: post.reactions.likes,
      dislikes: post.reactions.dislikes,
      views: post.views,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
    );
  }

  // Create new post
  static MyPostEntity create({
    required String title,
    required String body,
    required String authorName,
    required List<String> tags,
  }) {
    final now = DateTime.now();
    return MyPostEntity(
      id: 0, // ObjectBox will assign ID
      title: title,
      body: body,
      authorName: authorName,
      tags: tags,
      likes: 0,
      dislikes: 0,
      views: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  MyPostEntity copyWith({
    int? id,
    String? title,
    String? body,
    String? authorName,
    List<String>? tags,
    int? likes,
    int? dislikes,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return MyPostEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      authorName: authorName ?? this.authorName,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
