import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'models/webview_config.dart';
import 'widgets/connect_components.dart'
    show OnExitCallback, OnLoadErrorCallback;

// Conditional import for web support
import 'stripe_connect_stub.dart'
    if (dart.library.html) 'stripe_connect_web.dart' as web_impl;

typedef ClientSecretProvider = Future<String> Function();

class StripeConnect {
  static const MethodChannel _channel = MethodChannel('flutter_stripe_connect');

  static StripeConnect? _instance;
  static StripeConnect get instance => _instance ??= StripeConnect._();

  StripeConnect._();

  ClientSecretProvider? _clientSecretProvider;
  String? _publishableKey;
  WebViewConfig? _webViewConfig;

  // Callbacks for presentAccountOnboarding
  static OnExitCallback? _onAccountOnboardingExit;
  static OnLoadErrorCallback? _onAccountOnboardingLoadError;

  /// Get the client secret provider for WebView components
  ClientSecretProvider? get clientSecretProvider => _clientSecretProvider;

  /// Get the publishable key for WebView components
  String? get publishableKey => _publishableKey;

  /// Get the WebView configuration (null if using native mode)
  static WebViewConfig? get webViewConfig => instance._webViewConfig;

  /// Initialize Stripe Connect with your publishable key
  /// [publishableKey] - Your Stripe publishable key
  /// [clientSecretProvider] - Async function that fetches a client secret from your server
  /// [appearance] - Optional appearance customization (only used on web)
  /// [webViewConfig] - Optional WebView configuration for mobile platforms
  ///   When provided, components will render via WebView instead of native SDK
  Future<void> initialize({
    required String publishableKey,
    required ClientSecretProvider clientSecretProvider,
    ConnectAppearance? appearance,
    WebViewConfig? webViewConfig,
  }) async {
    _clientSecretProvider = clientSecretProvider;
    _publishableKey = publishableKey;
    _webViewConfig = webViewConfig;

    if (kIsWeb) {
      // Use web-specific initialization
      await web_impl.StripeConnectWeb.instance.initialize(
        publishableKey: publishableKey,
        clientSecretProvider: clientSecretProvider,
        appearance: appearance,
      );
      return;
    }

    // Native platform initialization (only if not using WebView mode)
    if (webViewConfig == null) {
      _channel.setMethodCallHandler(_handleMethodCall);

      await _channel.invokeMethod('initialize', {
        'publishableKey': publishableKey,
      });
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'fetchClientSecret':
        if (_clientSecretProvider == null) {
          throw Exception('Client secret provider not set');
        }
        return await _clientSecretProvider!();
      case 'onAccountOnboardingExit':
        _onAccountOnboardingExit?.call();
        break;
      case 'onAccountOnboardingLoadError':
        final error = call.arguments as String? ?? 'Unknown error';
        _onAccountOnboardingLoadError?.call(error);
        break;
      default:
        throw MissingPluginException('Unknown method ${call.method}');
    }
  }

  /// Logout and clear the current session
  Future<void> logout() async {
    if (kIsWeb) {
      web_impl.StripeConnectWeb.instance.logout();
      return;
    }
    await _channel.invokeMethod('logout');
  }

  /// Present the Account Onboarding flow modally.
  ///
  /// This allows you to trigger onboarding from your own UI (e.g., a button tap)
  /// without embedding the [StripeAccountOnboarding] widget.
  ///
  /// [onExit] - Called when the user closes the onboarding flow
  /// [onLoadError] - Called if there's an error loading the onboarding flow
  ///
  /// Example:
  /// ```dart
  /// await StripeConnect.presentAccountOnboarding(
  ///   onExit: () => print('User exited onboarding'),
  ///   onLoadError: (error) => print('Error: $error'),
  /// );
  /// ```
  static Future<void> presentAccountOnboarding({
    OnExitCallback? onExit,
    OnLoadErrorCallback? onLoadError,
  }) async {
    if (kIsWeb) {
      onLoadError?.call(
          'presentAccountOnboarding is not supported on web. Use StripeAccountOnboarding widget instead.');
      return;
    }

    // Store callbacks for native to call back
    _onAccountOnboardingExit = onExit;
    _onAccountOnboardingLoadError = onLoadError;

    try {
      await _channel.invokeMethod('presentAccountOnboarding');
    } on PlatformException catch (e) {
      onLoadError?.call(e.message ?? 'Unknown error');
    }
  }
}

/// Appearance configuration for Stripe Connect components
class ConnectAppearance {
  final String? fontFamily;
  final ConnectColors? colors;
  final double? cornerRadius;

  const ConnectAppearance({this.fontFamily, this.colors, this.cornerRadius});

  Map<String, dynamic> toMap() => {
        if (fontFamily != null) 'fontFamily': fontFamily,
        if (colors != null) 'colors': colors!.toMap(),
        if (cornerRadius != null) 'cornerRadius': cornerRadius,
      };
}

class ConnectColors {
  final String? primary;
  final String? background;
  final String? text;
  final String? secondaryText;
  final String? border;
  final String? actionPrimaryText;
  final String? actionSecondaryText;
  final String? formBackground;
  final String? formHighlightBorder;

  const ConnectColors({
    this.primary,
    this.background,
    this.text,
    this.secondaryText,
    this.border,
    this.actionPrimaryText,
    this.actionSecondaryText,
    this.formBackground,
    this.formHighlightBorder,
  });

  Map<String, dynamic> toMap() => {
        if (primary != null) 'primary': primary,
        if (background != null) 'background': background,
        if (text != null) 'text': text,
        if (secondaryText != null) 'secondaryText': secondaryText,
        if (border != null) 'border': border,
        if (actionPrimaryText != null) 'actionPrimaryText': actionPrimaryText,
        if (actionSecondaryText != null)
          'actionSecondaryText': actionSecondaryText,
        if (formBackground != null) 'formBackground': formBackground,
        if (formHighlightBorder != null)
          'formHighlightBorder': formHighlightBorder,
      };
}
