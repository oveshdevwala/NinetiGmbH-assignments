import 'package:assignments/features/users/presentation/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/router/app_router.dart';
import '../../domain/repositories/user_repository.dart';
import '../blocs/user_profile_cubit.dart';
import '../../../../shared/widgets/todo_card.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/floating_scroll_buttons.dart';

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
  late AnimationController _headerAnimationController;
  late AnimationController _contentAnimationController;
  late Animation<double> _headerSlideAnimation;
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _contentSlideAnimation;
  late Animation<double> _contentFadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerSlideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    _contentSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _contentAnimationController.forward();
      }
    });
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
            if (state.user != null && !_headerAnimationController.isCompleted) {
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

            return Stack(
              children: [
                DefaultTabController(
                  length: 3,
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        // Enhanced Header
                        SliverToBoxAdapter(
                          child: AnimatedBuilder(
                            animation: _headerAnimationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _headerSlideAnimation.value),
                                child: Opacity(
                                  opacity: _headerFadeAnimation.value,
                                  child: _buildEnhancedHeader(
                                      context, state.user!, theme, colorScheme),
                                ),
                              );
                            },
                          ),
                        ),

                        // Animated Stats Section
                        SliverToBoxAdapter(
                          child: AnimatedBuilder(
                            animation: _contentAnimationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _contentSlideAnimation.value),
                                child: Opacity(
                                  opacity: _contentFadeAnimation.value,
                                  child: _buildStatsSection(
                                      context, state, theme, colorScheme),
                                ),
                              );
                            },
                          ),
                        ),

                        // User Details Card
                        SliverToBoxAdapter(
                          child: AnimatedBuilder(
                            animation: _contentAnimationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    0, _contentSlideAnimation.value * 0.7),
                                child: Opacity(
                                  opacity: _contentFadeAnimation.value,
                                  child: _buildUserDetailsCard(
                                      context, state.user!, theme, colorScheme),
                                ),
                              );
                            },
                          ),
                        ),

                        // Enhanced Tab Bar
                        SliverToBoxAdapter(
                          child: AnimatedBuilder(
                            animation: _contentAnimationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    0, _contentSlideAnimation.value * 0.5),
                                child: Opacity(
                                  opacity: _contentFadeAnimation.value,
                                  child:
                                      _buildEnhancedTabBar(theme, colorScheme),
                                ),
                              );
                            },
                          ),
                        ),
                      ];
                    },
                    body: TabBarView(
                      children: [
                        _buildPostsTab(context, state, theme),
                        _buildTodosTab(context, state, theme),
                        _buildAboutTab(context, state.user!, theme),
                      ],
                    ),
                  ),
                ),

                // Floating Scroll Buttons
                const Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingScrollButtons(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(ThemeData theme, ColorScheme colorScheme) {
    return SafeArea(
      child: Column(
        children: [
          // Loading Header
          Container(
            width: double.infinity,
            height: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.secondary.withOpacity(0.1),
                  colorScheme.tertiary.withOpacity(0.1),
                ],
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LoadingIndicator(),
                SizedBox(height: 16),
                Text('Loading profile...'),
              ],
            ),
          ),

          // Loading Content
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  height: 120,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: LoadingIndicator()),
                );
              },
            ),
          ),
        ],
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

  Widget _buildEnhancedHeader(BuildContext context, dynamic user,
      ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.1),
            colorScheme.tertiary.withOpacity(0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Glassmorphism overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface.withOpacity(0.1),
                  colorScheme.surface.withOpacity(0.3),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Navigation and actions
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.2),
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
                          onPressed: () => context.safePop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.2),
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
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile shared!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.share,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Enhanced profile image with hero animation
                  Hero(
                    tag: 'user_avatar_${user.id}',
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withOpacity(0.3),
                            colorScheme.secondary.withOpacity(0.3),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 56,
                        backgroundColor: colorScheme.surface,
                        backgroundImage: user.image.isNotEmpty
                            ? NetworkImage(user.image)
                            : null,
                        child: user.image.isEmpty
                            ? Text(
                                user.firstName[0].toUpperCase(),
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // User name with enhanced styling
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Username with enhanced styling
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '@${user.username}',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Company info if available
                  if (user.company != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            user.company!.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            user.company!.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, UserProfileState state,
      ThemeData theme, ColorScheme colorScheme) {
    final completedTodos = state.todos.where((todo) => todo.completed).length;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              context,
              'Posts',
              state.posts.length.toString(),
              Icons.article_outlined,
              colorScheme.primary,
              theme,
              colorScheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Todos',
              state.todos.length.toString(),
              Icons.task_outlined,
              colorScheme.secondary,
              theme,
              colorScheme,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              context,
              'Completed',
              completedTodos.toString(),
              Icons.check_circle_outline,
              colorScheme.tertiary,
              theme,
              colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color accentColor,
      ThemeData theme,
      ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withOpacity(0.1),
            accentColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsCard(BuildContext context, dynamic user,
      ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
          width: 1,
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
            _buildDetailRow(
                Icons.email_outlined, 'Email', user.email, theme, colorScheme),
            const SizedBox(height: 12),
          ],
          if (user.phone.isNotEmpty) ...[
            _buildDetailRow(
                Icons.phone_outlined, 'Phone', user.phone, theme, colorScheme),
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
            const SizedBox(height: 16),
          ],
          if (user.company != null) ...[
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
        ],
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

  Widget _buildEnhancedTabBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withOpacity(0.8),
            ],
          ),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: colorScheme.onPrimary,
        unselectedLabelColor: colorScheme.onSurface.withOpacity(0.7),
        labelStyle: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Posts'),
          Tab(text: 'Todos'),
          Tab(text: 'About'),
        ],
      ),
    );
  }

  Widget _buildPostsTab(
      BuildContext context, UserProfileState state, ThemeData theme) {
    if (state.isLoadingPosts) {
      return _buildShimmerList();
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
          return PostCard(
            post: post,
            onTap: () {
              context.goToPostDetail(post);
            },
          );
        },
      ),
    );
  }

  Widget _buildTodosTab(
      BuildContext context, UserProfileState state, ThemeData theme) {
    if (state.isLoadingTodos) {
      return _buildShimmerList();
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
          return TodoCard(
            todo: todo,
          );
        },
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context, dynamic user, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.1),
              ),
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

          // Full Address Information
          if (user.address != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                ),
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
    );
  }

  Widget _buildShimmerList() {
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
