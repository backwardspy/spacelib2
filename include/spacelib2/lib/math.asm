.filenamespace sl

.namespace math {
    /*
     * converts the byte at `input_address` to BCD and stores the resulting two
     * bytes at `output_address`
     * 
     * trashes:
     * - AC
     * - XR
     * - zp_param_8
     */
    .macro @sl_math_bcd_byte(input_address, output_address) {
        .var output_lo = output_address+(0)
        .var output_hi = output_address+(1)

        // zero the output
        lda #0
        sta output_lo
        sta output_hi

        // set up for loop
        lda input_address
        sta zp_param_8
        ldx #8  // number of bits to shift

        // switch to decimal mode
        sed

        // converting binary to decimal
        // beginning with a total of 0:
        //   shift off a bit, starting from most significant
        //   double total
        //   add bit to total
        // rinse & repeat until all bits are gone
        loop:
            asl zp_param_8
            // double low digits + carry
            lda output_lo
            adc output_lo
            sta output_lo
            // double high digits + carry
            lda output_hi
            adc output_hi
            sta output_hi
            // loop until XR = 0
            dex
            bne loop
        
        // switch to binary mode
        cld
    }

    /*
     * converts the word at `input_address` to BCD and stores the resulting three
     * bytes at `output_address`
     * 
     * trashes:
     * - AC
     * - XR
     * - zp_param_7
     * - zp_param_8
     */
    .macro @sl_math_bcd_word(input_address, output_address) {
        .var output_0 = output_address+(0)
        .var output_1 = output_address+(1)
        .var output_2 = output_address+(2)

        // zero the output
        lda #0
        sta output_0
        sta output_1
        sta output_2

        // set up for loop
        lda input_address+(0)
        sta zp_param_7
        lda input_address+(1)
        sta zp_param_8
        ldx #16  // number of bits to shift

        // switch to decimal mode
        sed

        // see sl_math_bcd_byte for comment on this algorithm
        loop:
            // shift low byte into carry
            asl zp_param_7
            // rotate carry into high byte
            rol zp_param_8
            // double low digits + carry
            lda output_0
            adc output_0
            sta output_0
            // double high digits + carry
            lda output_1
            adc output_1
            sta output_1
            // double high digits + carry
            lda output_2
            adc output_2
            sta output_2
            // loop until XR = 0
            dex
            bne loop
        
        // switch to binary mode
        cld
    }

    .macro @sl_math_min(value1_addr, value2) {
        lda #value2
        cmp value1_addr
        bcs end         // carry set = no borrow = value2 >= value1
        sta value1_addr // carry clear = borrow = value2 < value1
    end:
    }

    .macro @sl_math_max(value1_addr, value2) {
        lda #value2
        cmp value1_addr
        bcc end         // carry clear = borrow = value2 < value1
        sta value1_addr // carry set = no borrow = value >= value1
    end:
    }

    .macro @sl_math_min16(value1_addr, value2) {
        // compare high bytes
        lda value1_addr + 1
        cmp #>value2
        bmi end         // hi(value2) > hi(value1), value1 must be lower

        mov #>value2 : value1_addr + 1

        sl_math_min(value1_addr, <value2)
    end:
    }

    .macro @sl_math_max16(value1_addr, value2) {
        lda #>value2
        cmp value1_addr + 1
        bcc end         // hi(value2) < hi(value1), value1 must be greater
        sta value1_addr + 1

        sl_math_max(value1_addr, <value2)
    end:
    }

    .macro @sl_math_clamp(value1_addr, minimum, maximum) {
        @sl_math_min(value1_addr, maximum)
        @sl_math_max(value1_addr, minimum)
    }

    .macro @sl_math_clamp16(value1_addr, minimum, maximum) {
        @sl_math_min16(value1_addr, maximum)
        @sl_math_max16(value1_addr, minimum)
    }
}
