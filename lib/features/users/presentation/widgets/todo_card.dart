import 'package:flutter/material.dart';
import '../../domain/entities/todo.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;
  final VoidCallback? onTap;
  final Function(bool?)? onCompletedChanged;

  const TodoCard({
    super.key,
    required this.todo,
    this.onTap,
    this.onCompletedChanged,
  });

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    if (widget.todo.completed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onTap?.call();
  }

  void _handleCheckboxChanged(bool? value) {
    if (value == true) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onCompletedChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.todo.completed
                        ? colorScheme.primaryContainer.withOpacity(0.3)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.todo.completed
                          ? colorScheme.primary.withOpacity(0.3)
                          : colorScheme.outline.withOpacity(0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Custom Checkbox with Animation
                      GestureDetector(
                        // onTap: () =>
                        //     _handleCheckboxChanged(!widget.todo.completed),
                        child: AnimatedBuilder(
                          animation: _checkAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: widget.todo.completed
                                    ? colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.todo.completed
                                      ? colorScheme.primary
                                      : colorScheme.outline.withOpacity(0.5),
                                  width: 2,
                                ),
                              ),
                              child: widget.todo.completed
                                  ? Transform.scale(
                                      scale: _checkAnimation.value,
                                      child: Icon(
                                        Icons.check,
                                        size: 14,
                                        color: colorScheme.onPrimary,
                                      ),
                                    )
                                  : null,
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Todo Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with strikethrough animation
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                    color: widget.todo.completed
                                        ? colorScheme.onSurface.withOpacity(0.5)
                                        : colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    decoration: widget.todo.completed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: colorScheme.primary,
                                    height: 1.3,
                                  ) ??
                                  TextStyle(
                                    color: widget.todo.completed
                                        ? colorScheme.onSurface.withOpacity(0.5)
                                        : colorScheme.onSurface,
                                    fontWeight: FontWeight.w500,
                                    decoration: widget.todo.completed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: colorScheme.primary,
                                    height: 1.3,
                                  ),
                              child: Text(
                                widget.todo.todo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Metadata row
                            Row(
                              children: [
                                // Status Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.todo.completed
                                        ? colorScheme.primary.withOpacity(0.15)
                                        : colorScheme.tertiary
                                            .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    widget.todo.completed
                                        ? 'Completed'
                                        : 'Pending',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: widget.todo.completed
                                          ? colorScheme.primary
                                          : colorScheme.tertiary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Todo ID
                                Icon(
                                  Icons.tag,
                                  size: 10,
                                  color: colorScheme.onSurface.withOpacity(0.4),
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${widget.todo.id}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color:
                                        colorScheme.onSurface.withOpacity(0.4),
                                    fontSize: 10,
                                  ),
                                ),

                                const Spacer(),

                                // User indicator (if available)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer
                                        .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person_outline,
                                        size: 10,
                                        color: colorScheme.onSecondaryContainer
                                            .withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        'U${widget.todo.userId}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme
                                              .onSecondaryContainer
                                              .withOpacity(0.7),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Completion indicator
                      const SizedBox(width: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: widget.todo.completed
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
