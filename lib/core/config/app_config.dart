class AppConfig {
  static const String baseUrl = 'https://dummyjson.com';
  static const String usersEndpoint = '/users';
  static const String postsEndpoint = '/posts';
  static const String todosEndpoint = '/todos';

  static const int itemsPerPage = 20;
  static const Duration requestTimeout = Duration(seconds: 30);

  // Cache Keys
  static const String usersCacheKey = 'cached_users';
  static const String postsCacheKey = 'cached_posts';
  static const String todosCacheKey = 'cached_todos';
}
