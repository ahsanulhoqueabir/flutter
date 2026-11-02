import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

bool _hasNetwork(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);

final _connectivityStreamProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  yield _hasNetwork(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_hasNetwork);
});

/// Whether the device has a network interface. Assumes online until known.
///
/// A network can exist without internet access, so never block a request on
/// this: send it and handle `NetworkException`. Use this for UI hints only.
final isOnlineProvider = Provider<bool>(
  (ref) => ref.watch(_connectivityStreamProvider).value ?? true,
);
