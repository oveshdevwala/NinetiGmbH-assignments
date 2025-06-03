import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../blocs/users_cubit.dart';
import '../../domain/entities/user.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../shared/widgets/enhanced_user_list_tile.dart';
import '../../../../shared/services/user_stats_service.dart';

class UsersListPage extends StatefulWidget {
  const UsersListPage({super.key});

  @override
  State<UsersListPage> createState() => _UsersListPageState();
}

class _UsersListPageState extends State<UsersListPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  // User stats management
  final Map<int, UserStats> _userStats = {};
  final Set<int> _loadingStats = {};
  late UserStatsService _userStatsService;

  late AnimationController _headerAnimationController;
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Initialize animations
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutQuart,
    ));

    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutQuart,
    ));

    // Initialize user stats service
    _userStatsService = UserStatsService(
      userRepository: context.read(),
    );

    // Start animations
    _headerAnimationController.forward();

    // Load users when page initializes
    context.read<UsersCubit>().loadUsers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<UsersCubit>().loadMoreUsers();
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<UsersCubit>().searchUsers(query);
    });
  }

  void _onRefresh() {
    _userStatsService.clearCache();
    _userStats.clear();
    _loadingStats.clear();
    context.read<UsersCubit>().refreshUsers();
  }

  // Load stats for users
  Future<void> _loadStatsForUsers(List<User> users) async {
    final userIds = users
        .map((user) => user.id)
        .where(
            (id) => !_userStats.containsKey(id) && !_loadingStats.contains(id))
        .toList();

    if (userIds.isEmpty) return;

    setState(() {
      _loadingStats.addAll(userIds);
    });

    try {
      final statsMap = await _userStatsService.getUsersStats(userIds);

      if (mounted) {
        setState(() {
          _userStats.addAll(statsMap);
          _loadingStats.removeAll(userIds);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingStats.removeAll(userIds);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            // Enhanced header
            SlideTransition(
              position: _headerSlideAnimation,
              child: FadeTransition(
                opacity: _headerFadeAnimation,
                child: _buildEnhancedHeader(theme, colorScheme),
              ),
            ),

            // Enhanced search bar
            FadeTransition(
              opacity: _headerFadeAnimation,
              child: _buildEnhancedSearchBar(theme, colorScheme),
            ),

            // Users list
            Expanded(
              child: BlocConsumer<UsersCubit, UsersCubitState>(
                listener: (context, state) {
                  // Load stats when users are loaded
                  if (state.users.isNotEmpty) {
                    _loadStatsForUsers(state.users);
                  }
                },
                builder: (context, state) {
                  if (state.isLoading && state.users.isEmpty) {
                    return _buildLoadingState(theme);
                  }

                  if (state.error != null && state.users.isEmpty) {
                    return _buildErrorState(state.error!, theme);
                  }

                  if (state.users.isEmpty) {
                    return _buildEmptyState(theme);
                  }

                  return _buildUsersList(state, theme);
                },
              ),
            ),

            // Enhanced status bar
            BlocBuilder<UsersCubit, UsersCubitState>(
              builder: (context, state) {
                if (state.isOffline ||
                    state.isSyncing ||
                    state.lastSyncTime != null) {
                  return _buildEnhancedStatusBar(state, theme);
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withOpacity(0.8),
            colorScheme.secondaryContainer.withOpacity(0.6),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Users Directory',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                BlocBuilder<UsersCubit, UsersCubitState>(
                  builder: (context, state) {
                    return Text(
                      '${state.users.length} users loaded',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          _buildActionButtons(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: _onRefresh,
            icon: Icon(
              Icons.refresh,
              color: colorScheme.primary,
            ),
            tooltip: 'Refresh',
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.primary,
            ),
            onSelected: (value) async {
              switch (value) {
                case 'sync':
                  await context.read<UsersCubit>().forceSync();
                  break;
                case 'cache_info':
                  _showCacheInfo();
                  break;
                case 'pagination_info':
                  _showPaginationInfo();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sync',
                child: Row(
                  children: [
                    Icon(Icons.sync),
                    SizedBox(width: 8),
                    Text('Force Sync'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cache_info',
                child: Row(
                  children: [
                    Icon(Icons.storage),
                    SizedBox(width: 8),
                    Text('Cache Info'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pagination_info',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Pagination Info'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedSearchBar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search users by name, username, or email...',
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.primary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    context.read<UsersCubit>().loadUsers();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildUsersList(UsersCubitState state, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        itemCount: state.users.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: LoadingIndicator()),
            );
          }

          final user = state.users[index];
          final stats = _userStats[user.id];
          final isLoadingStats = _loadingStats.contains(user.id);
          final isInitialBatch = index < 15; // First 15 are from initial batch

          return AnimatedContainer(
            duration: Duration(milliseconds: 200 + (index * 50)),
            curve: Curves.easeOutBack,
            child: EnhancedUserListTile(
              user: user,
              postsCount: stats?.postsCount,
              todosCount: stats?.todosCount,
              isLoading: isLoadingStats,
              isInitialBatch: isInitialBatch,
              onTap: () => context.goToUserProfile(user.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading users...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
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
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
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
                  Icons.people_outline,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Users Found',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Try adjusting your search or refresh the page.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _onRefresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedStatusBar(UsersCubitState state, ThemeData theme) {
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: state.isOffline
            ? colorScheme.errorContainer
            : state.isSyncing
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(
            state.isOffline
                ? Icons.wifi_off
                : state.isSyncing
                    ? Icons.sync
                    : Icons.check_circle,
            size: 20,
            color: state.isOffline
                ? colorScheme.onErrorContainer
                : state.isSyncing
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.isOffline
                  ? 'Offline - Showing cached users'
                  : state.isSyncing
                      ? 'Syncing with server...'
                      : state.lastSyncTime != null
                          ? 'Last synced: ${_formatTime(state.lastSyncTime!)}'
                          : 'All systems ready',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: state.isOffline
                    ? colorScheme.onErrorContainer
                    : state.isSyncing
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (state.isSyncing)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showCacheInfo() async {
    final cacheInfo = await context.read<UsersCubit>().getCacheInfo();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Total Cached Users',
                '${cacheInfo['total_cached_users'] ?? 0}'),
            _buildInfoRow('Initial Batch Count',
                '${cacheInfo['initial_batch_count'] ?? 0}'),
            _buildInfoRow('Has Initial Batch',
                '${cacheInfo['has_initial_batch'] ?? false}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPaginationInfo() {
    final paginationInfo = context.read<UsersCubit>().getPaginationInfo();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pagination Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Current Skip', '${paginationInfo['currentSkip']}'),
            _buildInfoRow(
                'Initial Batch Size', '${paginationInfo['initialBatchSize']}'),
            _buildInfoRow(
                'Pagination Size', '${paginationInfo['paginationSize']}'),
            _buildInfoRow(
                'Total Users Loaded', '${paginationInfo['totalUsersLoaded']}'),
            _buildInfoRow(
                'Has Reached Max', '${paginationInfo['hasReachedMax']}'),
            _buildInfoRow(
                'Is Loading More', '${paginationInfo['isLoadingMore']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
