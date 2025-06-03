import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../features/users/domain/entities/user.dart';

class EnhancedUserListTile extends StatelessWidget {
  final User user;
  final int? postsCount;
  final int? todosCount;
  final bool isLoading;
  final VoidCallback? onTap;
  final bool isInitialBatch;

  const EnhancedUserListTile({
    super.key,
    required this.user,
    this.postsCount,
    this.todosCount,
    this.isLoading = false,
    this.onTap,
    this.isInitialBatch = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap ?? () => context.go('/user-profile/${user.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Main user info row
                Row(
                  children: [
                    // Enhanced profile image with status indicator
                    Stack(
                      children: [
                        Hero(
                          tag: 'user_avatar_${user.id}',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary.withOpacity(0.15),
                                  colorScheme.secondary.withOpacity(0.15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: colorScheme.primaryContainer,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user.image,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.person,
                                      color: colorScheme.onPrimaryContainer,
                                      size: 20,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: colorScheme.primaryContainer,
                                    child: Icon(
                                      Icons.person,
                                      color: colorScheme.onPrimaryContainer,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Storage indicator
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isInitialBatch
                                  ? colorScheme.primary
                                  : colorScheme.tertiary,
                              border: Border.all(
                                color: colorScheme.surface,
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              isInitialBatch ? Icons.storage : Icons.cloud,
                              size: 6,
                              color: colorScheme.surface,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // User details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text(
                            user.fullName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),

                          // Username
                          Row(
                            children: [
                              Icon(
                                Icons.alternate_email,
                                size: 12,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  user.username,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Action button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.go('/user-profile/${user.id}'),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 14,
                                  color: colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'View',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Stats row
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // Posts count
                      Expanded(
                        child: _buildStatItem(
                          context: context,
                          icon: Icons.article_outlined,
                          label: 'Posts',
                          count: postsCount,
                          isLoading: isLoading,
                          color: colorScheme.primary,
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        height: 20,
                        color: colorScheme.outline.withOpacity(0.2),
                      ),

                      // Todos count
                      Expanded(
                        child: _buildStatItem(
                          context: context,
                          icon: Icons.checklist_outlined,
                          label: 'Todos',
                          count: todosCount,
                          isLoading: isLoading,
                          color: colorScheme.secondary,
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        height: 20,
                        color: colorScheme.outline.withOpacity(0.2),
                      ),

                      // Storage type
                      Expanded(
                        child: _buildStatItem(
                          context: context,
                          icon: isInitialBatch ? Icons.storage : Icons.cloud,
                          label: isInitialBatch ? 'Cached' : 'Online',
                          count: null,
                          isLoading: false,
                          color: isInitialBatch
                              ? colorScheme.primary
                              : colorScheme.tertiary,
                          showCount: false,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int? count,
    required bool isLoading,
    required Color color,
    bool showCount = true,
  }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(height: 2),
        if (showCount) ...[
          if (isLoading)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          else
            Text(
              count?.toString() ?? '-',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 11,
              ),
            ),
          const SizedBox(height: 1),
        ],
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 9,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
