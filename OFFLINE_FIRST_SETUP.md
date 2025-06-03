# Offline-First Architecture with ObjectBox

This document explains the complete offline-first architecture implementation using ObjectBox, Bloc, and Connectivity.

## 🏗️ Architecture Overview

### Core Components

1. **ObjectBox** - High-performance local database for offline storage
2. **Connectivity Service** - Monitors network status
3. **Sync Service** - Handles background synchronization
4. **Repository Pattern** - Offline-first data access layer
5. **Bloc/Cubit** - State management with offline support

## 📁 File Structure

```
lib/
├── core/
│   ├── config/
│   ├── errors/
│   └── utils/
├── features/
│   ├── posts/
│   │   └── presentation/
│   │       ├── blocs/
│   │       │   ├── posts_cubit.dart
│   │       │   └── posts_state.dart
│   │       └── pages/
│   │           └── post_detail_page.dart
│   └── users/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── post_local_datasource.dart
│       │   │   ├── todo_local_datasource.dart
│       │   │   ├── post_remote_datasource.dart
│       │   │   └── todo_remote_datasource.dart
│       │   ├── models/
│       │   │   ├── post_entity.dart
│       │   │   └── todo_entity.dart
│       │   └── repositories/
│       │       └── post_repository_offline_impl.dart
│       └── domain/
│           ├── entities/
│           │   ├── post.dart
│           │   └── todo.dart
│           └── repositories/
│               └── post_repository.dart
└── shared/
    ├── services/
    │   ├── objectbox_service.dart
    │   ├── connectivity_service.dart
    │   └── sync_service.dart
    └── widgets/
        ├── app_loading_indicator.dart
        ├── app_error_widget.dart
        └── sync_status_indicator.dart
```

## 🔧 Setup Instructions

### 1. Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.7
  
  # ObjectBox for offline storage
  objectbox: ^4.0.1
  objectbox_flutter_libs: ^4.0.1
  
  # Connectivity
  connectivity_plus: ^6.0.5
  
  # Other dependencies...

dev_dependencies:
  # ObjectBox generator
  objectbox_generator: ^4.0.1
  build_runner: ^2.4.13
```

### 2. Generate ObjectBox Code

Run the build runner to generate ObjectBox files:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. Initialize Services

Update your `bootstrap.dart`:

```dart
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ObjectBox for offline storage
  final objectBoxService = await ObjectBoxService.create();

  // Initialize connectivity service
  final connectivityService = ConnectivityService();
  await connectivityService.initialize();

  // Setup data sources and repositories
  // ... (see complete bootstrap.dart)

  // Initialize sync service
  await syncService.initialize();

  runApp(MyApp());
}
```

## 🚀 Key Features

### Offline-First Data Flow

1. **Read**: Always try local storage first
2. **Write**: Save locally immediately, sync when connected
3. **Sync**: Background synchronization when network is available

### State Management

```dart
class PostsState extends Equatable {
  final List<Post> posts;
  final bool isLoading;
  final bool isOffline;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  // ... other fields

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    // ... other parameters
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      // ... other assignments
    );
  }
}
```

### Repository Implementation

```dart
class PostRepositoryOfflineImpl implements PostRepository {
  @override
  Future<Either<Failure, List<Post>>> getAllPosts() async {
    // 1. Try local storage first
    final localPosts = await localDataSource.getAllPosts();
    
    if (localPosts.isNotEmpty) {
      // 2. Return local data immediately
      _backgroundSync(); // Sync in background
      return Right(localPosts);
    }
    
    // 3. Fetch from remote if no local data
    final isConnected = await connectivityService.isConnected;
    if (isConnected) {
      return await _fetchFromRemoteAndSave();
    }
    
    // 4. Return empty if offline and no local data
    return const Right([]);
  }
}
```

## 🔄 Sync Strategy

### Automatic Sync

- **On Network Connect**: Immediate sync when network becomes available
- **Periodic Sync**: Every 5 minutes when connected
- **Background Sync**: When accessing data that might be stale

### Manual Sync

- **Pull to Refresh**: User-initiated refresh
- **Sync Button**: Force sync from UI
- **Deep Refresh**: Complete data reload

## 📱 UI Components

### Sync Status Indicator

Shows current sync status in the app bar:

```dart
BlocBuilder<PostsCubit, PostsState>(
  builder: (context, state) {
    return SyncStatusIndicator(
      isOffline: state.isOffline,
      isSyncing: state.isSyncing,
      lastSyncTime: state.lastSyncTime,
      onRefresh: () => context.read<PostsCubit>().forceSync(),
    );
  },
)
```

### Offline Indicator

Shows when the app is in offline mode:

```dart
if (state.isOffline)
  Container(
    // Offline indicator UI
    child: Text('You\'re offline. Showing cached content.'),
  )
```

## 🎯 Best Practices

### 1. Error Handling

```dart
result.fold(
  (failure) {
    // Handle different types of failures
    if (failure is NetworkFailure) {
      // Show network error
    } else if (failure is CacheFailure) {
      // Show cache error
    }
  },
  (data) {
    // Handle success
  },
);
```

### 2. Loading States

```dart
// Show loading only if no cached data
if (_currentPost == null && state.isLoading) {
  return const AppLoadingIndicator();
}

// Show cached data immediately with background loading
if (_currentPost != null) {
  return _buildPostContent(_currentPost!, state);
}
```

### 3. Data Freshness

```dart
// Always show cached data for immediate response
// Update UI when fresh data arrives
BlocListener<PostsCubit, PostsState>(
  listener: (context, state) {
    if (state.posts.isNotEmpty) {
      final updatedPost = state.posts
          .where((post) => post.id == widget.postId)
          .firstOrNull;
      
      if (updatedPost != null && updatedPost != _currentPost) {
        setState(() {
          _currentPost = updatedPost;
        });
      }
    }
  },
  // ...
)
```

## 🔍 Usage Example

### Post Detail Page with Preloaded Data

```dart
// Navigation with preloaded data
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PostDetailPage(
      preloadedPost: post, // Pass cached data
      postId: post.id,
    ),
  ),
);
```

### Benefits

1. **Instant Loading**: Shows cached data immediately
2. **Background Updates**: Fetches fresh data in background
3. **Offline Support**: Works without internet connection
4. **Automatic Sync**: Keeps data up-to-date when online

## 🧪 Testing

### Testing Offline Functionality

1. Turn off internet connection
2. App should continue working with cached data
3. UI should show offline indicator
4. Turn on internet connection
5. App should sync and update data

### Testing Sync

1. Make changes while offline
2. Changes should be saved locally
3. When back online, changes should sync to server
4. Sync status should be visible to user

## 📊 Performance Considerations

1. **ObjectBox**: High-performance local database
2. **Lazy Loading**: Load data as needed
3. **Background Sync**: Don't block UI during sync
4. **Efficient Queries**: Use ObjectBox query builder
5. **Data Pagination**: Implement pagination for large datasets

## 🛠️ Troubleshooting

### Common Issues

1. **Build Runner Fails**: Clean and rebuild
2. **ObjectBox Errors**: Check entity annotations
3. **Sync Issues**: Verify connectivity service
4. **State Issues**: Check Bloc event handling

### Debug Commands

```bash
# Clean project
flutter clean && flutter pub get

# Regenerate ObjectBox files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Check dependencies
flutter pub deps
```

This architecture provides a robust, scalable, and user-friendly offline-first experience that prioritizes local data while maintaining synchronization with remote sources. 