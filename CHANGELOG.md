# Changelog

## 0.2.2

* Fixed CocoaPods dependency conflict issues
* Simplified podspec dependency logic

## 0.2.1

* Documentation cleanup - replaced example branding with generic placeholders
* Updated WebView integration guide examples

## 0.2.0

* **WebView Mode** - Added optional WebView-based rendering for all components
  - New `WebViewConfig` class to configure self-hosted web app URL
  - Pass `webViewConfig` to `StripeConnect.initialize()` to enable
  - All 13 components automatically switch to WebView when configured
* **Tax & Capital on Mobile** - Components previously web-only now work on iOS/Android via WebView mode
  - `StripeTaxSettings`, `StripeTaxRegistrations` auto-fallback to WebView
* **New exports**: `StripeConnectWebView`, `StripeConnectPaths`, `WebViewConfig`
* Added `webview_flutter` dependency for WebView support
* See `STRIPE_CONNECT_WEBVIEW_INTEGRATION.md` for hosting your own Stripe Connect web app

## 0.1.0

* **Web Platform Support** - Added full web platform support using Stripe Connect.js
* Added new embedded components:
  - `StripeNotificationBanner` - Show required actions for compliance
  - `StripeBalances` - Display balance information and payout controls
  - `StripeDocuments` - Show documents available for download
  - `StripeTaxSettings` - Configure tax settings (Web only)
  - `StripeTaxRegistrations` - Manage tax registrations (Web only)
  - `StripePayoutsList` - Filterable list of payouts
  - `StripePaymentDetails` - Payment detail overlay
  - `StripePayoutDetails` - Payout detail overlay
  - `StripeDisputesList` - View and manage disputes
* Added `appearance` parameter to `StripeConnect.initialize()` for web
* Updated documentation with comprehensive platform support matrix

## 0.0.2

* Fixed issue with Android platform.

## 0.0.1

* Initial release
* Added `StripeAccountOnboarding` widget for connected account onboarding
* Added `StripeAccountManagement` widget for account settings management
* Added `StripePayouts` widget for viewing payout history
* Added `StripePayments` widget for viewing payment history
* Added `ConnectAppearance` for UI customization
* Android and iOS platform support
