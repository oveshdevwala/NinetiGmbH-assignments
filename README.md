# Flutter User Management App

A Flutter application showcasing user management with BLoC pattern, API integration, and clean architecture principles.

## 📱 Project Overview

This application demonstrates modern Flutter development practices by building a user management system that:

- Fetches users from DummyJSON API with pagination and search functionality
- Implements infinite scrolling for seamless user experience
- Displays user details with their posts and todos
- Allows creating new posts locally
- Handles loading, success, and error states appropriately
- Supports light/dark theme switching
- Uses clean architecture with BLoC state management

## 🏗️ Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/                     # Core application components
│   ├── config/              # App configuration and constants
│   ├── errors/              # Error handling classes
│   ├── router/              # Navigation setup with GoRouter
│   ├── theme/               # App theming configuration
│   └── utils/               # Utilities and helper functions
├── features/                # Feature-based modules
│   └── users/              # User management feature
│       ├── data/           # Data layer
│       │   ├── datasources/ # Remote/local data sources
│       │   ├── models/      # Data models with JSON serialization
│       │   └── repositories/ # Repository implementations
│       ├── domain/         # Business logic layer
│       │   ├── entities/    # Core business objects
│       │   └── repositories/ # Repository contracts
│       └── presentation/   # UI layer
│           ├── blocs/       # BLoC state management
│           ├── pages/       # Screen widgets
│           └── widgets/     # Feature-specific UI components
├── shared/                 # Shared components
│   ├── services/           # Cross-feature services
│   └── widgets/            # Reusable UI components
├── bootstrap.dart          # App initialization and DI setup
└── main.dart              # Application entry point
```

### Architecture Layers:

1. **Presentation Layer**: UI components, BLoCs, and user interaction handling
2. **Domain Layer**: Business entities, use cases, and repository contracts
3. **Data Layer**: API integration, data models, and repository implementations

## 🚀 Features

### Core Features
- ✅ **User List**: Display users with avatar, name, and email
- ✅ **Search Functionality**: Real-time search by user name
- ✅ **Pagination**: Infinite scrolling with lazy loading
- ✅ **User Details**: Comprehensive user information display
- ✅ **Posts & Todos**: Fetch and display user's posts and todos
- ✅ **Create Posts**: Add new posts locally
- ✅ **Error Handling**: Graceful error state management
- ✅ **Loading States**: Appropriate loading indicators

### Bonus Features
- ✅ **Theme Switching**: Light/Dark mode support
- 🔄 **Pull to Refresh**: Refresh user list (to be implemented)
- 🔄 **Offline Caching**: Local storage with Hive (to be implemented)

## 🛠️ Tech Stack

### Core Dependencies
- **flutter_bloc**: State management with BLoC pattern
- **dio**: HTTP client for API requests
- **go_router**: Declarative routing
- **equatable**: Value equality for objects

### UI & UX
- **cached_network_image**: Efficient image loading and caching
- **shimmer**: Loading shimmer effects

### Storage & Caching
- **hive**: Local database for offline caching
- **shared_preferences**: Simple key-value storage

### Code Generation
- **json_serializable**: JSON serialization code generation
- **build_runner**: Build system for code generation

### Testing
- **bloc_test**: Testing utilities for BLoCs
- **mocktail**: Mocking framework for testing

## 📋 Setup Instructions

### Prerequisites
- Flutter SDK (^3.5.4)
- Dart SDK
- IDE (VS Code, Android Studio, or IntelliJ)

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

3. **Generate code (for JSON serialization)**
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
- **Clean and rebuild**: `flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs`
- **Run tests**: `flutter test`

## 🎯 API Integration

The app integrates with [DummyJSON API](https://dummyjson.com/) for:

- **Users**: `GET /users` - Fetch users with pagination
- **Search**: `GET /users/search` - Search users by name
- **User Details**: `GET /users/{id}` - Get specific user
- **User Posts**: `GET /posts/user/{userId}` - Get user's posts
- **User Todos**: `GET /todos/user/{userId}` - Get user's todos
- **Create Post**: `POST /posts/add` - Create new post

## 🧪 Testing

The project includes comprehensive testing:

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/users/presentation/blocs/users_bloc_test.dart
```

### Testing Strategy
- **Unit Tests**: BLoCs, repositories, and utilities
- **Widget Tests**: UI components and pages
- **Integration Tests**: End-to-end user flows

## 🎨 Design Patterns

### BLoC Pattern
- **Events**: User actions (LoadUsers, SearchUsers, etc.)
- **States**: UI states (loading, loaded, error)
- **BLoCs**: Business logic and state management

### Repository Pattern
- **Abstract repositories**: Domain contracts
- **Concrete implementations**: Data layer implementations
- **Dependency injection**: Loose coupling between layers

### Clean Architecture
- **Separation of concerns**: Each layer has specific responsibilities
- **Dependency inversion**: High-level modules don't depend on low-level modules
- **Testability**: Easy to test each layer independently

## 🔧 Configuration

### Environment Setup
- **Base URL**: Configured in `lib/core/config/app_config.dart`
- **API timeouts**: Configurable request timeouts
- **Pagination**: Adjustable page sizes

### Theme Configuration
- **Light/Dark themes**: Defined in `lib/core/theme/app_theme.dart`
- **Material 3**: Modern Material Design components
- **Responsive design**: Adaptive layouts for different screen sizes

## 📱 Screenshots

*Screenshots will be added once UI implementation is complete*

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📄 License

This project is created for assessment purposes.

## 📞 Contact

For questions or clarifications, please contact [your-email@example.com]

---

**Built with ❤️ using Flutter and BLoC**
