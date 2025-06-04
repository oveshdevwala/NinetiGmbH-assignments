import 'package:equatable/equatable.dart';

class MyPost extends Equatable {
  final int id;
  final String title;
  final String body;
  final String authorName;
  final List<String> tags;
  final MyPostReactions reactions;
  final int views;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MyPost({
    required this.id,
    required this.title,
    required this.body,
    required this.authorName,
    required this.tags,
    required this.reactions,
    required this.views,
    required this.createdAt,
    required this.updatedAt,
  });

  MyPost copyWith({
    int? id,
    String? title,
    String? body,
    String? authorName,
    List<String>? tags,
    MyPostReactions? reactions,
    int? views,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MyPost(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      authorName: authorName ?? this.authorName,
      tags: tags ?? this.tags,
      reactions: reactions ?? this.reactions,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        authorName,
        tags,
        reactions,
        views,
        createdAt,
        updatedAt,
      ];
}

class MyPostReactions extends Equatable {
  final int likes;
  final int dislikes;

  const MyPostReactions({
    required this.likes,
    required this.dislikes,
  });

  MyPostReactions copyWith({
    int? likes,
    int? dislikes,
  }) {
    return MyPostReactions(
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
    );
  }

  @override
  List<Object> get props => [likes, dislikes];
}
