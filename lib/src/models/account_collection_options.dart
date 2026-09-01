/// Which set of requirements account onboarding asks the connected account for.
///
/// See https://docs.stripe.com/connect/supported-embedded-components/account-onboarding#requirement-collection-options
enum AccountFieldOption {
  /// Only the requirements that are due right now.
  currentlyDue('currently_due'),

  /// Everything that will eventually be due, pulled forward into this session.
  ///
  /// This collects `eventually_due` and `currently_due` requirements both.
  eventuallyDue('eventually_due');

  const AccountFieldOption(this.value);

  /// The value Stripe expects.
  final String value;
}

/// Whether account onboarding also collects
/// [future requirements](https://docs.stripe.com/connect/handle-verification-updates).
enum AccountFutureRequirementOption {
  /// Leave future requirements for a later session.
  omit('omit'),

  /// Collect future requirements now.
  include('include');

  const AccountFutureRequirementOption(this.value);

  /// The value Stripe expects.
  final String value;
}

/// The requirements account onboarding collects.
///
/// Currently due requirements are always collected. These options ask for more
/// on top of them, which is how you get fields Stripe would otherwise defer —
/// a date of birth or the last four digits of a social security number, say,
/// which for a US individual are only due once the account approaches its
/// first payouts.
///
/// ```dart
/// await StripeConnect.presentAccountOnboarding(
///   collectionOptions: const AccountCollectionOptions(
///     fields: AccountFieldOption.eventuallyDue,
///     futureRequirements: AccountFutureRequirementOption.include,
///   ),
/// );
/// ```
///
/// Collecting more than is currently due is subject to Stripe's policy
/// instructions — see
/// https://docs.stripe.com/connect/supported-embedded-components/account-onboarding#requirement-collection-options
class AccountCollectionOptions {
  const AccountCollectionOptions({
    this.fields = AccountFieldOption.currentlyDue,
    this.futureRequirements = AccountFutureRequirementOption.omit,
  });

  /// Whether to collect `currently_due` or `eventually_due` requirements.
  final AccountFieldOption fields;

  /// Whether to also collect future requirements.
  final AccountFutureRequirementOption futureRequirements;

  Map<String, dynamic> toMap() => {
        'fields': fields.value,
        'futureRequirements': futureRequirements.value,
      };
}
