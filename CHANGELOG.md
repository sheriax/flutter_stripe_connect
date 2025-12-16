# Changelog

## 0.3.3

* **Native SDK Always Initialized** - Native SDK (`EmbeddedComponentManager`) now initializes regardless of `webViewConfig`
  - Fixes "EmbeddedComponentManager not initialized" error when using native components with `webViewConfig`
  - Users can now freely mix native and WebView components in the same app
  - No breaking changes - existing code continues to work

## 0.3.2

* **Customizable WebView URL Parameters** - New `publishableKeyParam` and `clientSecretParam` options in `WebViewConfig`
  - Allows customizing URL query parameter names for hosted web apps
  - Defaults to `publishableKey` and `clientSecret` for backward compatibility
  - Example: Use `pk` and `secret` if your web app expects different parameter names
* **Example App Improvements** - Migrated to `go_router` for web-friendly URL routing
  - Routes now match the Next.js paths documented in `WEBVIEW_INTEGRATION.md`
  - Supports direct navigation to `/onboarding`, `/payments`, `/payouts`, etc.


## 0.3.1

* **Android Account Management Fix** - Removed `AccountManagementListener` which doesn't exist in the Android Stripe Connect SDK
  - Account Management component now shows a helpful error on Android
  - Use WebView mode or iOS for Account Management on mobile
* **New `StripeConnectViewType` Enum** - Type-safe component type identifiers
  - Replaces raw strings for component types in web components
  - All 13 Stripe Connect component types now available as enum values
  - Better IDE autocomplete and compile-time safety
* **Platform Availability Clarification**
  - Account Management: iOS ✅, Android ❌ (WebView required), Web ✅
  - Updated component to show clear error message on Android

## 0.3.0

* **Programmatic Account Onboarding** - New `StripeConnect.presentAccountOnboarding()` static method
  - Trigger onboarding flow from your own UI without embedding the widget
  - Supports `onExit` and `onLoadError` callbacks
  - Works on both iOS and Android (Web should use widget)
* **iOS Native Improvements**
  - Added `presentAccountOnboarding` method handler
  - Plugin now conforms to `AccountOnboardingControllerDelegate`
* **Android Native Improvements**
  - Normalized method name from `showAccountOnboarding` to `presentAccountOnboarding`
  - Added `onDismissListener` for exit callback support

## 0.2.3

* **Native vs WebView Control** - Added `useWebView` prop to components with native SDK support
  - `StripeAccountOnboarding`, `StripePayments`, `StripePayouts` now use native SDK by default
  - Set `useWebView: true` to force WebView rendering (requires `webViewConfig`)
* **Web-only Components** - Components without native SDK support now require WebView on mobile
  - `StripeAccountManagement`, `StripeNotificationBanner`, `StripeBalances`, `StripeDocuments`
  - `StripePayoutsList`, `StripePaymentDetails`, `StripePayoutDetails`, `StripeDisputesList`
  - These components show a helpful error if `webViewConfig` is not configured on mobile
* **Documentation** - Reorganized documentation into `doc/` folder
  - `doc/AUTHENTICATION.md` - Authentication flow documentation
  - `doc/WEBVIEW_INTEGRATION.md` - WebView mode setup guide
  - `doc/RESEARCH.md` - SDK research notes
* Updated component platform availability documentation

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
