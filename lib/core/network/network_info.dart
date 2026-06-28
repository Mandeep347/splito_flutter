import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstract contract for checking internet connectivity.
abstract class INetworkInfo {
  /// Returns true if the device has active internet access.
  Future<bool> get isConnected;
}

/// Zero-dependency implementation of [INetworkInfo] that executes DNS resolution lookups
/// to ensure there is a live path to the web, rather than just an interface connection.
class NetworkInfo implements INetworkInfo {
  const NetworkInfo();

  @override
  Future<bool> get isConnected async {
    try {
      final lookupResults = await InternetAddress.lookup('google.com');
      return lookupResults.isNotEmpty && lookupResults[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

/// Provider for [INetworkInfo] interface.
final networkInfoProvider = Provider<INetworkInfo>((ref) {
  return const NetworkInfo();
});
