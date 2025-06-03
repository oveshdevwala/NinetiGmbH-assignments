import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SyncStatusIndicator extends StatelessWidget {
  final bool isOffline;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final VoidCallback? onRefresh;

  const SyncStatusIndicator({
    super.key,
    required this.isOffline,
    required this.isSyncing,
    this.lastSyncTime,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      onPressed: isSyncing ? null : onRefresh,
      tooltip: _getTooltipText(),
      icon: Stack(
        children: [
          Icon(
            _getIcon(),
            color: _getIconColor(theme),
          ),
          if (isSyncing)
            Positioned.fill(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    if (isSyncing) {
      return Icons.sync;
    } else if (isOffline) {
      return Icons.cloud_off;
    } else {
      return Icons.cloud_done;
    }
  }

  Color _getIconColor(ThemeData theme) {
    if (isSyncing) {
      return theme.colorScheme.primary;
    } else if (isOffline) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getTooltipText() {
    if (isSyncing) {
      return 'Syncing...';
    } else if (isOffline) {
      return 'You are offline';
    } else {
      final lastSync = lastSyncTime != null
          ? 'Last synced: ${DateFormat('HH:mm').format(lastSyncTime!)}'
          : 'Connected';
      return lastSync;
    }
  }
}
