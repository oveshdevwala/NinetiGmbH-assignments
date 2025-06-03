import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to manage connectivity status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamController<bool>? _connectivityController;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  /// Stream of connectivity status
  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    final initialResult = await _connectivity.checkConnectivity();
    final isConnected = _isConnected(initialResult);
    _connectivityController?.add(isConnected);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> result) {
        final connected = _isConnected(result);
        _connectivityController?.add(connected);
        log('Connectivity changed: $connected');
      },
    );
  }

  /// Check if currently connected
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result);
  }

  /// Helper to determine if connected based on ConnectivityResult
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription.cancel();
    _connectivityController?.close();
    _connectivityController = null;
  }
}
