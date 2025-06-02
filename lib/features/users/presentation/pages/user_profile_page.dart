import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../blocs/users_bloc.dart';
import '../blocs/posts_bloc.dart';
import '../blocs/todos_bloc.dart';
import '../widgets/post_card.dart';
import '../widgets/todo_card.dart';
import '../../../../shared/widgets/user_avatar.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load user data and posts/todos
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    // Find the user from the loaded users or load all users
    final usersState = context.read<UsersBloc>().state;
    if (usersState.users.isNotEmpty) {
      try {
        _currentUser = usersState.users.firstWhere(
          (user) => user.id == widget.userId,
        );
      } catch (e) {
        // User not found, use first user as fallback or set to null
        _currentUser =
            usersState.users.isNotEmpty ? usersState.users.first : null;
      }
    }

    // Load user-specific data
    context.read<PostsBloc>().add(LoadUserPostsEvent(widget.userId));
    context.read<TodosBloc>().add(LoadUserTodosEvent(widget.userId));

    // If user not found in current state, load all users
    if (_currentUser == null) {
      context.read<UsersBloc>().add(const LoadUsersEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: BlocListener<UsersBloc, UsersState>(
        listener: (context, state) {
          if (state.users.isNotEmpty && _currentUser == null) {
            setState(() {
              try {
                _currentUser = state.users.firstWhere(
                  (user) => user.id == widget.userId,
                );
              } catch (e) {
                // User not found, use first user as fallback
                _currentUser =
                    state.users.isNotEmpty ? state.users.first : null;
              }
            });
          }
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(theme),
            if (_currentUser != null) ...[
              _buildUserInfo(theme),
              _buildTabBar(theme),
              _buildTabContent(),
            ] else
              const SliverFillRemaining(
                child: LoadingIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _currentUser != null
              ? '${_currentUser!.firstName} ${_currentUser!.lastName}'
              : 'User Profile',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
    );
  }

  Widget _buildUserInfo(ThemeData theme) {
    if (_currentUser == null) return const SliverToBoxAdapter();

    final user = _currentUser!;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            UserAvatar(
              imageUrl: user.image,
              initials: _getInitials(user.firstName, user.lastName),
              size: 100,
            ),
            const SizedBox(height: 16),
            Text(
              '${user.firstName} ${user.lastName}',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@${user.username}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.email_outlined,
              user.email,
              theme,
            ),
            if (user.phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.phone_outlined,
                user.phone,
                theme,
              ),
            ],
            if (user.address != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.location_on_outlined,
                '${user.address!.city}, ${user.address!.state}',
                theme,
              ),
            ],
            if (user.company != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.work_outline,
                '${user.company!.title} at ${user.company!.name}',
                theme,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: theme.colorScheme.primary,
          ),
          labelColor: theme.colorScheme.onPrimary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          labelStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.all(4),
          tabs: const [
            Tab(
              icon: Icon(Icons.article_outlined),
              text: 'Posts',
            ),
            Tab(
              icon: Icon(Icons.checklist_outlined),
              text: 'Todos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsList(),
          _buildTodosList(),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) => const LoadingIndicator(
              useShimmer: true,
              child: ShimmerPostCard(),
            ),
          );
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading posts',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<PostsBloc>()
                        .add(LoadUserPostsEvent(widget.userId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.posts.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No posts found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.posts.length,
          itemBuilder: (context, index) {
            final post = state.posts[index];
            return PostCard(post: post);
          },
        );
      },
    );
  }

  Widget _buildTodosList() {
    return BlocBuilder<TodosBloc, TodosState>(
      builder: (context, state) {
        if (state.isLoading) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) => LoadingIndicator(
              useShimmer: true,
              child: Container(
                height: 80,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }

        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading todos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context
                        .read<TodosBloc>()
                        .add(LoadUserTodosEvent(widget.userId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.todos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.checklist_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No todos found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: state.todos.length,
          itemBuilder: (context, index) {
            final todo = state.todos[index];
            return TodoCard(todo: todo);
          },
        );
      },
    );
  }

  String _getInitials(String firstName, String lastName) {
    String initials = '';
    if (firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    return initials.isEmpty ? 'U' : initials;
  }
}
