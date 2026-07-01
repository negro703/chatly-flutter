import 'package:connectivity_plus/connectivity_plus.dart';

/// Abstract interface for network connectivity information.
abstract class NetworkInfo {
  /// Returns `true` if the device is connected to the internet.
  Future<bool> get isConnected;

  /// Stream of connectivity changes.
  Stream<bool> get onConnectivityChanged;
}

/// Implementation of [NetworkInfo] using connectivity_plus.
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({required this.connectivity});

  final Connectivity connectivity;

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return _isConnectedResult(result);
  }

  @override
  Stream<bool> get onConnectivityChanged {
    return connectivity.onConnectivityChanged.map(_isConnectedResult);
  }

  bool _isConnectedResult(List<ConnectivityResult> result) {
    return result.any((r) => r != ConnectivityResult.none);
  }
}