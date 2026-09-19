package com.sheriax.flutter_stripe_connect

import com.stripe.android.connect.AccountOnboardingProps
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Covers the decoder for the arguments `presentAccountOnboarding` and the
 * platform view send over the method channel.
 */
internal class AccountOnboardingPropsTest {

    @Test
    fun `decodes the terms and privacy arguments`() {
        val props = accountOnboardingProps(
            mapOf(
                "fullTermsOfServiceUrl" to "https://example.com/terms",
                "recipientTermsOfServiceUrl" to "https://example.com/recipient",
                "privacyPolicyUrl" to "https://example.com/privacy",
                "skipTermsOfServiceCollection" to true,
            )
        )

        assertEquals("https://example.com/terms", props.fullTermsOfServiceUrl)
        assertEquals("https://example.com/recipient", props.recipientTermsOfServiceUrl)
        assertEquals("https://example.com/privacy", props.privacyPolicyUrl)
        assertEquals(true, props.skipTermsOfServiceCollection)
    }

    @Test
    fun `leaves the arguments unset when nothing was sent`() {
        val props = accountOnboardingProps(null)

        assertNull(props.fullTermsOfServiceUrl)
        assertNull(props.recipientTermsOfServiceUrl)
        assertNull(props.privacyPolicyUrl)
        assertNull(props.skipTermsOfServiceCollection)
        assertNull(props.collectionOptions)
    }

    @Test
    fun `ignores arguments of the wrong type`() {
        val props = accountOnboardingProps(
            mapOf(
                "fullTermsOfServiceUrl" to 42,
                "skipTermsOfServiceCollection" to "true",
            )
        )

        assertNull(props.fullTermsOfServiceUrl)
        assertNull(props.skipTermsOfServiceCollection)
    }

    @Test
    fun `decodes the field option Stripe expects`() {
        assertEquals(
            AccountOnboardingProps.FieldOption.CURRENTLY_DUE,
            collectionOptions("fields" to "currently_due").fields,
        )
        assertEquals(
            AccountOnboardingProps.FieldOption.EVENTUALLY_DUE,
            collectionOptions("fields" to "eventually_due").fields,
        )
    }

    @Test
    fun `decodes the future requirement option Stripe expects`() {
        assertEquals(
            AccountOnboardingProps.FutureRequirementOption.OMIT,
            collectionOptions("futureRequirements" to "omit").futureRequirements,
        )
        assertEquals(
            AccountOnboardingProps.FutureRequirementOption.INCLUDE,
            collectionOptions("futureRequirements" to "include").futureRequirements,
        )
    }

    @Test
    fun `leaves an option unset when its value is not one Stripe knows`() {
        val options = collectionOptions(
            "fields" to "all_of_them",
            "futureRequirements" to true,
        )

        assertNull(options.fields)
        assertNull(options.futureRequirements)
    }

    @Test
    fun `carries the collection options through onto the props`() {
        val props = accountOnboardingProps(
            mapOf("collectionOptions" to mapOf("fields" to "eventually_due"))
        )

        assertEquals(
            AccountOnboardingProps.FieldOption.EVENTUALLY_DUE,
            props.collectionOptions?.fields,
        )
    }

    @Test
    fun `returns no collection options when none were sent`() {
        assertNull(accountCollectionOptions(emptyMap<String, Any?>()))
        assertNull(accountCollectionOptions(mapOf("collectionOptions" to "not a map")))
    }

    @Test
    fun `returns collection options even when every value was unreadable`() {
        // An empty CollectionOptions is not the same as none: the host app did
        // ask for the component to take collection options, so the SDK gets an
        // object rather than a null it would read as "never configured".
        assertTrue(
            accountCollectionOptions(mapOf("collectionOptions" to emptyMap<String, Any?>()))
                is AccountOnboardingProps.CollectionOptions
        )
    }

    private fun collectionOptions(
        vararg entries: Pair<String, Any?>,
    ): AccountOnboardingProps.CollectionOptions =
        accountCollectionOptions(mapOf("collectionOptions" to mapOf(*entries)))!!
}
