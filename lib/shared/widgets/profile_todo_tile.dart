import 'package:flutter/material.dart';
import '../../features/users/domain/entities/todo.dart';

/// A robust, non-clickable todo tile widget designed for user profile sections.
/// This widget displays todo information in a clean, readonly format.
class ProfileTodoTile extends StatelessWidget {
  final Todo todo;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final bool showStatusBadge;
  final bool showUserInfo;
  final double? height;

  const ProfileTodoTile({
    super.key,
    required this.todo,
    this.margin,
    this.padding,
    this.showStatusBadge = true,
    this.showUserInfo = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;

    // Define colors based on completion status and theme
    final backgroundColor = todo.completed
        ? (isDarkMode
            ? colorScheme.primaryContainer.withOpacity(0.1)
            : colorScheme.primaryContainer.withOpacity(0.2))
        : (isDarkMode ? colorScheme.surface : colorScheme.surface);

    final borderColor = todo.completed
        ? colorScheme.primary.withOpacity(0.3)
        : colorScheme.outline.withOpacity(0.12);

    final checkboxColor = todo.completed
        ? colorScheme.primary
        : colorScheme.outline.withOpacity(0.5);

    final textColor = todo.completed
        ? colorScheme.onSurface.withOpacity(0.6)
        : colorScheme.onSurface;

    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Completion status indicator (non-interactive)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: todo.completed ? checkboxColor : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: checkboxColor,
                width: 2,
              ),
            ),
            child: todo.completed
                ? Icon(
                    Icons.check,
                    size: 14,
                    color: colorScheme.onPrimary,
                  )
                : null,
          ),

          const SizedBox(width: 12),

          // Todo content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Todo title
                Text(
                  todo.todo,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                    decoration: todo.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: colorScheme.primary,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // User info (if enabled)
                if (showUserInfo) ...[
                  const SizedBox(height: 4),
                  Text(
                    'User ID: ${todo.userId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],

                // Additional metadata if needed
                ...[
                  const SizedBox(height: 4),
                  Text(
                    'Task #${todo.id}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Status badge (if enabled)
          if (showStatusBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: todo.completed
                    ? colorScheme.primaryContainer
                    : colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                todo.completed ? 'Completed' : 'Pending',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: todo.completed
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A compact version of ProfileTodoTile for dense layouts
class CompactProfileTodoTile extends StatelessWidget {
  final Todo todo;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CompactProfileTodoTile({
    super.key,
    required this.todo,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: todo.completed
            ? colorScheme.primaryContainer.withOpacity(0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Small completion indicator
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: todo.completed ? colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: todo.completed
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: todo.completed
                ? Icon(
                    Icons.check,
                    size: 10,
                    color: colorScheme.onPrimary,
                  )
                : null,
          ),

          const SizedBox(width: 10),

          // Todo text
          Expanded(
            child: Text(
              todo.todo,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: todo.completed
                    ? colorScheme.onSurface.withOpacity(0.6)
                    : colorScheme.onSurface,
                decoration: todo.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                decorationColor: colorScheme.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Small status indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  todo.completed ? colorScheme.primary : colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
