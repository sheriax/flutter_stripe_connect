/// Stub file for non-web platforms
///
/// This file provides placeholder implementations that are never actually
/// used on non-web platforms - the kIsWeb check prevents their use.
library flutter_stripe_connect_stub;

import 'stripe_connect.dart';

/// Stub for web StripeConnect implementation
class StripeConnectWeb {
  static StripeConnectWeb? _instance;
  static StripeConnectWeb get instance => _instance ??= StripeConnectWeb._();

  StripeConnectWeb._();

  bool get isInitialized => throw UnimplementedError();

  Future<void> initialize({
    required String publishableKey,
    required ClientSecretProvider clientSecretProvider,
    ConnectAppearance? appearance,
  }) async {
    throw UnimplementedError();
  }

  void logout() {
    throw UnimplementedError();
  }
}
