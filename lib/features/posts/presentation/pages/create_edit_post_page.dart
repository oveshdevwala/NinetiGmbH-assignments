import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/my_post.dart';
import '../blocs/my_posts_cubit.dart';

class CreateEditPostPage extends StatefulWidget {
  final MyPost? post; // null for create, non-null for edit

  const CreateEditPostPage({
    super.key,
    this.post,
  });

  @override
  State<CreateEditPostPage> createState() => _CreateEditPostPageState();
}

class _CreateEditPostPageState extends State<CreateEditPostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _authorController = TextEditingController();
  final _tagController = TextEditingController();

  List<String> _tags = [];
  final FocusNode _tagFocusNode = FocusNode();

  bool get isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.post!.title;
      _bodyController.text = widget.post!.body;
      _authorController.text = widget.post!.authorName;
      _tags = List.from(widget.post!.tags);
    } else {
      // Default author name for new posts
      _authorController.text = 'Anonymous User';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _authorController.dispose();
    _tagController.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim().toLowerCase();
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 10) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Post' : 'Create Post',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocConsumer<MyPostsCubit, MyPostsState>(
            listener: (context, state) {
              if (!state.isCreating &&
                  !state.isUpdating &&
                  state.error == null) {
                // Successfully created or updated
                if (isEditing
                    ? state.posts.any((p) => p.id == widget.post!.id)
                    : state.posts.isNotEmpty) {
                  context.pop();
                }
              }

              if (state.error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error!),
                    backgroundColor: colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                child: ElevatedButton(
                  onPressed:
                      (state.isCreating || state.isUpdating) ? null : _savePost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: (state.isCreating || state.isUpdating)
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : Text(
                          isEditing ? 'Update' : 'Publish',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.tertiary.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isEditing ? Icons.edit_note : Icons.create,
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Edit Your Post' : 'Create New Post',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEditing
                                ? 'Make changes to your existing post'
                                : 'Share your thoughts with the world',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Author Name Field
              _buildInputField(
                controller: _authorController,
                label: 'Author Name',
                hint: 'Your name or pen name...',
                icon: Icons.person_outline,
                maxLength: 50,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
                theme: theme,
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 20),

              // Title Field
              _buildInputField(
                controller: _titleController,
                label: 'Post Title',
                hint: 'Enter a catchy title...',
                icon: Icons.title_outlined,
                maxLength: 100,
                style: theme.textTheme.titleMedium,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
                theme: theme,
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 20),

              // Body Field
              _buildInputField(
                controller: _bodyController,
                label: 'Content',
                hint: 'Write your post content here...',
                icon: Icons.description_outlined,
                maxLines: 8,
                minLines: 5,
                maxLength: 1000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter some content';
                  }
                  if (value.trim().length < 10) {
                    return 'Content must be at least 10 characters';
                  }
                  return null;
                },
                theme: theme,
                colorScheme: colorScheme,
              ),

              const SizedBox(height: 20),

              // Tags Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tags',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_tags.length}/10',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Tag input field
                    TextFormField(
                      controller: _tagController,
                      focusNode: _tagFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Add a tag and press enter...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.5),
                        ),
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.add,
                            color: colorScheme.primary,
                          ),
                          onPressed: _addTag,
                        ),
                      ),
                      onFieldSubmitted: (_) => _addTag(),
                      textInputAction: TextInputAction.done,
                    ),

                    // Tags display
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colorScheme.secondary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '#$tag',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => _removeTag(tag),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tips Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Writing Tips',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...[
                      '✨ Write a clear, descriptive title',
                      '📝 Add detailed content to engage readers',
                      '🏷️ Use relevant tags to help others discover your post',
                      '💾 All posts are saved locally on your device',
                      '🎯 Keep your content focused and valuable',
                    ].map((tip) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            tip,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required ThemeData theme,
    required ColorScheme colorScheme,
    int? maxLength,
    int? maxLines,
    int? minLines,
    TextStyle? style,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: colorScheme.primary,
            ),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colorScheme.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: style ?? theme.textTheme.bodyMedium,
          maxLength: maxLength,
          maxLines: maxLines ?? 1,
          minLines: minLines,
          validator: validator,
        ),
      ],
    );
  }

  void _savePost() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final body = _bodyController.text.trim();
      final authorName = _authorController.text.trim();

      if (isEditing) {
        // Update existing post
        final updatedPost = widget.post!.copyWith(
          title: title,
          body: body,
          authorName: authorName,
          tags: _tags,
          updatedAt: DateTime.now(),
        );
        context.read<MyPostsCubit>().updatePost(updatedPost);
      } else {
        // Create new post
        context.read<MyPostsCubit>().createPost(
              title: title,
              body: body,
              authorName: authorName,
              tags: _tags,
            );
      }
    }
  }
}
