import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/post.dart';
import '../../../../core/utils/typedef.dart';

part 'post_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PostModel extends Post {
  @JsonKey(
      name: 'reactions', fromJson: _reactionsFromJson, toJson: _reactionsToJson)
  final PostReactionsModel reactionsModel;

  const PostModel({
    required super.id,
    required super.title,
    required super.body,
    required super.userId,
    required super.tags,
    required this.reactionsModel,
    required super.views,
  }) : super(reactions: reactionsModel);

  factory PostModel.fromJson(DataMap json) => _$PostModelFromJson(json);

  DataMap toJson() => _$PostModelToJson(this);

  static PostReactionsModel _reactionsFromJson(DataMap json) =>
      PostReactionsModel.fromJson(json);

  static DataMap _reactionsToJson(PostReactionsModel reactions) =>
      reactions.toJson();

  PostModel copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
    List<String>? tags,
    PostReactionsModel? reactions,
    int? views,
  }) {
    return PostModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      tags: tags ?? this.tags,
      reactionsModel: reactions ?? reactionsModel,
      views: views ?? this.views,
    );
  }
}

@JsonSerializable()
class PostReactionsModel extends PostReactions {
  const PostReactionsModel({
    required super.likes,
    required super.dislikes,
  });

  factory PostReactionsModel.fromJson(DataMap json) =>
      _$PostReactionsModelFromJson(json);

  DataMap toJson() => _$PostReactionsModelToJson(this);
}
