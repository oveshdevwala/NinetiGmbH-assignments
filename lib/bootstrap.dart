import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

// Services
import 'shared/services/objectbox_service.dart';
import 'shared/services/connectivity_service.dart';
import 'shared/services/sync_service.dart';
import 'shared/services/user_stats_service.dart';

// Data Sources
import 'features/users/data/datasources/user_remote_datasource.dart';
import 'features/users/data/datasources/user_local_datasource.dart';
import 'features/home/data/datasources/post_remote_datasource.dart';
import 'features/home/data/datasources/todo_remote_datasource.dart';
import 'features/home/data/datasources/post_local_datasource.dart';
import 'features/home/data/datasources/todo_local_datasource.dart';
import 'features/my_posts/data/datasources/my_post_local_datasource.dart';

// Repository Implementations
import 'features/users/data/repositories/user_repository_offline_impl.dart';
import 'features/home/data/repositories/post_repository_offline_impl.dart';
import 'features/home/data/repositories/todo_repository_impl.dart';
import 'features/my_posts/data/repositories/my_post_repository_impl.dart';

// Domain Repositories
import 'features/users/domain/repositories/user_repository.dart';
import 'features/home/domain/repositories/post_repository.dart';
import 'features/home/domain/repositories/todo_repository.dart';
import 'features/my_posts/domain/repositories/my_post_repository.dart';

// BLoCs and Cubits
import 'features/users/presentation/blocs/users_cubit.dart';
import 'features/profile/presentation/blocs/user_profile_cubit.dart';
import 'features/home/presentation/blocs/todos_bloc/todos_bloc.dart';
import 'features/home/presentation/blocs/post_bloc/posts_bloc.dart';
import 'features/home/presentation/blocs/scroll_cubit/scroll_cubit.dart';
import 'features/my_posts/presentation/blocs/my_posts_cubit.dart';

class App extends StatelessWidget {
  final ObjectBoxService objectBoxService;
  final ConnectivityService connectivityService;
  final SyncService syncService;

  const App({
    super.key,
    required this.objectBoxService,
    required this.connectivityService,
    required this.syncService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UsersCubit>(
          create: (context) => UsersCubit(
            userRepository: context.read<UserRepository>(),
            connectivityService: connectivityService,
            syncService: syncService,
          ),
        ),
        BlocProvider<UserProfileCubit>(
          create: (context) => UserProfileCubit(
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
        BlocProvider<ScrollCubit>(
          create: (context) => ScrollCubit(),
        ),
        BlocProvider<MyPostsCubit>(
          create: (context) => MyPostsCubit(
            repository: context.read<MyPostRepository>(),
          ),
        ),
      ],
      child: PageStorage(
        bucket: PageStorageBucket(),
        child: MaterialApp.router(
          title: 'Users App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for shared preferences (fallback)
  await Hive.initFlutter();

  // Initialize ObjectBox for offline storage
  final objectBoxService = await ObjectBoxService.create();

  // Initialize connectivity service
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

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

  // Setup remote data sources
  final userRemoteDataSource = UserRemoteDataSourceImpl(dio: dio);
  final postRemoteDataSource = PostRemoteDataSourceImpl(dio: dio);
  final todoRemoteDataSource = TodoRemoteDataSourceImpl(dio: dio);

  // Setup local data sources
  final userLocalDataSource = UserLocalDataSourceImpl(
    userBox: objectBoxService.userBox,
  );
  final postLocalDataSource = PostLocalDataSourceImpl(
    postBox: objectBoxService.postBox,
  );
  final todoLocalDataSource = TodoLocalDataSourceImpl(
    todoBox: objectBoxService.todoBox,
  );
  final myPostLocalDataSource = MyPostLocalDataSourceImpl(
    myPostBox: objectBoxService.myPostBox,
  );

  // Setup sync service
  final syncService = SyncService(
    postLocalDataSource: postLocalDataSource,
    postRemoteDataSource: postRemoteDataSource,
    todoLocalDataSource: todoLocalDataSource,
    todoRemoteDataSource: todoRemoteDataSource,
    connectivityService: connectivityService,
  );

  // Initialize sync service
  await syncService.initialize();

  // Setup repositories
  final userRepository = UserRepositoryOfflineImpl(
    remoteDataSource: userRemoteDataSource,
    localDataSource: userLocalDataSource,
    connectivityService: connectivityService,
  );

  final postRepository = PostRepositoryOfflineImpl(
    localDataSource: postLocalDataSource,
    remoteDataSource: postRemoteDataSource,
    connectivityService: connectivityService,
  );

  final todoRepository = TodoRepositoryImpl(
    remoteDataSource: todoRemoteDataSource,
  );

  final myPostRepository = MyPostRepositoryImpl(
    localDataSource: myPostLocalDataSource,
  );

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
        RepositoryProvider<MyPostRepository>(
          create: (context) => myPostRepository,
        ),
        // Provide services for dependency injection
        RepositoryProvider<ObjectBoxService>(
          create: (context) => objectBoxService,
        ),
        RepositoryProvider<ConnectivityService>(
          create: (context) => connectivityService,
        ),
        RepositoryProvider<SyncService>(
          create: (context) => syncService,
        ),
        RepositoryProvider<UserStatsService>(
          create: (context) => UserStatsService(
            userRepository: userRepository,
          ),
        ),
      ],
      child: App(
        objectBoxService: objectBoxService,
        connectivityService: connectivityService,
        syncService: syncService,
      ),
    ),
  );
}
