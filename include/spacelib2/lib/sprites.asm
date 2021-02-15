.filenamespace sl

.namespace sprites {
    .label max_sprites = 8

    .label sprite_width = 24
    .label sprite_height = 21

    .print "animation data stored at " + toHexString(*)
    anim_start_frame:   .fill max_sprites, 0
    anim_end_frame:     .fill max_sprites, 0
    anim_current_frame: .fill max_sprites, 0
    anim_delay:         .fill max_sprites, 0
    anim_timer:         .fill max_sprites, 0
    anim_loop:          .fill max_sprites, 0
    anim_enabled:       .fill max_sprites, 0

    .macro check_sprite_id(id) {
        // ensure id is in range
        .if (id < 0 || id >= max_sprites) {
            .error("sprite id " + id + " out of range.")
            .error("sprite ids must be between 0 and " + (max_sprites - 1))
        }
    }

    .macro @sl_sprite_enable_all(enabled) {
        .if (enabled) {
            lda #$ff
        } else {
            lda #0
        }
        sta sprite_enable
    }

    .macro @sl_sprite_enable(id, enabled) {
        check_sprite_id(id)

        lda sprite_enable
        .if (enabled) {
            ora #1 << id
        } else {
            and #~(1 << id)
        }
        sta sprite_enable
    }

    .macro @sl_sprite_multicolour_enable_all(enabled) {
        .if (enabled) {
            lda #$ff
        } else {
            lda #0
        }
        sta sprite_multicolour_enable
    }

    .macro @sl_sprite_multicolour_enable(id, enabled) {
        check_sprite_id(id)

        lda sprite_multicolour_enable
        .if (enabled) {
            ora #1 << id
        } else {
            and #~(1 << id)
        }
        sta sprite_multicolour_enable
    }

    .macro @sl_sprite_multicolour_set_colours(colour1, colour2) {
        lda #colour1
        sta sprite_multicolour_0
        lda #colour2
        sta sprite_multicolour_1
    }

    .macro @sl_sprite_set_position_vvv(id, x, y) {
        check_sprite_id(id)

        // [un]set high x of relevant sprite
        lda sprite_x_msb
        .if (x >= 256) {
            ora #1 << id
        } else {
            and #~(1 << id)
        }
        sta sprite_x_msb

        // set low x & y of relevant sprite
        lda #<x
        sta sprite_0_x+(id * 2)
        lda #y
        sta sprite_0_y+(id * 2)
    }

    .macro @sl_sprite_set_position_vaa(id, x_addr, y_addr) {
        check_sprite_id(id)

        // [un]set high x of relevant sprite
        lda sprite_x_msb    // unset bit
        and #~(1 << id)
        sta sprite_x_msb
        lda x_addr + 1
        beq !+              // skip if high byte is 0
        lda sprite_x_msb    // set bit
        ora #1 << id
        sta sprite_x_msb

        // set low x & y of relevant sprite
    !:  mov x_addr : sprite_0_x+(id * 2)
        mov y_addr : sprite_0_y+(id * 2)
    }

    .macro @sl_sprite_set_colour(id, colour) {
        check_sprite_id(id)

        lda #colour
        sta sprite_0_colour+(id)
    }

    .macro @sl_sprite_anim_set_frame(id, frame) {
        check_sprite_id(id)

        sl_sprite_anim_stop(id)

        lda #sprites_data_pointer + frame
        sta sprite_pointer_0+(id)
    }

    .macro @sl_sprite_anim_start(id, frame_count, start_frame, delay, loop) {
        check_sprite_id(id)

        mov #(start_frame + frame_count) : anim_end_frame+(id)
        mov #start_frame : anim_start_frame+(id)
        mov #start_frame : anim_current_frame+(id)
        mov #delay : anim_delay+(id)
        mov #delay : anim_timer+(id)

        .if (loop) {
            mov #1 : anim_loop+(id)
        } else {
            mov #0 : anim_loop+(id)
        }

        mov #1 : anim_enabled+(id)

        lda #sprites_data_pointer + start_frame
        sta sprite_pointer_0+(id)
    }

    .macro @sl_sprite_anim_stop(id) {
        check_sprite_id(id)

        mov #0 : anim_enabled+(id)
    }

    .macro @sl_sprite_anim_update() {
        ldx #max_sprites - 1
        loop:
            lda anim_enabled, x
            beq next    // skip sprite if animation is not enabled

            dec anim_timer, x
            bne next    // skip unless delay timer hits 0

            // reset delay timer
            mov anim_delay, x : anim_timer, x

            // set sprite pointer for current animation frame
            clc
            lda #sprites_data_pointer
            adc anim_current_frame, x
            sta sprite_pointer_0, x

            // advance/loop animation frame
            inc anim_current_frame, x
            lda anim_current_frame, x
            cmp anim_end_frame, x
            bne next
            mov anim_start_frame, x : anim_current_frame, x

            next: dex; bpl loop
    }
}
