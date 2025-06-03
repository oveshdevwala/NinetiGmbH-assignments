import 'package:flutter/material.dart';
import '../../features/users/domain/entities/todo.dart';
import 'profile_todo_tile.dart';

/// Example usage and variations of ProfileTodoTile and CompactProfileTodoTile widgets
/// This file demonstrates how to use these robust, non-clickable todo widgets
/// in different scenarios within user profile sections.

class ProfileTodoExamples extends StatelessWidget {
  const ProfileTodoExamples({super.key});

  @override
  Widget build(BuildContext context) {
    // Example todo data
    const completedTodo = Todo(
      id: 1,
      todo: "Memorize a poem",
      completed: true,
      userId: 1,
    );

    const pendingTodo = Todo(
      id: 2,
      todo: "Create a compost file for better organization",
      completed: false,
      userId: 1,
    );

    const longTodo = Todo(
      id: 3,
      todo:
          "Learn the periodic table of elements and their chemical properties for the upcoming chemistry exam",
      completed: false,
      userId: 1,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Todo Examples'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Profile Todo Tile Examples',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Robust, non-clickable todo widgets for user profile sections',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 24),

            // Standard ProfileTodoTile
            _buildSection(
              context,
              'Standard Profile Todo Tile',
              'Default appearance with status badge',
              [
                const ProfileTodoTile(todo: completedTodo),
                const ProfileTodoTile(todo: pendingTodo),
                const ProfileTodoTile(todo: longTodo),
              ],
            ),

            // Without status badge
            _buildSection(
              context,
              'Without Status Badge',
              'Cleaner look for dense layouts',
              [
                const ProfileTodoTile(
                  todo: completedTodo,
                  showStatusBadge: false,
                ),
                const ProfileTodoTile(
                  todo: pendingTodo,
                  showStatusBadge: false,
                ),
              ],
            ),

            // With user info
            _buildSection(
              context,
              'With User Information',
              'Shows additional user metadata',
              [
                const ProfileTodoTile(
                  todo: completedTodo,
                  showUserInfo: true,
                ),
                const ProfileTodoTile(
                  todo: pendingTodo,
                  showUserInfo: true,
                ),
              ],
            ),

            // Custom spacing
            _buildSection(
              context,
              'Custom Spacing',
              'Different margin and padding options',
              [
                const ProfileTodoTile(
                  todo: completedTodo,
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  padding: EdgeInsets.all(12),
                ),
                const ProfileTodoTile(
                  todo: pendingTodo,
                  margin: EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                  padding: EdgeInsets.all(20),
                ),
              ],
            ),

            // Compact version
            _buildSection(
              context,
              'Compact Todo Tiles',
              'Space-efficient version for dense layouts',
              [
                const CompactProfileTodoTile(todo: completedTodo),
                const CompactProfileTodoTile(todo: pendingTodo),
                const CompactProfileTodoTile(todo: longTodo),
              ],
            ),

            // In a column layout
            _buildSection(
              context,
              'Column Layout Example',
              'How they look in a typical profile section',
              [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Todos',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      const ProfileTodoTile(
                        todo: completedTodo,
                        margin: EdgeInsets.only(bottom: 8),
                      ),
                      const ProfileTodoTile(
                        todo: pendingTodo,
                        margin: EdgeInsets.only(bottom: 8),
                      ),
                      const CompactProfileTodoTile(
                        todo: longTodo,
                        margin: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Usage notes
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Usage Notes',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• These widgets are non-clickable and read-only\n'
                    '• Perfect for user profile sections where todos are displayed for viewing\n'
                    '• Automatically adapts to light and dark themes\n'
                    '• Supports text overflow and proper truncation\n'
                    '• Use ProfileTodoTile for standard layouts\n'
                    '• Use CompactProfileTodoTile for dense information display',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String description,
    List<Widget> examples,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
        ),
        const SizedBox(height: 12),
        ...examples,
        const SizedBox(height: 24),
      ],
    );
  }
}
