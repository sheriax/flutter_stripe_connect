# Changelog

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
