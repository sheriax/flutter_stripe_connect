/// Web implementation of Stripe Connect using Connect.js
///
/// This file provides JavaScript interop with Stripe's Connect.js library
/// for web platform support.
library flutter_stripe_connect_web;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'stripe_connect.dart';

/// JavaScript interop for StripeConnect global object
@JS('StripeConnect')
external StripeConnectJS? get stripeConnectGlobal;

/// JavaScript interop types for Connect.js
@JS()
@staticInterop
class StripeConnectJS {}

extension StripeConnectJSExtension on StripeConnectJS {
  @JS('init')
  external StripeConnectInstanceJS init(JSObject options);
}

@JS()
@staticInterop
class StripeConnectInstanceJS {}

extension StripeConnectInstanceJSExtension on StripeConnectInstanceJS {
  @JS('create')
  external web.HTMLElement create(String componentName);

  @JS('update')
  external void update(JSObject options);

  @JS('logout')
  external void logout();
}

/// Web-specific Stripe Connect manager
class StripeConnectWeb {
  static StripeConnectWeb? _instance;
  static StripeConnectWeb get instance => _instance ??= StripeConnectWeb._();

  StripeConnectWeb._();

  StripeConnectInstanceJS? _connectInstance;
  ClientSecretProvider? _clientSecretProvider;
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  /// Check if Connect.js is loaded
  bool get isLoaded => stripeConnectGlobal != null;

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Get the Connect instance
  StripeConnectInstanceJS? get connectInstance => _connectInstance;

  /// Initialize Stripe Connect for web
  Future<void> initialize({
    required String publishableKey,
    required ClientSecretProvider clientSecretProvider,
    ConnectAppearance? appearance,
  }) async {
    _clientSecretProvider = clientSecretProvider;

    // Wait for Connect.js to load if not already loaded
    await _waitForConnectJs();

    // Create the fetchClientSecret function that returns a Promise
    JSFunction fetchClientSecretJS = _createFetchClientSecretFunction();

    // Build options object using JSObject
    final options = JSObject();
    options['publishableKey'] = publishableKey.toJS;
    options['fetchClientSecret'] = fetchClientSecretJS;

    // Build appearance options if provided
    if (appearance != null) {
      final variables = JSObject();
      if (appearance.fontFamily != null) {
        variables['fontFamily'] = appearance.fontFamily!.toJS;
      }
      if (appearance.colors?.primary != null) {
        variables['colorPrimary'] = appearance.colors!.primary!.toJS;
      }
      if (appearance.colors?.background != null) {
        variables['colorBackground'] = appearance.colors!.background!.toJS;
      }
      if (appearance.colors?.text != null) {
        variables['colorText'] = appearance.colors!.text!.toJS;
      }
      if (appearance.colors?.secondaryText != null) {
        variables['colorSecondaryText'] =
            appearance.colors!.secondaryText!.toJS;
      }
      if (appearance.colors?.border != null) {
        variables['colorBorder'] = appearance.colors!.border!.toJS;
      }
      if (appearance.cornerRadius != null) {
        variables['borderRadius'] = appearance.cornerRadius!.toString().toJS;
      }

      final appearanceObj = JSObject();
      appearanceObj['overlays'] = 'dialog'.toJS;
      appearanceObj['variables'] = variables;
      options['appearance'] = appearanceObj;
    }

    // Initialize Connect.js
    _connectInstance = stripeConnectGlobal!.init(options);
    _isInitialized = true;
    debugPrint('StripeConnectWeb: Initialized successfully');
  }

  /// Create a JS function that returns a Promise for fetching client secret
  JSFunction _createFetchClientSecretFunction() {
    // fetchClientSecret must be a function that takes NO arguments and returns a Promise<string>
    return (() {
      return _fetchClientSecretAsync().then((secret) {
        if (secret != null) {
          return secret.toJS;
        } else {
          throw Exception('Failed to fetch client secret');
        }
      }).toJS;
    }).toJS;
  }

  Future<String?> _fetchClientSecretAsync() async {
    if (_clientSecretProvider == null) {
      return null;
    }
    try {
      return await _clientSecretProvider!();
    } catch (e) {
      debugPrint('StripeConnectWeb: Error fetching client secret: $e');
      return null;
    }
  }

  /// Wait for Connect.js script to load
  Future<void> _waitForConnectJs() async {
    if (isLoaded) return;

    _initCompleter = Completer<void>();

    // Check if script is already in the document
    final existingScript = web.document.querySelector(
      'script[src*="connect-js.stripe.com"]',
    );

    if (existingScript == null) {
      // Add the script dynamically
      final script =
          web.document.createElement('script') as web.HTMLScriptElement;
      script.src = 'https://connect-js.stripe.com/v1.0/connect.js';
      script.async = true;
      web.document.head?.appendChild(script);
    }

    // Wait for StripeConnect to be available
    for (int i = 0; i < 100; i++) {
      if (isLoaded) {
        _initCompleter?.complete();
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _initCompleter?.completeError(
      Exception(
          'Connect.js failed to load. Please add the script to your index.html'),
    );
    throw Exception('Connect.js failed to load');
  }

  /// Create a Connect component element
  web.HTMLElement? createComponent(String componentType) {
    if (!_isInitialized || _connectInstance == null) {
      debugPrint('StripeConnectWeb: Not initialized. Call initialize() first.');
      return null;
    }

    try {
      // Map Flutter component type to Connect.js component name
      final componentName = _mapComponentName(componentType);
      debugPrint('StripeConnectWeb: Creating component: $componentName');
      return _connectInstance!.create(componentName);
    } catch (e) {
      debugPrint('StripeConnectWeb: Error creating component: $e');
      return null;
    }
  }

  /// Map Flutter component type to Connect.js component name
  String _mapComponentName(String flutterType) {
    switch (flutterType) {
      case 'stripe_account_onboarding':
        return 'account-onboarding';
      case 'stripe_account_management':
        return 'account-management';
      case 'stripe_payments':
        return 'payments';
      case 'stripe_payouts':
        return 'payouts';
      case 'stripe_notification_banner':
        return 'notification-banner';
      case 'stripe_balances':
        return 'balances';
      case 'stripe_documents':
        return 'documents';
      case 'stripe_tax_settings':
        return 'tax-settings';
      case 'stripe_tax_registrations':
        return 'tax-registrations';
      case 'stripe_payouts_list':
        return 'payouts-list';
      case 'stripe_payment_details':
        return 'payment-details';
      case 'stripe_payout_details':
        return 'payout-details';
      case 'stripe_disputes_list':
        return 'disputes-list';
      default:
        return flutterType;
    }
  }

  /// Update appearance
  void updateAppearance(ConnectAppearance appearance) {
    if (!_isInitialized || _connectInstance == null) return;

    final variables = JSObject();
    if (appearance.fontFamily != null) {
      variables['fontFamily'] = appearance.fontFamily!.toJS;
    }
    if (appearance.colors?.primary != null) {
      variables['colorPrimary'] = appearance.colors!.primary!.toJS;
    }
    if (appearance.colors?.background != null) {
      variables['colorBackground'] = appearance.colors!.background!.toJS;
    }
    if (appearance.colors?.text != null) {
      variables['colorText'] = appearance.colors!.text!.toJS;
    }
    if (appearance.colors?.secondaryText != null) {
      variables['colorSecondaryText'] = appearance.colors!.secondaryText!.toJS;
    }
    if (appearance.colors?.border != null) {
      variables['colorBorder'] = appearance.colors!.border!.toJS;
    }
    if (appearance.cornerRadius != null) {
      variables['borderRadius'] = appearance.cornerRadius!.toString().toJS;
    }

    final appearanceObj = JSObject();
    appearanceObj['variables'] = variables;

    final options = JSObject();
    options['appearance'] = appearanceObj;

    _connectInstance!.update(options);
  }

  /// Logout and clear session
  void logout() {
    if (_connectInstance != null) {
      _connectInstance!.logout();
    }
    _connectInstance = null;
    _isInitialized = false;
  }
}
