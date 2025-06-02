import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final PostReactions reactions;
  final int views;

  const Post({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.reactions,
    required this.views,
  });

  @override
  List<Object> get props => [id, title, body, userId, tags, reactions, views];
}

class PostReactions extends Equatable {
  final int likes;
  final int dislikes;

  const PostReactions({
    required this.likes,
    required this.dislikes,
  });

  @override
  List<Object> get props => [likes, dislikes];
}
