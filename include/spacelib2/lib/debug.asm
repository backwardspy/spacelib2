.filenamespace sl

.namespace debug {
    /*
     * outputs the text at `text_address` to screen memory at (row, column)
     * given text must be null-terminated
     *
     * trashes:
     * - AC
     * - XR
     */
    .macro @sl_debug_print(row, column, text_address) {
        .var addr = screen_base + row * sl.gfx.grid_width + column
        ldx #$ff
        loop:
            inx
            lda text_address, x
            beq end
            sta addr, x
            jmp loop
        end:
    }

    /*
     * outputs the byte at `byte_address` to screen memory at (row, column)
     * the byte is displayed in decimal
     *
     * trashes:
     * - AC
     * - XR
     * - zp_param_0
     * - zp_param_1
     * - zp_param_8
     */
    .macro @sl_debug_print_byte(row, column, byte_address) {
        .var addr = screen_base + row * sl.gfx.grid_width + column

        // high digits in zp_param_1, low in zp_param_0
        sl_math_bcd_byte(byte_address, zp_param_0)

        lda zp_param_1
        and #$0f
        ora #$30
        sta addr+(0)

        lda zp_param_0
        .for (var i = 0; i < 4; i++) lsr
        ora #$30
        sta addr+(1)

        lda zp_param_0
        and #$0f
        ora #$30
        sta addr+(2)
    }

    /*
     * outputs the word at `word_address` to screen memory at (row, column)
     * the word is displayed in decimal
     *
     * trashes:
     * - AC
     * - XR
     * - zp_param_0
     * - zp_param_1
     * - zp_param_2
     * - zp_param_7
     * - zp_param_8
     */
    .macro @sl_debug_print_word(row, column, word_address) {
        .var addr = screen_base + row * sl.gfx.grid_width + column

        // digits in zp_param 2 thru 0
        sl_math_bcd_word(word_address, zp_param_0)

        lda zp_param_2
        and #$0f
        ora #$30
        sta addr+(0)

        lda zp_param_1
        .for (var i = 0; i < 4; i++) lsr
        ora #$30
        sta addr+(1)

        lda zp_param_1
        and #$0f
        ora #$30
        sta addr+(2)

        lda zp_param_0
        .for (var i = 0; i < 4; i++) lsr
        ora #$30
        sta addr+(3)

        lda zp_param_0
        and #$0f
        ora #$30
        sta addr+(4)
    }

    /*
     * outputs the byte at `byte_address` to screen memory at (row, column)
     * the byte is displayed in hexadecimal
     *
     * trashes:
     * - AC
     * - zp_param_0
     */
    .macro @sl_debug_print_byte_hex(row, column, byte_address) {
        .var addr = screen_base + row * sl.gfx.grid_width + column
        lda byte_address
        sta zp_param_0

        .for (var i = 0; i < 4; i++) lsr
        print_hex_digit(addr)

        lda zp_param_0
        and #$0f
        print_hex_digit(addr + 1)
    }

    /*
     * outputs the word at `word_address` to screen memory at (row, column)
     * the word is displayed in hexadecimal
     *
     * trashes:
     * - AC
     * - zp_param_0
     */
    .macro @sl_debug_print_word_hex(row, column, word_address) {
        sl_debug_print_byte_hex(row, column, word_address + 1)
        sl_debug_print_byte_hex(row, column + 2, word_address)
    }

    .macro print_hex_digit(screen_address) {
        cmp #10
        bcs as_hex  // carry set if >=

        adc #'0'
        jmp display

    as_hex:
        clc
        sbc #10 - 'a' - 1

    display:
        sta screen_address
    }

    /*
     * increments the border colour to start a new profiling region
     * be sure to use sl_debug_profile_end to reset the colour later
     */
    .macro @sl_debug_profile_start() {
        inc border_colour
    }

    /*
     * decrements the border colour to end a profiling region
     * only intended for use after sl_debug_profile_start
     */
    .macro @sl_debug_profile_end() {
        dec border_colour
    }

    /*
     * busy-waits for a count of `iterations` to create an artificial delay
     */
    .macro @sl_debug_delay(iterations) {
        ldx #iterations
        loop:
            dex
            bne loop
    }
}