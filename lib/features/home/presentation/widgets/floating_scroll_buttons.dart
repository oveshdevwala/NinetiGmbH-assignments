
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/scroll_cubit/scroll_cubit.dart';

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
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final buttonSize = widget.buttonSize ?? 40.0;
    final primaryColor = widget.primaryColor ?? colorScheme.onPrimary;
    final backgroundColor = widget.backgroundColor ?? colorScheme.primary;

    return BlocConsumer<ScrollCubit, ScrollState>(
      listener: (context, state) {
        if (state.showFloatingButtons) {
          _slideController.forward();
        } else {
          _slideController.reverse();
        }
      },
      builder: (context, state) {
        return Positioned(
          right: widget.margin?.right ?? 20,
          bottom:
              widget.margin?.bottom ?? 25, // Set to exactly 45px from bottom
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Scroll to top button
                if (state.canScrollToTop)
                  _buildMinimalistButton(
                    icon: Icons.keyboard_arrow_up,
                    onPressed: () {
                      try {
                        context.read<ScrollCubit>().scrollToTop();
                      } catch (e) {
                        // Ignore if widget is disposed
                      }
                    },
                    buttonSize: buttonSize,
                    primaryColor: primaryColor,
                    backgroundColor: backgroundColor,
                    theme: theme,
                  ),

                if (state.canScrollToTop && state.canScrollToBottom)
                  const SizedBox(height: 8), // Reduced spacing

                // Scroll to bottom button
                if (state.canScrollToBottom)
                  _buildMinimalistButton(
                    icon: Icons.keyboard_arrow_down,
                    onPressed: () {
                      try {
                        context.read<ScrollCubit>().scrollToBottom();
                      } catch (e) {
                        // Ignore if widget is disposed
                      }
                    },
                    buttonSize: buttonSize,
                    primaryColor: primaryColor,
                    backgroundColor: backgroundColor,
                    theme: theme,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMinimalistButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double buttonSize,
    required Color primaryColor,
    required Color backgroundColor,
    required ThemeData theme,
  }) {
    return Container(
      width: buttonSize,
      height: buttonSize,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(buttonSize / 2),
        border: Border.all(
          color: primaryColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(buttonSize / 2),
          child: Icon(
            icon,
            color: primaryColor.withOpacity(0.8),
            size: buttonSize * 0.5, // More compact icon size
          ),
        ),
      ),
    );
  }
}
