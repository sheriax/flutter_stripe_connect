/// Web plugin registration for Flutter Stripe Connect
library flutter_stripe_connect_web;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'src/stripe_connect.dart';
import 'src/stripe_connect_web.dart';

/// Web plugin implementation for Flutter Stripe Connect
class FlutterStripeConnectWeb {
  /// Registers the web plugin with Flutter
  static void registerWith(Registrar registrar) {
    // Web implementation doesn't need method channel registration
    // The StripeConnectWeb class handles all web-specific functionality
    debugPrint('FlutterStripeConnectWeb: Registered web plugin');
  }
}

/// Extension to make StripeConnect work on web
extension StripeConnectWebExtension on StripeConnect {
  /// Initialize for web platform
  static Future<void> initializeWeb({
    required String publishableKey,
    required ClientSecretProvider clientSecretProvider,
    ConnectAppearance? appearance,
  }) async {
    await StripeConnectWeb.instance.initialize(
      publishableKey: publishableKey,
      clientSecretProvider: clientSecretProvider,
      appearance: appearance,
    );
  }

  /// Logout on web
  static void logoutWeb() {
    StripeConnectWeb.instance.logout();
  }
}
