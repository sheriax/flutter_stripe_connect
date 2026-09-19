package com.sheriax.flutter_stripe_connect

import com.stripe.android.connect.appearance.Appearance
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * Covers the appearance decoder that sits between the method channel and the
 * SDK's [Appearance].
 *
 * The SDK exposes what it holds through `internal` getters, so the assertions
 * read the backing fields. That couples the test to field names rather than to
 * a public API, but the alternative — asserting on `toString()` — is no looser
 * and far harder to read when it fails.
 *
 * An [Appearance] always carries its sub-objects; "unset" means a null leaf
 * inside one, never a null `colors` or `form`. The assertions below are
 * written that way on purpose.
 */
internal class AppearanceDecodingTest {

    @Test
    fun `returns null when no appearance was sent`() {
        assertNull(connectAppearance(null))
    }

    @Test
    fun `leaves everything unset for an empty map`() {
        val appearance = connectAppearance(emptyMap<String, Any?>())!!

        assertNull(appearance.field("colors")!!.field("primary"))
        assertNull(appearance.field("cornerRadius")!!.field("base"))
        assertNull(appearance.field("typography")!!.field("fontFamily"))
    }

    @Test
    fun `decodes the colors that stayed on Colors`() {
        val appearance = connectAppearance(
            mapOf(
                "colors" to mapOf(
                    "primary" to "#635BFF",
                    "background" to "#FFFFFF",
                    "text" to "#1A1A1A",
                    "secondaryText" to "#717171",
                    "border" to "#D7D7D7",
                )
            )
        )!!

        val colors = appearance.field("colors")!!
        assertEquals(0xFF635BFF.toInt(), colors.field("primary"))
        assertEquals(0xFFFFFFFF.toInt(), colors.field("background"))
        assertEquals(0xFF1A1A1A.toInt(), colors.field("text"))
        assertEquals(0xFF717171.toInt(), colors.field("secondaryText"))
        assertEquals(0xFFD7D7D7.toInt(), colors.field("border"))
    }

    @Test
    fun `routes the action colors through Action`() {
        val appearance = connectAppearance(
            mapOf(
                "colors" to mapOf(
                    "actionPrimaryText" to "#0074D4",
                    "actionSecondaryText" to "#444444",
                )
            )
        )!!

        assertEquals(
            0xFF0074D4.toInt(),
            appearance.field("actionPrimaryText")!!.field("colorText"),
        )
        assertEquals(
            0xFF444444.toInt(),
            appearance.field("actionSecondaryText")!!.field("colorText"),
        )
    }

    @Test
    fun `routes the form colors through Form`() {
        val appearance = connectAppearance(
            mapOf(
                "colors" to mapOf(
                    "formBackground" to "#FFFFFF",
                    "formHighlightBorder" to "#D7D7D7",
                )
            )
        )!!

        val form = appearance.field("form")!!
        assertEquals(0xFFFFFFFF.toInt(), form.field("colorBackground"))
        assertEquals(0xFFD7D7D7.toInt(), form.field("highlightBorder"))
    }

    @Test
    fun `sets one form color without disturbing the other`() {
        val appearance = connectAppearance(
            mapOf("colors" to mapOf("formBackground" to "#FFFFFF"))
        )!!

        val form = appearance.field("form")!!
        assertEquals(0xFFFFFFFF.toInt(), form.field("colorBackground"))
        assertNull(form.field("highlightBorder"))
    }

    @Test
    fun `leaves the action and form colors null when none were sent`() {
        val appearance = connectAppearance(
            mapOf("colors" to mapOf("primary" to "#635BFF"))
        )!!

        assertNull(appearance.field("actionPrimaryText")!!.field("colorText"))
        assertNull(appearance.field("actionSecondaryText")!!.field("colorText"))
        assertNull(appearance.field("form")!!.field("colorBackground"))
        assertNull(appearance.field("form")!!.field("highlightBorder"))
    }

    @Test
    fun `decodes the corner radius as the base radius`() {
        val appearance = connectAppearance(mapOf("cornerRadius" to 12.0))!!

        assertEquals(12.0f, appearance.field("cornerRadius")!!.field("base"))
    }

    @Test
    fun `decodes an integer corner radius too`() {
        val appearance = connectAppearance(mapOf("cornerRadius" to 8))!!

        assertEquals(8.0f, appearance.field("cornerRadius")!!.field("base"))
    }

    @Test
    fun `decodes the font family`() {
        val appearance = connectAppearance(mapOf("fontFamily" to "Roboto"))!!

        assertEquals("Roboto", appearance.field("typography")!!.field("fontFamily"))
    }

    @Test
    fun `ignores values of the wrong type`() {
        val appearance = connectAppearance(
            mapOf(
                "colors" to "not a map",
                "cornerRadius" to "12",
                "fontFamily" to 12,
            )
        )!!

        assertNull(appearance.field("colors")!!.field("primary"))
        assertNull(appearance.field("cornerRadius")!!.field("base"))
        assertNull(appearance.field("typography")!!.field("fontFamily"))
    }

    private fun Any.field(name: String): Any? =
        javaClass.getDeclaredField(name).apply { isAccessible = true }.get(this)
}
