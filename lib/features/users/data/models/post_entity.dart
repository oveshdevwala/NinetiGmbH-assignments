import 'package:objectbox/objectbox.dart';
import '../../domain/entities/post.dart';

@Entity()
class PostEntity {
  @Id()
  int id;

  int apiId; // Store the original API ID separately
  String title;
  String body;
  int userId;
  String tags; // Store as comma-separated string for ObjectBox
  int likes;
  int dislikes;
  int views;

  // Sync related fields
  DateTime createdAt;
  DateTime updatedAt;
  bool isSynced;
  bool isDeleted;

  PostEntity({
    this.id = 0,
    required this.apiId,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.likes,
    required this.dislikes,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

  // Convert to domain entity (use apiId as the domain id)
  Post toDomain() {
    return Post(
      id: apiId,
      title: title,
      body: body,
      userId: userId,
      tags: tags.split(',').where((tag) => tag.isNotEmpty).toList(),
      reactions: PostReactions(
        likes: likes,
        dislikes: dislikes,
      ),
      views: views,
    );
  }

  // Convert from domain entity
  static PostEntity fromDomain(Post post) {
    final now = DateTime.now();
    return PostEntity(
      id: 0, // Always use 0 for new ObjectBox entities
      apiId: post.id,
      title: post.title,
      body: post.body,
      userId: post.userId,
      tags: post.tags.join(','),
      likes: post.reactions.likes,
      dislikes: post.reactions.dislikes,
      views: post.views,
      createdAt: now,
      updatedAt: now,
      isSynced: true,
    );
  }

  // Convert from JSON (API response)
  static PostEntity fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return PostEntity(
      id: 0, // Always use 0 for new ObjectBox entities
      apiId: json['id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      userId: json['userId'] ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.join(',') ?? '',
      likes: json['reactions']?['likes'] ?? 0,
      dislikes: json['reactions']?['dislikes'] ?? 0,
      views: json['views'] ?? 0,
      createdAt: now,
      updatedAt: now,
      isSynced: true,
    );
  }

  // Convert to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': apiId, // Use apiId for API requests
      'title': title,
      'body': body,
      'userId': userId,
      'tags': tags.split(',').where((tag) => tag.isNotEmpty).toList(),
      'reactions': {
        'likes': likes,
        'dislikes': dislikes,
      },
      'views': views,
    };
  }

  PostEntity copyWith({
    int? id,
    int? apiId,
    String? title,
    String? body,
    int? userId,
    String? tags,
    int? likes,
    int? dislikes,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return PostEntity(
      id: id ?? this.id,
      apiId: apiId ?? this.apiId,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
