# Flutter User Management App with BLoC & Offline-First Architecture

A comprehensive Flutter application showcasing modern development practices with BLoC pattern, API integration, offline-first architecture, and clean architecture principles.

## 📱 Project Overview
### **ScreenShot**
**Attached IN the Assets Folder**

This application demonstrates advanced Flutter development by building a full-featured user management system that:

- **Offline-First Architecture**: Works seamlessly offline with ObjectBox local database
- **API Integration**: Fetches data from DummyJSON API with intelligent caching
- **User Management**: Browse users with search, pagination, and detailed profiles
- **Posts & Todos**: View and manage user posts and todos with real-time sync
- **My Posts**: Create, edit, and manage personal posts locally
- **Connectivity Awareness**: Automatic sync when connection is restored
- **Modern UI**: Material 3 design with light/dark theme support
- **Clean Architecture**: Proper separation of concerns with SOLID principles

## 🏗️ Architecture

The project follows **Clean Architecture** with an **Offline-First** approach:

```
lib/
├── core/                           # Core application components
│   ├── config/                     # App configuration (API URLs, timeouts)
│   ├── errors/                     # Global error handling classes
│   ├── router/                     # Navigation with GoRouter (Shell Navigation)
│   ├── theme/                      # Material 3 theme configuration
│   └── utils/                      # Utilities and helper functions
├── features/                       # Feature-based modular architecture
│   ├── home/                       # Home tab with posts and todos
│   │   ├── data/
│   │   │   ├── datasources/        # Remote (API) & Local (ObjectBox) sources
│   │   │   ├── models/             # JSON serializable data models
│   │   │   └── repositories/       # Repository implementations with offline support
│   │   ├── domain/
│   │   │   ├── entities/           # Core business objects
│   │   │   └── repositories/       # Abstract repository contracts
│   │   └── presentation/
│   │       ├── blocs/              # PostsBloc, TodosBloc, ScrollCubit, PostDetailsCubit
│   │       ├── pages/              # HomePage, PostDetailPage
│   │       └── widgets/            # Feature-specific UI components
│   ├── users/                      # User management with offline caching
│   │   ├── data/
│   │   │   ├── datasources/        # UserRemoteDataSource, UserLocalDataSource
│   │   │   ├── models/             # User model with JSON serialization
│   │   │   └── repositories/       # UserRepositoryOfflineImpl
│   │   ├── domain/
│   │   │   ├── entities/           # User entity
│   │   │   └── repositories/       # UserRepository contract
│   │   └── presentation/
│   │       ├── blocs/              # UsersCubit with search and pagination
│   │       ├── pages/              # UsersListPage
│   │       └── widgets/            # User-specific UI components
│   ├── my_posts/                   # Personal posts management
│   │   ├── data/
│   │   │   ├── datasources/        # MyPostLocalDataSource (ObjectBox)
│   │   │   ├── models/             # MyPost model
│   │   │   └── repositories/       # MyPostRepository implementation
│   │   ├── domain/
│   │   │   ├── entities/           # MyPost entity
│   │   │   └── repositories/       # Repository contracts
│   │   └── presentation/
│   │       ├── blocs/              # MyPostsCubit
│   │       ├── pages/              # MyPostsPage, CreateEditPostPage
│   │       └── widgets/            # Post management widgets
│   └── profile/                    # User profile feature
│       └── presentation/
│           ├── blocs/              # UserProfileCubit
│           ├── pages/              # ProfilePage, FullUserProfilePage
│           └── widgets/            # Profile-specific components
├── shared/                         # Shared cross-feature components
│   ├── services/                   # Core services
│   │   ├── objectbox_service.dart  # ObjectBox database setup
│   │   ├── connectivity_service.dart # Network connectivity monitoring
│   │   ├── sync_service.dart       # Background sync service
│   │   └── user_stats_service.dart # User statistics calculations
│   └── widgets/                    # Reusable UI components
│       ├── app_scaffold.dart       # Bottom navigation shell
│       ├── enhanced_user_list_tile.dart
│       ├── user_profile_tile.dart
│       ├── todo_card.dart
│       ├── app_search_bar.dart
│       ├── sync_status_indicator.dart
│       ├── loading_indicator.dart
│       ├── app_error_widget.dart
│       ├── user_avatar.dart
│       ├── app_button.dart
│       └── page_transitions.dart   # Custom page transitions
├── objectbox.g.dart                # Generated ObjectBox code
├── objectbox-model.json           # ObjectBox schema
├── bootstrap.dart                  # Dependency injection and app setup
└── main.dart                      # Application entry point
```

### Architecture Layers:

1. **Presentation Layer**: UI components, BLoCs/Cubits, and user interaction handling
2. **Domain Layer**: Business entities, use cases, and repository contracts
3. **Data Layer**: API integration, local storage, and repository implementations
4. **Core Layer**: Configuration, routing, theming, and utilities
5. **Shared Layer**: Cross-feature services and reusable components

## 🚀 Features

### ✅ Implemented Core Features

#### **Home Tab**
- 📊 **Dashboard View**: Posts and todos overview with statistics
- 📝 **Posts Management**: View, search, and interact with posts
- ✅ **Todos Management**: Browse and manage todo items
- 🔄 **Real-time Sync**: Automatic background synchronization
- 📱 **Infinite Scrolling**: Lazy loading with scroll position restoration

#### **Users Tab**
- 👥 **User Directory**: Browse all users with avatars and basic info
- 🔍 **Smart Search**: Real-time search by name with debouncing
- 📄 **Pagination**: Efficient pagination with infinite scroll
- 📱 **User Profiles**: Detailed user information with posts and todos
- 💾 **Offline Cache**: Browse users even without internet

#### **My Posts Tab**
- ✏️ **Create Posts**: Add new posts with title and content
- 📝 **Edit Posts**: Modify existing posts with full editor
- 🗑️ **Delete Posts**: Remove unwanted posts
- 💾 **Local Storage**: All posts stored locally with ObjectBox
- 📊 **Post Statistics**: Track your posting activity

#### **Profile Tab**
- 👤 **Personal Profile**: View and manage user information
- 📈 **Activity Stats**: Posts and todos statistics
- 🎨 **Theme Toggle**: Switch between light and dark themes
- ⚙️ **Settings**: App configuration and preferences

### 🔄 Offline-First Features
- **Complete Offline Support**: All features work without internet
- **Smart Sync**: Automatic data synchronization when online
- **Conflict Resolution**: Intelligent handling of data conflicts
- **Background Sync**: Sync data in background when app is not active
- **Connection Awareness**: Visual indicators for connection status

### 🎨 UI/UX Features
- **Material 3 Design**: Modern Material Design 3 components
- **Dark/Light Theme**: System-aware theme switching
- **Responsive Design**: Adaptive layouts for different screen sizes
- **Smooth Animations**: Custom page transitions and loading states
- **Accessibility**: Screen reader support and semantic labels
- **Loading States**: Skeleton loading and shimmer effects
- **Error Handling**: Graceful error states with retry options

## 🛠️ Tech Stack

### **State Management**
- `flutter_bloc: ^8.1.6` - BLoC pattern for state management
- `equatable: ^2.0.7` - Value equality for state objects

### **Network & API**
- `dio: ^5.4.3+1` - HTTP client with interceptors and logging
- `http: ^1.2.2` - Alternative HTTP client
- `connectivity_plus: ^6.0.5` - Network connectivity monitoring

### **Local Storage & Offline**
- `objectbox: ^4.0.1` - High-performance local database
- `objectbox_flutter_libs: ^4.0.1` - ObjectBox Flutter integration
- `hive: ^2.2.3` - Additional local storage
- `shared_preferences: ^2.2.3` - Simple key-value storage

### **Navigation & Routing**
- `go_router: ^14.2.7` - Declarative routing with shell navigation

### **UI & Images**
- `cached_network_image: ^3.3.1` - Efficient image loading and caching
- `shimmer: ^3.0.0` - Loading shimmer effects
- `cupertino_icons: ^1.0.8` - iOS-style icons

### **JSON & Serialization**
- `json_annotation: ^4.9.0` - JSON serialization annotations
- `json_serializable: ^6.9.0` - Code generation for JSON

### **Utilities**
- `intl: ^0.19.0` - Internationalization and date formatting
- `dartz: ^0.10.1` - Functional programming utilities

### **Development & Testing**
- `build_runner: ^2.4.13` - Code generation runner
- `flutter_lints: ^4.0.0` - Dart linting rules
- `bloc_test: ^9.1.7` - Testing utilities for BLoCs
- `mocktail: ^1.0.4` - Mocking framework for testing

## 📋 Setup Instructions

### Prerequisites
- Flutter SDK (^3.5.4)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)
- Git

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd assignments
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (ObjectBox & JSON serialization)**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

### Development Commands

- **Generate code**: `flutter pub run build_runner build`
- **Watch for changes**: `flutter pub run build_runner watch`
- **Clean and rebuild**: 
  ```bash
  flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
  ```
- **Run tests**: `flutter test`
- **Analyze code**: `flutter analyze`

## 🎯 API Integration

The app integrates with [DummyJSON API](https://dummyjson.com/) for data:

### **Endpoints Used**
- `GET /users` - Fetch paginated users list
- `GET /users/search?q={query}` - Search users by name
- `GET /users/{id}` - Get specific user details
- `GET /posts/user/{userId}` - Get user's posts
- `GET /todos/user/{userId}` - Get user's todos
- `GET /posts` - Fetch all posts with pagination
- `POST /posts/add` - Create new post (API simulation)

### **Offline Strategy**
- **Cache-First**: Always try local data first
- **Network Fallback**: Fetch from API if local data is stale
- **Background Sync**: Sync data when network is available
- **Conflict Resolution**: Handle data conflicts intelligently

## 🗄️ Database Schema (ObjectBox)

### **User Entity**
```dart
@Entity()
class UserEntity {
  @Id()
  int id;
  String firstName;
  String lastName;
  String email;
  String? image;
  DateTime? cachedAt;
  // ... additional fields
}
```

### **Post Entity**
```dart
@Entity()
class PostEntity {
  @Id()
  int id;
  String title;
  String body;
  int userId;
  DateTime? cachedAt;
  // ... additional fields
}
```

### **MyPost Entity**
```dart
@Entity()
class MyPostEntity {
  @Id()
  int id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### **Todo Entity**
```dart
@Entity()
class TodoEntity {
  @Id()
  int id;
  String todo;
  bool completed;
  int userId;
  DateTime? cachedAt;
}
```

## 🔄 Navigation Structure

The app uses **Shell Navigation** with GoRouter:

### **Main Tabs**
- **Home** (`/home`) - Posts and todos dashboard
- **Users** (`/users`) - User directory with search
- **My Posts** (`/my-posts`) - Personal posts management
- **Profile** (`/profile`) - User profile and settings

### **Detail Routes**
- **User Profile** (`/user-profile/:userId`) - Full user details
- **Post Detail** (`/post-detail/:postId`) - Individual post view
- **Create Post** (`/my-posts/create`) - New post creation
- **Edit Post** (`/my-posts/edit/:postId`) - Post editing

## 🧪 Testing Strategy

### **Unit Tests**
- BLoC/Cubit state management logic
- Repository implementations
- Data source functionality
- Utility functions and extensions

### **Widget Tests**
- Individual UI components
- Page widgets and layouts
- User interaction flows

### **Integration Tests**
- End-to-end user scenarios
- Offline/online state transitions
- Data synchronization flows

### **Testing Commands**
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/users/presentation/blocs/users_cubit_test.dart

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## 🎨 Design System

### **Theme Configuration**
- **Material 3**: Modern Material Design system
- **Color Schemes**: Dynamic light/dark color palettes
- **Typography**: Consistent text styles across the app
- **Component Themes**: Customized button, card, and input styles

### **Custom Components**
- **AppScaffold**: Bottom navigation shell
- **UserAvatar**: Cached network image with fallback
- **AppButton**: Themed button with loading states
- **AppSearchBar**: Consistent search interface
- **LoadingIndicator**: Customizable loading animations
- **AppErrorWidget**: Standardized error displays

## 📊 Performance Optimizations

### **Image Loading**
- `CachedNetworkImage` for efficient image caching
- Placeholder and error widgets
- Memory and disk cache management

### **List Performance**
- `ListView.builder` for dynamic lists
- Infinite scroll with pagination
- Scroll position restoration

### **State Management**
- Selective BLoC rebuilds with `BlocSelector`
- Efficient state updates with `copyWith`
- Debounced search to reduce API calls

### **Database Optimization**
- ObjectBox indexes for fast queries
- Lazy loading of relationships
- Efficient data serialization

## 🔒 Security & Best Practices

### **Code Quality**
- Consistent naming conventions
- Comprehensive error handling
- Type-safe null safety implementation
- SOLID principles adherence

### **Data Handling**
- Input validation and sanitization
- Secure local storage
- Network request timeouts
- Error boundary implementations

## 🚀 Future Enhancements

### **Planned Features**
- 🔔 **Push Notifications**: Real-time updates
- 📱 **Deep Linking**: Direct navigation to content
- 🌐 **Internationalization**: Multi-language support
- 📊 **Analytics**: User behavior tracking
- 🔐 **Authentication**: User login system
- 💾 **Cloud Sync**: Cross-device synchronization

### **Technical Improvements**
- **Testing**: Increase test coverage to 90%+
- **Performance**: Implement advanced caching strategies
- **Accessibility**: Enhanced screen reader support
- **CI/CD**: Automated testing and deployment pipelines

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes following the project conventions
4. Write/update tests for new functionality
5. Commit changes: `git commit -m 'Add amazing feature'`
6. Push to branch: `git push origin feature/amazing-feature`
7. Open a Pull Request with detailed description

### **Code Style Guidelines**
- Follow Dart style guide (80 character line limit)
- Use trailing commas for better diffs
- Write comprehensive documentation
- Maintain test coverage above 80%

## 📄 License

This project is created for assessment purposes and demonstrates modern Flutter development practices.

## 📞 Contact

For questions, suggestions, or technical discussions about this project, please reach out through the repository's issue tracker.

---

**Built with ❤️ using Flutter, BLoC, and Clean Architecture**

*Showcasing offline-first architecture, modern UI/UX, and production-ready code quality*
