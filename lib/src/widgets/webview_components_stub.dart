/// Web stub for the mobile-only WebView widget.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../models/webview_config.dart';

export 'webview_paths.dart';

/// WebView rendering is only available on mobile platforms.
class StripeConnectWebView extends StatelessWidget {
  final String componentPath;
  final WebViewConfig config;
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final VoidCallback? onExit;
  final VoidCallback? onClose;
  final Map<String, String>? extraParams;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripeConnectWebView({
    super.key,
    required this.componentPath,
    required this.config,
    this.onLoaded,
    this.onLoadError,
    this.onExit,
    this.onClose,
    this.extraParams,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) => throw UnsupportedError(
    'StripeConnectWebView is only available on mobile. '
    'Use a Stripe Connect component widget on web.',
  );
}
