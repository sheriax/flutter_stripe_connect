/// Web-specific component widgets for Stripe Connect
///
/// These widgets use HtmlElementView to embed Connect.js components.
library flutter_stripe_connect_web_components;

import 'dart:ui_web' as ui_web;
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

import '../stripe_connect.dart';
import '../stripe_connect_web.dart';
import 'connect_components.dart';

/// Counter for generating unique view IDs
int _viewIdCounter = 0;

/// Base class for web-specific Stripe Connect components
class StripeConnectWebView extends StatefulWidget {
  /// The component type identifier
  final StripeConnectViewType componentType;

  /// Called when the component finishes loading
  final VoidCallback? onLoaded;

  /// Called when the component fails to load
  final void Function(String error)? onLoadError;

  /// Called when the component is dismissed (for onboarding)
  final VoidCallback? onExit;

  /// Appearance customization
  final ConnectAppearance? appearance;

  /// Extra parameters for the component
  final Map<String, dynamic>? extraParams;

  const StripeConnectWebView({
    super.key,
    required this.componentType,
    this.onLoaded,
    this.onLoadError,
    this.onExit,
    this.appearance,
    this.extraParams,
  });

  @override
  State<StripeConnectWebView> createState() => _StripeConnectWebViewState();
}

class _StripeConnectWebViewState extends State<StripeConnectWebView> {
  late final String _viewType;
  bool _isCreated = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _viewType =
        'stripe-connect-${widget.componentType.value}-${_viewIdCounter++}-${math.Random().nextInt(10000)}';
    _registerViewFactory();
  }

  void _registerViewFactory() {
    // Register the platform view factory for this component
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final container =
            web.document.createElement('div') as web.HTMLDivElement;
        container.style
          ..width = '100%'
          ..height = '100%'
          ..display = 'flex'
          ..flexDirection = 'column';

        // Schedule component creation after the container is added to DOM
        _createComponentAsync(container);

        return container;
      },
    );
    _isCreated = true;
  }

  Future<void> _createComponentAsync(web.HTMLDivElement container) async {
    // Small delay to ensure the container is in the DOM
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final webInstance = StripeConnectWeb.instance;

      if (!webInstance.isInitialized) {
        const errorMsg =
            'Stripe Connect not initialized. Call StripeConnect.initialize() first.';
        debugPrint('StripeConnectWebView: $errorMsg');
        _showError(container, errorMsg);
        widget.onLoadError?.call(errorMsg);
        return;
      }

      final component = webInstance.createComponent(widget.componentType);
      if (component == null) {
        final errorMsg =
            'Failed to create ${widget.componentType.value} component';
        debugPrint('StripeConnectWebView: $errorMsg');
        _showError(container, errorMsg);
        widget.onLoadError?.call(errorMsg);
        return;
      }

      // Set component to fill container
      component.style
        ..width = '100%'
        ..height = '100%';

      container.appendChild(component);

      debugPrint(
          'StripeConnectWebView: Component ${widget.componentType.value} created successfully');
      widget.onLoaded?.call();
    } catch (e) {
      final errorMsg = 'Error creating component: $e';
      debugPrint('StripeConnectWebView: $errorMsg');
      _showError(container, errorMsg);
      widget.onLoadError?.call(errorMsg);
    }
  }

  void _showError(web.HTMLDivElement container, String message) {
    final errorDiv = web.document.createElement('div') as web.HTMLDivElement;
    errorDiv.style
      ..padding = '16px'
      ..color = '#dc3545'
      ..textAlign = 'center'
      ..fontFamily = 'system-ui, -apple-system, sans-serif';
    errorDiv.textContent = message;
    container.appendChild(errorDiv);

    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCreated) {
      return const Center(
        child: Text('Loading...'),
      );
    }

    if (_hasError) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Color(0xFFDC3545)),
        ),
      );
    }

    return HtmlElementView(
      viewType: _viewType,
    );
  }
}

/// Account Onboarding component for web
class StripeAccountOnboardingWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final VoidCallback? onExit;
  final ConnectAppearance? appearance;

  const StripeAccountOnboardingWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.onExit,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.accountOnboarding,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      onExit: onExit,
      appearance: appearance,
    );
  }
}

/// Account Management component for web
class StripeAccountManagementWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeAccountManagementWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.accountManagement,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}

/// Payments component for web
class StripePaymentsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripePaymentsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.payments,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}

/// Payouts component for web
class StripePayoutsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripePayoutsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.payouts,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}

/// Notification Banner component for web
class StripeNotificationBannerWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeNotificationBannerWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.notificationBanner,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}

/// Balances component for web
class StripeBalancesWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeBalancesWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.balances,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}

/// Documents component for web
class StripeDocumentsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeDocumentsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.documents,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}

/// Tax Settings component for web
class StripeTaxSettingsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeTaxSettingsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.taxSettings,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}

/// Tax Registrations component for web
class StripeTaxRegistrationsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeTaxRegistrationsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.taxRegistrations,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}

/// Payouts List component for web
class StripePayoutsListWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripePayoutsListWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.payoutsList,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}

/// Payment Details component for web
class StripePaymentDetailsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final VoidCallback? onClose;
  final ConnectAppearance? appearance;
  final String? paymentId;

  const StripePaymentDetailsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.onClose,
    this.appearance,
    this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.paymentDetails,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      extraParams: paymentId != null ? {'paymentId': paymentId} : null,
    );
  }
}

/// Payout Details component for web
class StripePayoutDetailsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final VoidCallback? onClose;
  final ConnectAppearance? appearance;
  final String? payoutId;

  const StripePayoutDetailsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.onClose,
    this.appearance,
    this.payoutId,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.payoutDetails,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      extraParams: payoutId != null ? {'payoutId': payoutId} : null,
    );
  }
}

/// Disputes List component for web
class StripeDisputesListWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String error)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeDisputesListWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) {
    return StripeConnectWebView(
      componentType: StripeConnectViewType.disputesList,
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
    );
  }
}
