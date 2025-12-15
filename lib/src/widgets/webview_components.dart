import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/webview_config.dart';
import '../stripe_connect.dart';

/// Component paths for Stripe Connect WebView
class StripeConnectPaths {
  // Onboarding & Compliance
  static const accountOnboarding = '/onboarding';
  static const accountManagement = '/account';
  static const notificationBanner = '/notifications';

  // Payments
  static const payments = '/payments';
  static const paymentDetails = '/payment-details';
  static const paymentMethodSettings = '/payment-methods';
  static const disputesForPayment = '/dispute';
  static const disputesList = '/disputes';

  // Payouts
  static const payouts = '/payouts';
  static const payoutDetails = '/payout-details';
  static const payoutsList = '/payouts-list';
  static const balances = '/balances';
  static const instantPayoutsPromotion = '/instant-payouts';
  static const recipients = '/recipients';

  // Capital
  static const capitalFinancing = '/capital';
  static const capitalFinancingApplication = '/capital-apply';
  static const capitalFinancingPromotion = '/capital-promo';

  // Tax
  static const taxRegistrations = '/tax-registrations';
  static const taxSettings = '/tax-settings';

  // Financial Services / Issuing
  static const financialAccount = '/financial-account';
  static const financialAccountTransactions = '/financial-txns';
  static const issuingCard = '/issuing-card';
  static const issuingCardsList = '/issuing-cards';

  // Reporting
  static const documents = '/documents';
  static const reportingChart = '/reporting';
}

/// Callback for when a component finishes loading
typedef OnLoadCallback = void Function();

/// Callback for component errors
typedef OnLoadErrorCallback = void Function(String error);

/// Callback for when onboarding exits
typedef OnExitCallback = void Function();

/// Callback for when a component overlay is closed
typedef OnCloseCallback = void Function();

/// WebView-based Stripe Connect component widget
class StripeConnectWebView extends StatefulWidget {
  /// The component path to display
  final String componentPath;

  /// WebView configuration (base URL, theme, etc.)
  final WebViewConfig config;

  /// Callback when the component loads successfully
  final OnLoadCallback? onLoaded;

  /// Callback when there's a load error
  final OnLoadErrorCallback? onLoadError;

  /// Callback when the user exits (for onboarding)
  final OnExitCallback? onExit;

  /// Callback when overlay is closed (for details views)
  final OnCloseCallback? onClose;

  /// Extra query parameters to pass to the URL
  final Map<String, String>? extraParams;

  const StripeConnectWebView({
    super.key,
    required this.componentPath,
    required this.config,
    this.onLoaded,
    this.onLoadError,
    this.onExit,
    this.onClose,
    this.extraParams,
  });

  @override
  State<StripeConnectWebView> createState() => _StripeConnectWebViewState();
}

class _StripeConnectWebViewState extends State<StripeConnectWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;
  String? _clientSecret;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      // Fetch client secret from the provider
      final clientSecretProvider = StripeConnect.instance.clientSecretProvider;
      if (clientSecretProvider == null) {
        throw Exception(
          'StripeConnect not initialized. Call StripeConnect.initialize() first.',
        );
      }

      _clientSecret = await clientSecretProvider();
      if (!mounted) return;

      final publishableKey = StripeConnect.instance.publishableKey;
      if (publishableKey == null) {
        throw Exception('Publishable key not set');
      }

      // Build the URL
      final url = widget.config.buildUrl(
        componentPath: widget.componentPath,
        publishableKey: publishableKey,
        clientSecret: _clientSecret!,
        extraParams: widget.extraParams,
      );

      // Initialize WebViewController
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) {
                setState(() => _isLoading = true);
              }
            },
            onPageFinished: (_) {
              if (mounted) {
                setState(() => _isLoading = false);
                widget.onLoaded?.call();
              }
            },
            onWebResourceError: (error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _error = error.description;
                });
                widget.onLoadError?.call(error.description);
              }
            },
          ),
        )
        ..addJavaScriptChannel(
          'FlutterChannel',
          onMessageReceived: _handleJavaScriptMessage,
        )
        ..loadRequest(url);

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
        widget.onLoadError?.call(e.toString());
      }
    }
  }

  void _handleJavaScriptMessage(JavaScriptMessage message) {
    try {
      final data = jsonDecode(message.message);
      final type = data['type'] as String?;

      switch (type) {
        case 'ONBOARDING_EXIT':
          widget.onExit?.call();
          break;
        case 'COMPONENT_LOADED':
          widget.onLoaded?.call();
          break;
        case 'COMPONENT_ERROR':
          widget.onLoadError?.call(data['error'] as String? ?? 'Unknown error');
          break;
        case 'OVERLAY_CLOSE':
          widget.onClose?.call();
          break;
      }
    } catch (_) {
      // Handle plain text messages
      if (message.message == 'ONBOARDING_EXIT') {
        widget.onExit?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load component',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                    _isInitialized = false;
                  });
                  _initializeWebView();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_isLoading) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
