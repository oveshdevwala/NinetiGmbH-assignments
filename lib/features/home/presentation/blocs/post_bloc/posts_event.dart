part of 'posts_bloc.dart';


abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialPostsEvent extends PostsEvent {
  const LoadInitialPostsEvent();
}

class LoadAllPostsEvent extends PostsEvent {
  const LoadAllPostsEvent();
}

class LoadMorePostsEvent extends PostsEvent {
  const LoadMorePostsEvent();
}

class RefreshPostsEvent extends PostsEvent {
  const RefreshPostsEvent();
}

class LoadUserPostsEvent extends PostsEvent {
  final int userId;

  const LoadUserPostsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
