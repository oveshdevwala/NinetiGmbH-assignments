// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
      userId: (json['userId'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      reactionsModel: PostModel._reactionsFromJson(
          json['reactions'] as Map<String, dynamic>),
      views: (json['views'] as num).toInt(),
    );

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'userId': instance.userId,
      'tags': instance.tags,
      'views': instance.views,
      'reactions': PostModel._reactionsToJson(instance.reactionsModel),
    };

PostReactionsModel _$PostReactionsModelFromJson(Map<String, dynamic> json) =>
    PostReactionsModel(
      likes: (json['likes'] as num).toInt(),
      dislikes: (json['dislikes'] as num).toInt(),
    );

Map<String, dynamic> _$PostReactionsModelToJson(PostReactionsModel instance) =>
    <String, dynamic>{
      'likes': instance.likes,
      'dislikes': instance.dislikes,
    };
