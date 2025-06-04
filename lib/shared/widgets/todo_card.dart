import 'package:flutter/material.dart';
import '../../features/home/domain/entities/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;
  final VoidCallback? onTap;

  const TodoCard({
    super.key,
    required this.todo,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Completion status
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      todo.completed ? colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: todo.completed
                        ? colorScheme.primary
                        : colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: todo.completed
                    ? Icon(
                        Icons.check,
                        size: 16,
                        color: colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Todo text
              Expanded(
                child: Text(
                  todo.todo,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: todo.completed
                        ? colorScheme.onSurface.withOpacity(0.6)
                        : colorScheme.onSurface,
                    decoration:
                        todo.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: todo.completed
                      ? colorScheme.primaryContainer
                      : colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  todo.completed ? 'Completed' : 'Pending',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: todo.completed
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
