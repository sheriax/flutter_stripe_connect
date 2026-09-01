# flutter_stripe_connect

A Flutter plugin for Stripe Connect embedded components. Easily integrate account onboarding, account management, payouts, payments, and more into your Flutter app.

[![pub package](https://img.shields.io/pub/v/flutter_stripe_connect.svg)](https://pub.dev/packages/flutter_stripe_connect)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- **Account Onboarding** - Collect connected account information with a pre-built UI
- **Account Management** - Let connected accounts manage their account settings
- **Payments** - Show payment history for connected accounts
- **Payouts** - Display payout history and status for connected accounts
- **Balances** - Show balance information and payout controls
- **Notification Banner** - Display required actions for compliance
- **Documents** - Show documents available for download
- **Tax Settings** - Allow connected accounts to configure tax settings
- **Tax Registrations** - Manage tax registrations
- **Disputes List** - View and manage disputes
- **Payment Details** - Show detailed payment information
- **Payout Details** - Show detailed payout information
- **Payouts List** - Filterable list of payouts
- **WebView Mode** - Optional self-hosted web rendering for full component access
- **Customizable Appearance** - Configure colors, fonts, and corner radius

## Platform Support

| Platform | Supported |
|:--------:|:---------:|
| Android  |     ✅     |
| iOS      |     ✅     |
| Web      |     ✅     |

### Component Availability by Platform

| Component | iOS Native | Android Native | Web | Mobile WebView |
|:----------|:----------:|:--------------:|:---:|:--------------:|
| Account Onboarding | ✅ | ✅ | ✅ | Optional |
| Payments | ✅ | ✅ | ✅ | Optional |
| Payouts | ✅ | ✅ | ✅ | Optional |
| Account Management | ✅ | ❌ | ✅ | Required on Android |
| Notification Banner | ❌ | ❌ | ✅ | Required |
| Balances | ❌ | ❌ | ✅ | Required |
| Documents | ❌ | ❌ | ✅ | Required |
| Tax Settings | ❌ | ❌ | ✅ | Required |
| Tax Registrations | ❌ | ❌ | ✅ | Required |
| Disputes List | ❌ | ❌ | ✅ | Required |
| Payment Details | ❌ | ❌ | ✅ | Required |
| Payout Details | ❌ | ❌ | ✅ | Required |
| Payouts List | ❌ | ❌ | ✅ | Required |

> **Legend:** 
> - ✅ Native SDK supported - uses platform-native component by default
> - ❌ No native SDK - requires WebView mode on mobile
> - **Optional**: Component supports both native and WebView (use `useWebView: true` to force WebView)
> - **Required**: Component requires `webViewConfig` to work on mobile
>
> See [doc/WEBVIEW_INTEGRATION.md](doc/WEBVIEW_INTEGRATION.md) for WebView mode setup.

## Installation

Add `flutter_stripe_connect` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_stripe_connect: ^0.3.7
```

## Platform Setup

### Android Setup

**Important**: Your `MainActivity` must extend `FlutterFragmentActivity` (not `FlutterActivity`) for the Stripe Connect components to work properly.

Update your `android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
package com.example.yourapp

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

### iOS Setup

**Important**: add `NSCameraUsageDescription` to your `ios/Runner/Info.plist`.
Embedded components capture identity documents with the camera, and the
StripeConnect SDK asserts on this key when the component manager is created —
without it a debug build stops there.

```xml
<key>NSCameraUsageDescription</key>
<string>This app uses your camera to take a photo of your identity documents.</string>
```

The plugin ships both a podspec and a `Package.swift`, so it works under
CocoaPods and under Swift Package Manager. Either way the app has to target
iOS 15.0 or later.

> **Troubleshooting**: If pod install fails on the first try, run:
> ```bash
> cd ios/
> pod install --repo-update
> ```

### Web Setup

Add the Connect.js script to your `web/index.html` inside the `<head>` tag:

```html
<script src="https://connect-js.stripe.com/v1.0/connect.js" async></script>
```

**CSP Requirements**: If you're using Content Security Policy headers, allow these Stripe domains:
- `https://connect-js.stripe.com`
- `https://js.stripe.com`

## Usage

### 1. Initialize the SDK

```dart
import 'package:flutter_stripe_connect/flutter_stripe_connect.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StripeConnect.instance.initialize(
    publishableKey: 'pk_test_...',
    clientSecretProvider: () async {
      // Fetch client secret from your server
      final response = await http.post(
        Uri.parse('https://your-server.com/create-account-session'),
      );
      return jsonDecode(response.body)['client_secret'];
    },
  );
  
  runApp(MyApp());
}
```

### 1b. Enable WebView Mode (Optional)

For full component access on mobile (including Tax, Capital, Issuing), use WebView mode:

```dart
await StripeConnect.instance.initialize(
  publishableKey: 'pk_test_...',
  clientSecretProvider: () async {
    final response = await http.post(
      Uri.parse('https://your-server.com/create-account-session'),
    );
    return jsonDecode(response.body)['client_secret'];
  },
  webViewConfig: WebViewConfig(
    baseUrl: 'https://connect.yourapp.com',  // Your hosted web app
    theme: 'light',
    primaryColor: '#635BFF',
    // Optional: Customize URL parameter names if your web app uses different names
    // publishableKeyParam: 'pk',      // defaults to 'publishableKey'
    // clientSecretParam: 'secret',    // defaults to 'clientSecret'
  ),
);
```

> **Note**: WebView mode requires hosting your own Next.js app. See [doc/WEBVIEW_INTEGRATION.md](doc/WEBVIEW_INTEGRATION.md) for setup guide.

### 2. Use the Embedded Components

#### Account Onboarding

**Option A: Embed as Widget**

```dart
StripeAccountOnboarding(
  onLoaded: () => print('Onboarding loaded'),
  onLoadError: (error) => print('Error: $error'),
  onExit: () => print('User exited onboarding'),
  // Uses native SDK by default on iOS/Android
  // Set useWebView: true to force WebView rendering
)
```

**Option B: Present Programmatically (New in 0.3.0)**

Trigger onboarding from your own UI without embedding the widget:

```dart
ElevatedButton(
  onPressed: () async {
    await StripeConnect.presentAccountOnboarding(
      onExit: () {
        print('User exited onboarding');
        // Navigate back or refresh state
      },
      onLoadError: (error) {
        print('Error: $error');
        // Show error dialog
      },
    );
  },
  child: Text('Start Onboarding'),
)
```

> **Note**: `presentAccountOnboarding()` is only supported on iOS and Android. On Web, use the `StripeAccountOnboarding` widget.

**Collecting more than what is currently due**

Onboarding always collects `currently_due` requirements. Anything Stripe defers
is left out — for a US individual, the date of birth and the last four digits
of the social security number are only due as the account approaches its first
payouts, so an onboarding run early in your flow never asks for them. Pass
`collectionOptions` to pull them forward:

```dart
await StripeConnect.presentAccountOnboarding(
  collectionOptions: const AccountCollectionOptions(
    fields: AccountFieldOption.eventuallyDue,
    futureRequirements: AccountFutureRequirementOption.include,
  ),
);
```

Collecting more than what is currently due is subject to Stripe's
[policy instructions](https://docs.stripe.com/connect/supported-embedded-components/account-onboarding#requirement-collection-options).

**Your own agreements, and your own title**

For connected accounts where your platform is responsible for collecting
requirements, you can put your own agreements in place of Stripe's links and
take terms acceptance through your own flow:

```dart
await StripeConnect.presentAccountOnboarding(
  title: context.l10n.onboardingTitle,
  fullTermsOfServiceUrl: 'https://example.com/terms',
  recipientTermsOfServiceUrl: 'https://example.com/recipient-terms',
  privacyPolicyUrl: 'https://example.com/privacy',
  skipTermsOfServiceCollection: true,
);
```

Both sets of options are also available on the `StripeAccountOnboarding`
widget. `title` applies to native platforms only — on web the component has no
title bar of its own.

#### Account Management

```dart
StripeAccountManagement(
  onLoaded: () => print('Account management loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Payments

```dart
StripePayments(
  onLoaded: () => print('Payments loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Payouts

```dart
StripePayouts(
  onLoaded: () => print('Payouts loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Balances

```dart
StripeBalances(
  onLoaded: () => print('Balances loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Tax Settings (Web Only)

```dart
StripeTaxSettings(
  onLoaded: () => print('Tax settings loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Disputes List

```dart
StripeDisputesList(
  onLoaded: () => print('Disputes loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

### 3. Customize Appearance (Optional)

Appearance belongs to the Stripe instance rather than to an individual
component, so it is set once at initialization and applies everywhere:

```dart
await StripeConnect.instance.initialize(
  publishableKey: 'pk_test_...',
  clientSecretProvider: fetchClientSecret,
  appearance: const ConnectAppearance(
    fontFamily: 'Roboto',
    cornerRadius: 12.0,
    colors: ConnectColors(
      primary: '#635BFF',
      background: '#FFFFFF',
      text: '#1A1A1A',
    ),
  ),
);
```

Restyle later — following the app's theme, for instance — with
`updateAppearance`, which also reaches the components already on screen:

```dart
await StripeConnect.instance.updateAppearance(
  const ConnectAppearance(colors: ConnectColors(background: '#111111')),
);
```

Colors are hex strings. On native platforms `#RGB` and `#RRGGBB` are accepted;
alpha is not, because CSS reads `#RRGGBBAA` while Android reads `#AARRGGBB`. A
`fontFamily` only renders if it resolves to a font the app already has — a
system font, or one it bundles and registers.

> **Note**: the `appearance` argument on the individual component widgets is
> not applied. Set it through `initialize` or `updateAppearance` instead.

## Server-Side Setup

To use Stripe Connect embedded components, you need to create an Account Session on your server. Here's an example using Node.js:

```javascript
const stripe = require('stripe')('sk_test_...');

app.post('/create-account-session', async (req, res) => {
  const accountSession = await stripe.accountSessions.create({
    account: 'acct_...', // Connected account ID
    components: {
      account_onboarding: { enabled: true },
      account_management: { enabled: true },
      payments: { 
        enabled: true,
        features: {
          refund_management: true,
          dispute_management: true,
          capture_payments: true,
        }
      },
      payouts: { 
        enabled: true,
        features: {
          instant_payouts: true,
          standard_payouts: true,
        }
      },
      balances: { enabled: true },
      tax_settings: { enabled: true },
      tax_registrations: { enabled: true },
      documents: { enabled: true },
      notification_banner: { enabled: true },
    },
  });
  
  res.json({ client_secret: accountSession.client_secret });
});
```

## Requirements

- Flutter SDK `>=3.10.0`
- Dart SDK `>=3.0.0 <4.0.0`
- Android: `minSdk 21`
- iOS: `iOS 15.0+`
- Web: Modern browsers (Chrome, Firefox, Safari, Edge)

## Documentation

- [WebView Integration Guide](doc/WEBVIEW_INTEGRATION.md) - How to set up WebView mode for full component access
- [Authentication Flow](doc/AUTHENTICATION.md) - Understanding the Stripe Connect authentication flow
- [SDK Research](doc/RESEARCH.md) - Technical research notes on the Stripe Connect SDKs

## License

MIT License - see [LICENSE](LICENSE) for details.

