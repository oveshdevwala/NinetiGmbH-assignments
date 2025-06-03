import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/users/presentation/blocs/scroll_cubit.dart';

class FloatingScrollButtons extends StatefulWidget {
  final EdgeInsets? margin;
  final double? buttonSize;
  final Color? primaryColor;
  final Color? backgroundColor;

  const FloatingScrollButtons({
    super.key,
    this.margin,
    this.buttonSize,
    this.primaryColor,
    this.backgroundColor,
  });

  @override
  State<FloatingScrollButtons> createState() => _FloatingScrollButtonsState();
}

class _FloatingScrollButtonsState extends State<FloatingScrollButtons>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final buttonSize = widget.buttonSize ?? 56.0;
    final primaryColor = widget.primaryColor ?? colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? colorScheme.surface;

    return BlocConsumer<ScrollCubit, ScrollState>(
      listener: (context, state) {
        // Show/hide buttons based on scroll state
        if (state.showFloatingButtons) {
          _slideController.forward();
        } else {
          _slideController.reverse();
        }
      },
      builder: (context, state) {
        // Debug indicator - remove in production
        // if (!state.showFloatingButtons &&
        //     !state.canScrollToTop &&
        //     !state.canScrollToBottom) {
        //   return Positioned(
        //     right: widget.margin?.right ?? 20,
        //     bottom: widget.margin?.bottom ?? 100,
        //     child: Container(
        //       padding: const EdgeInsets.all(8),
        //       decoration: BoxDecoration(
        //         color: Colors.red.withOpacity(0.7),
        //         borderRadius: BorderRadius.circular(4),
        //       ),
        //       child: const Text(
        //         'No Scroll\nButtons',
        //         style: TextStyle(
        //           color: Colors.white,
        //           fontSize: 10,
        //           fontWeight: FontWeight.bold,
        //         ),
        //         textAlign: TextAlign.center,
        //       ),
        //     ),
        //   );
        // }

        return Positioned(
          right: widget.margin?.right ?? 20,
          bottom: widget.margin?.bottom ?? 100,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scroll to top button
                if (state.canScrollToTop)
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _buildScrollButton(
                          icon: Icons.keyboard_arrow_up_rounded,
                          onPressed: () {
                            try {
                              context.read<ScrollCubit>().scrollToTop();
                              _triggerFeedback();
                            } catch (e) {
                              // Ignore if widget is disposed
                            }
                          },
                          buttonSize: buttonSize,
                          primaryColor: primaryColor,
                          backgroundColor: backgroundColor,
                          theme: theme,
                          tooltip: 'Scroll to top',
                        ),
                      );
                    },
                  ),

                if (state.canScrollToTop && state.canScrollToBottom)
                  const SizedBox(height: 12),

                // Scroll to bottom button
                if (state.canScrollToBottom)
                  AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _buildScrollButton(
                          icon: Icons.keyboard_arrow_down_rounded,
                          onPressed: () {
                            try {
                              context.read<ScrollCubit>().scrollToBottom();
                              _triggerFeedback();
                            } catch (e) {
                              // Ignore if widget is disposed
                            }
                          },
                          buttonSize: buttonSize,
                          primaryColor: primaryColor,
                          backgroundColor: backgroundColor,
                          theme: theme,
                          tooltip: 'Scroll to bottom',
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double buttonSize,
    required Color primaryColor,
    required Color backgroundColor,
    required ThemeData theme,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(buttonSize / 2),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(buttonSize / 2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.15),
                    primaryColor.withOpacity(0.08),
                  ],
                ),
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: buttonSize * 0.45,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _triggerFeedback() {
    // Provide haptic feedback
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // iOS-style feedback
      // Note: You might want to add haptic_feedback package for better control
    }

    // Temporary scale animation for button press feedback
    _pulseController.reset();
    _pulseController.forward().then((_) {
      _pulseController.repeat(reverse: true);
    });
  }
}
