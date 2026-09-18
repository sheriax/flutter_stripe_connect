import Flutter
import StripeConnect
import UIKit
import XCTest

@testable import flutter_stripe_connect

// Covers the decoders that sit between the method channel and the iOS SDK.
//
// Everything lives in this one file because it is the only source file the
// RunnerTests target references; adding another means editing the Xcode
// project by hand.
//
// Run with:
//   xcodebuild test -workspace example/ios/Runner.xcworkspace -scheme Runner \
//     -destination 'platform=iOS Simulator,name=iPhone 16'

// MARK: - Colors

class ColorParsingTests: XCTestCase {

    func testParsesSixDigitHex() {
        assertColor(AppearanceArguments.color("#635BFF"), 0x635BFF)
    }

    func testExpandsThreeDigitHex() {
        assertColor(AppearanceArguments.color("#FFF"), 0xFFFFFF)
        assertColor(AppearanceArguments.color("#12A"), 0x1122AA)
    }

    func testIsCaseInsensitive() {
        assertColor(AppearanceArguments.color("#635bff"), 0x635BFF)
    }

    func testIsOpaque() {
        var alpha: CGFloat = 0
        AppearanceArguments.color("#000000")?.getRed(nil, green: nil, blue: nil, alpha: &alpha)
        XCTAssertEqual(alpha, 1)
    }

    func testTrimsSurroundingWhitespace() {
        assertColor(AppearanceArguments.color("  #635BFF \n"), 0x635BFF)
    }

    func testRejectsAValueWithoutTheHashPrefix() {
        XCTAssertNil(AppearanceArguments.color("635BFF"))
    }

    func testRejectsTheAlphaNotations() {
        // CSS reads #RRGGBBAA and Android reads #AARRGGBB; neither is accepted
        // rather than guessing which one the host app meant.
        XCTAssertNil(AppearanceArguments.color("#635BFF80"))
        XCTAssertNil(AppearanceArguments.color("#80635BFF"))
    }

    func testRejectsLengthsItCannotRead() {
        XCTAssertNil(AppearanceArguments.color("#"))
        XCTAssertNil(AppearanceArguments.color("#12"))
        XCTAssertNil(AppearanceArguments.color("#12345"))
    }

    func testRejectsNonHexDigits() {
        XCTAssertNil(AppearanceArguments.color("#GGGGGG"))
        XCTAssertNil(AppearanceArguments.color("#12 45 6"))
    }

    func testRejectsAnythingThatIsNotAString() {
        XCTAssertNil(AppearanceArguments.color(nil))
        XCTAssertNil(AppearanceArguments.color(0x635BFF))
        XCTAssertNil(AppearanceArguments.color(["#635BFF"]))
    }

    private func assertColor(
        _ color: UIColor?,
        _ expected: UInt32,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard let color else {
            return XCTFail("expected a color, got nil", file: file, line: line)
        }

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        let actual = UInt32(round(red * 255)) << 16
            | UInt32(round(green * 255)) << 8
            | UInt32(round(blue * 255))
        XCTAssertEqual(
            String(actual, radix: 16),
            String(expected, radix: 16),
            file: file,
            line: line
        )
    }
}

// MARK: - Appearance

class AppearanceDecodingTests: XCTestCase {

    func testLeavesEverythingUnsetWhenNothingWasSent() {
        let appearance = AppearanceArguments.appearance(from: nil)

        XCTAssertNil(appearance.colors.primary)
        XCTAssertNil(appearance.cornerRadius.base)
        XCTAssertNil(appearance.typography.font)
    }

    func testDecodesEveryColorTheHostAppCanSet() {
        let appearance = AppearanceArguments.appearance(from: [
            "colors": [
                "primary": "#635BFF",
                "background": "#FFFFFF",
                "text": "#1A1A1A",
                "secondaryText": "#717171",
                "border": "#D7D7D7",
                "actionPrimaryText": "#0074D4",
                "actionSecondaryText": "#444444",
                "formBackground": "#FAFAFA",
                "formHighlightBorder": "#CCCCCC",
            ]
        ])

        XCTAssertNotNil(appearance.colors.primary)
        XCTAssertNotNil(appearance.colors.background)
        XCTAssertNotNil(appearance.colors.text)
        XCTAssertNotNil(appearance.colors.secondaryText)
        XCTAssertNotNil(appearance.colors.border)
        XCTAssertNotNil(appearance.colors.actionPrimaryText)
        XCTAssertNotNil(appearance.colors.actionSecondaryText)
        XCTAssertNotNil(appearance.colors.formBackground)
        XCTAssertNotNil(appearance.colors.formHighlightBorder)
    }

    func testPutsEachColorWhereItBelongs() {
        let appearance = AppearanceArguments.appearance(from: [
            "colors": ["primary": "#635BFF"]
        ])

        XCTAssertEqual(appearance.colors.primary, AppearanceArguments.color("#635BFF"))
        XCTAssertNil(appearance.colors.background)
    }

    func testDecodesTheCornerRadiusAsTheBaseRadius() {
        XCTAssertEqual(
            AppearanceArguments.appearance(from: ["cornerRadius": 12.0]).cornerRadius.base,
            12
        )
        XCTAssertEqual(
            AppearanceArguments.appearance(from: ["cornerRadius": 8]).cornerRadius.base,
            8
        )
    }

    func testDecodesAFontFamilyTheSystemResolves() {
        let appearance = AppearanceArguments.appearance(from: ["fontFamily": "Helvetica"])

        XCTAssertEqual(appearance.typography.font?.familyName, "Helvetica")
    }

    func testLeavesTheFontUnsetWhenTheFamilyDoesNotResolve() {
        // The SDK takes a UIFont, so a family UIKit cannot resolve — including
        // the generic CSS families Android and web accept — cannot be passed
        // on and the SDK falls back to -apple-system.
        XCTAssertNil(
            AppearanceArguments.appearance(from: ["fontFamily": "sans-serif"]).typography.font
        )
        XCTAssertNil(
            AppearanceArguments.appearance(from: ["fontFamily": "NotAFont"]).typography.font
        )
    }

    func testIgnoresValuesOfTheWrongType() {
        let appearance = AppearanceArguments.appearance(from: [
            "colors": "not a map",
            "cornerRadius": "12",
            "fontFamily": 12,
        ])

        XCTAssertNil(appearance.colors.primary)
        XCTAssertNil(appearance.cornerRadius.base)
        XCTAssertNil(appearance.typography.font)
    }
}

// MARK: - Account onboarding

class AccountOnboardingArgumentsTests: XCTestCase {

    func testDefaultsToWhatTheSdkDefaultsTo() {
        let options = AccountOnboardingArguments.collectionOptions(from: nil)

        XCTAssertEqual(options.fields, .currentlyDue)
        XCTAssertEqual(options.futureRequirements, .omit)
    }

    func testDecodesTheFieldOptionStripeExpects() {
        XCTAssertEqual(collectionOptions(["fields": "currently_due"]).fields, .currentlyDue)
        XCTAssertEqual(collectionOptions(["fields": "eventually_due"]).fields, .eventuallyDue)
    }

    func testDecodesTheFutureRequirementOptionStripeExpects() {
        XCTAssertEqual(collectionOptions(["futureRequirements": "omit"]).futureRequirements, .omit)
        XCTAssertEqual(
            collectionOptions(["futureRequirements": "include"]).futureRequirements,
            .include
        )
    }

    func testKeepsTheDefaultWhenAValueIsNotOneStripeKnows() {
        let options = collectionOptions([
            "fields": "all_of_them",
            "futureRequirements": true,
        ])

        XCTAssertEqual(options.fields, .currentlyDue)
        XCTAssertEqual(options.futureRequirements, .omit)
    }

    func testDecodesAUrl() {
        let args = ["privacyPolicyUrl": "https://example.com/privacy"]

        XCTAssertEqual(
            AccountOnboardingArguments.url(from: args, key: "privacyPolicyUrl"),
            URL(string: "https://example.com/privacy")
        )
    }

    func testReturnsNoUrlWhenTheKeyIsAbsentOrNotAString() {
        XCTAssertNil(AccountOnboardingArguments.url(from: nil, key: "privacyPolicyUrl"))
        XCTAssertNil(AccountOnboardingArguments.url(from: [:], key: "privacyPolicyUrl"))
        XCTAssertNil(AccountOnboardingArguments.url(from: ["privacyPolicyUrl": 42], key: "privacyPolicyUrl"))
    }

    private func collectionOptions(_ map: [String: Any]) -> AccountCollectionOptions {
        AccountOnboardingArguments.collectionOptions(from: ["collectionOptions": map])
    }
}
