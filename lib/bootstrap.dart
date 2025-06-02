import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

// Data Sources
import 'features/users/data/datasources/user_remote_datasource.dart';
import 'features/users/data/datasources/post_remote_datasource.dart';
import 'features/users/data/datasources/todo_remote_datasource.dart';

// Repository Implementations
import 'features/users/data/repositories/user_repository_impl.dart';
import 'features/users/data/repositories/post_repository_impl.dart';
import 'features/users/data/repositories/todo_repository_impl.dart';

// Domain Repositories
import 'features/users/domain/repositories/user_repository.dart';
import 'features/users/domain/repositories/post_repository.dart';
import 'features/users/domain/repositories/todo_repository.dart';

// BLoCs
import 'features/users/presentation/blocs/users_bloc.dart';
import 'features/users/presentation/blocs/posts_bloc.dart';
import 'features/users/presentation/blocs/todos_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UsersBloc>(
          create: (context) => UsersBloc(
            userRepository: context.read<UserRepository>(),
          ),
        ),
        BlocProvider<PostsBloc>(
          create: (context) => PostsBloc(
            postRepository: context.read<PostRepository>(),
          ),
        ),
        BlocProvider<TodosBloc>(
          create: (context) => TodosBloc(
            todoRepository: context.read<TodoRepository>(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'User Management App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize Dio for HTTP requests
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: AppConfig.requestTimeout,
    receiveTimeout: AppConfig.requestTimeout,
    sendTimeout: AppConfig.requestTimeout,
  ));

  // Add logging interceptor in debug mode
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => debugPrint(object.toString()),
    ));
  }

  // Setup data sources
  final userRemoteDataSource = UserRemoteDataSourceImpl(dio: dio);
  final postRemoteDataSource = PostRemoteDataSourceImpl(dio: dio);
  final todoRemoteDataSource = TodoRemoteDataSourceImpl(dio: dio);

  // Setup repositories
  final userRepository =
      UserRepositoryImpl(remoteDataSource: userRemoteDataSource);
  final postRepository =
      PostRepositoryImpl(remoteDataSource: postRemoteDataSource);
  final todoRepository =
      TodoRepositoryImpl(remoteDataSource: todoRemoteDataSource);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>(
          create: (context) => userRepository,
        ),
        RepositoryProvider<PostRepository>(
          create: (context) => postRepository,
        ),
        RepositoryProvider<TodoRepository>(
          create: (context) => todoRepository,
        ),
      ],
      child: const App(),
    ),
  );
}
