import 'package:assignments/features/profile/presentation/blocs/user_profile_state.dart';
import 'package:assignments/features/home/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../blocs/user_profile_cubit.dart';
import '../../../../shared/widgets/profile_todo_tile.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/user_avatar.dart';

class FullUserProfilePage extends StatelessWidget {
  final int userId;

  const FullUserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserProfileCubit(
        userRepository: context.read<UserRepository>(),
      )..loadUserProfile(userId),
      child: _FullUserProfileView(),
    );
  }
}

class _FullUserProfileView extends StatefulWidget {
  @override
  State<_FullUserProfileView> createState() => _FullUserProfileViewState();
}

class _FullUserProfileViewState extends State<_FullUserProfileView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _animationController.forward();
  }

  String _getInitials(String firstName, String lastName) {
    return '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.safePop();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: BlocConsumer<UserProfileCubit, UserProfileState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: colorScheme.error,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'Dismiss',
                    textColor: colorScheme.onError,
                    onPressed: () {
                      context.read<UserProfileCubit>().clearError();
                    },
                  ),
                ),
              );
            }

            // Start animations when user data is loaded
            if (state.user != null && !_animationController.isCompleted) {
              _startAnimations();
            }
          },
          builder: (context, state) {
            if (state.isLoading && state.user == null) {
              return _buildLoadingScreen(theme, colorScheme);
            }

            if (state.user == null) {
              return _buildErrorScreen(theme, colorScheme);
            }

            return _buildProfileView(context, state, theme, colorScheme);
          },
        ),
      ),
    );
  }

  Widget _buildProfileView(BuildContext context, UserProfileState state,
      ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Enhanced AppBar with user info
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () => context.safePop(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Avatar in AppBar
                  Hero(
                    tag: 'user_avatar_${state.user!.id}',
                    child: UserAvatar(
                      imageUrl: state.user!.image,
                      initials: _getInitials(
                        state.user!.firstName,
                        state.user!.lastName,
                      ),
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Name and Username
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${state.user!.firstName} ${state.user!.lastName}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '@${state.user!.username}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withOpacity(0.6),
            indicatorColor: colorScheme.primary,
            indicatorWeight: 3,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(
                icon: Icon(Icons.person_outline),
                text: 'About',
              ),
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

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTab(context, state.user!, theme),
              _buildPostsTab(context, state, theme),
              _buildTodosTab(context, state, theme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingScreen(ThemeData theme, ColorScheme colorScheme) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LoadingIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading profile...',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(ThemeData theme, ColorScheme colorScheme) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 64,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Failed to load profile',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Something went wrong while loading the user profile.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.safePop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<UserProfileCubit>().loadUserProfile(
                            context.read<UserProfileCubit>().state.user?.id ??
                                1,
                          );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab(
      BuildContext context, UserProfileState state, ThemeData theme) {
    if (state.isLoadingPosts) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: LoadingIndicator()),
          );
        },
      );
    }

    if (state.posts.isEmpty) {
      return _buildEmptyState(
        icon: Icons.article_outlined,
        title: 'No posts yet',
        subtitle: 'This user hasn\'t shared any posts.',
        theme: theme,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserProfileCubit>().loadUserProfile(state.user!.id);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          final post = state.posts[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == state.posts.length - 1 ? 0 : 16,
            ),
            child: PostCard(
              post: post,
              onTap: () {
                context.goToPostDetail(post);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTodosTab(
      BuildContext context, UserProfileState state, ThemeData theme) {
    if (state.isLoadingTodos) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(child: LoadingIndicator()),
          );
        },
      );
    }

    if (state.todos.isEmpty) {
      return _buildEmptyState(
        icon: Icons.task_outlined,
        title: 'No todos found',
        subtitle: 'This user hasn\'t created any todos.',
        theme: theme,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserProfileCubit>().loadUserProfile(state.user!.id);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.todos.length,
        itemBuilder: (context, index) {
          final todo = state.todos[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == state.todos.length - 1 ? 0 : 8,
            ),
            child: ProfileTodoTile(
              todo: todo,
            ),
          );
        },
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context, dynamic user, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserProfileCubit>().loadUserProfile(user.id);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Contact Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (user.email.isNotEmpty) ...[
                    _buildDetailRow(Icons.email_outlined, 'Email', user.email,
                        theme, colorScheme),
                    const SizedBox(height: 12),
                  ],
                  if (user.phone.isNotEmpty) ...[
                    _buildDetailRow(Icons.phone_outlined, 'Phone', user.phone,
                        theme, colorScheme),
                    const SizedBox(height: 12),
                  ],
                  if (user.address != null) ...[
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Location',
                      '${user.address!.city}, ${user.address!.country}',
                      theme,
                      colorScheme,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Basic Information
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Basic Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.person_outline, 'Full Name',
                      '${user.firstName} ${user.lastName}', theme, colorScheme),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.alternate_email, 'Username',
                      user.username, theme, colorScheme),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      Icons.wc, 'Gender', user.gender, theme, colorScheme),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Work Information
            if (user.company != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.business_outlined, 'Company',
                        user.company!.name, theme, colorScheme),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.badge_outlined, 'Position',
                        user.company!.title, theme, colorScheme),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.apartment_outlined, 'Department',
                        user.company!.department, theme, colorScheme),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Address Details
            if (user.address != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Address Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(Icons.home_outlined, 'Address',
                        user.address!.address, theme, colorScheme),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.location_city, 'City',
                        user.address!.city, theme, colorScheme),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.map_outlined,
                        'State',
                        '${user.address!.state} (${user.address!.stateCode})',
                        theme,
                        colorScheme),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.local_post_office, 'Postal Code',
                        user.address!.postalCode, theme, colorScheme),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.flag_outlined, 'Country',
                        user.address!.country, theme, colorScheme),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value,
      ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: colorScheme.primary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
