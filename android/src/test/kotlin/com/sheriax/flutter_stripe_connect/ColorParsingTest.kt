package com.sheriax.flutter_stripe_connect

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

/**
 * Covers [parseColor], which has to agree with the iOS parser about which hex
 * notations the host app may use.
 */
internal class ColorParsingTest {

    @Test
    fun `parses six digit hex`() {
        assertEquals(0xFF635BFF.toInt(), parseColor("#635BFF"))
    }

    @Test
    fun `expands three digit hex`() {
        assertEquals(0xFFFFFFFF.toInt(), parseColor("#FFF"))
        assertEquals(0xFF1122AA.toInt(), parseColor("#12A"))
    }

    @Test
    fun `is case insensitive`() {
        assertEquals(parseColor("#635BFF"), parseColor("#635bff"))
    }

    @Test
    fun `always sets the alpha channel to opaque`() {
        assertEquals(0xFF000000.toInt(), parseColor("#000000"))
    }

    @Test
    fun `trims surrounding whitespace`() {
        assertEquals(0xFF635BFF.toInt(), parseColor("  #635BFF \n"))
    }

    @Test
    fun `rejects a value without the hash prefix`() {
        assertNull(parseColor("635BFF"))
    }

    @Test
    fun `rejects the alpha notations, which the platforms read differently`() {
        assertNull(parseColor("#635BFF80"))
        assertNull(parseColor("#80635BFF"))
    }

    @Test
    fun `rejects lengths it cannot read`() {
        assertNull(parseColor("#"))
        assertNull(parseColor("#12"))
        assertNull(parseColor("#12345"))
    }

    @Test
    fun `rejects non hex digits`() {
        assertNull(parseColor("#GGGGGG"))
        assertNull(parseColor("#12 45 6"))
    }

    @Test
    fun `rejects anything that is not a string`() {
        assertNull(parseColor(null))
        assertNull(parseColor(0xFF635BFF))
        assertNull(parseColor(listOf("#635BFF")))
    }
}
