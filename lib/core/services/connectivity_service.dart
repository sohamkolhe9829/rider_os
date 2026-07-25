import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Monitors device network connectivity state.
///
/// Used to determine when online-optional features (weather,
/// cloud sync placeholder) are available. RiderOS is offline-first
/// — all core features work without connectivity.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final _statusController = StreamController<ConnectionStatus>.broadcast();

  /// Stream of connection status changes.
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  /// Most recent connection status.
  ConnectionStatus _lastStatus = ConnectionStatus.unknown;
  ConnectionStatus get lastStatus => _lastStatus;

  /// Whether the device currently has any network connection.
  bool get isConnected => _lastStatus == ConnectionStatus.connected;

  /// Start monitoring connectivity changes.
  Future<void> startMonitoring() async {
    if (_subscription != null) return;

    // Get initial state.
    try {
      final results = await _connectivity.checkConnectivity();
      _processResults(results);
    } catch (e) {
      debugPrint('ConnectivityService: Initial check failed: $e');
    }

    // Listen for changes.
    _subscription = _connectivity.onConnectivityChanged.listen(
      _processResults,
      onError: (e) => debugPrint('ConnectivityService: Stream error: $e'),
    );
  }

  /// Stop monitoring connectivity.
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _processResults(List<ConnectivityResult> results) {
    final status = _resolveStatus(results);
    if (status != _lastStatus) {
      _lastStatus = status;
      _statusController.add(status);
    }
  }

  /// Resolves a list of connectivity results into a single status.
  static ConnectionStatus _resolveStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none) || results.isEmpty) {
      return ConnectionStatus.disconnected;
    }
    return ConnectionStatus.connected;
  }

  /// Clean up resources.
  void dispose() {
    stopMonitoring();
    _statusController.close();
  }
}

/// Simplified connection status.
///
/// RiderOS doesn't need to differentiate between WiFi, mobile,
/// etc. — it only needs to know if any connection exists.
enum ConnectionStatus { connected, disconnected, unknown }
