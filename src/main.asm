.const trigger_line_1 = 100
.const trigger_line_2 = 135
.const trigger_line_3 = 170
.const trigger_line_4 = 205
.const trigger_line_5 = 240

// setting to true speeds up irq handling by disabling kernal & default handlers
.const quick_irq = true

.const sprite_colours = List().add(2, 3, 4, 6, 7, 8, 10, 14).lock()

.const anim_frame_count = 8
.const anim_delay = 4
.const anim_start_frames = List().add(0, 4, 3, 5, 7, 1, 2, 6).lock()

.macro set_sprite_positions(line) {
    .for (var i = 0; i < sl.sprites.max_sprites; i++) {
        // y position is slightly above the trigger line so we don't update
        // attributes half way through drawing
        sl_sprite_set_position(
            i,
            40 + i * (sl.sprites.sprite_width * 1.5),
            line - 20
        )
        sl_sprite_set_colour(i, sprite_colours.get(mod(line + i, 8)))
    }
}

.macro raster_irq_handler(next_line, next_handler) {
    sl_interrupts_irq_handler_begin(quick_irq)

    // sl_debug_profile_start()

    // set up next irq handler in chain
    sl_interrupts_raster_set_trigger_line(
        next_line,
        next_handler,
        quick_irq
    )

    set_sprite_positions(next_line)

    // sl_debug_profile_end()
    
    sl_interrupts_irq_handler_end(quick_irq)
}

entry_point:
    .if (quick_irq) {
        // yeet kernal & basic
        sl_bank_disable_kernal()
    }

    // set up first raster interrupt
    sl_interrupts_raster_init(trigger_line_1, raster_irq_1, quick_irq)

    // set colours & clear screen
    sl_gfx_set_border_colour(sl.gfx.grey)
    sl_gfx_set_background_colour(sl.gfx.black)
    sl_gfx_fill(colour_base, sl.gfx.light_green)
    sl_gfx_fill(screen_base, ' ')

    sl_debug_print(1, 3, str_irq_vector_0)
    sl_debug_print_word_hex(1, 3 + str_irq_vector_0_len, $fffe)

    sl_debug_print(2, 3, str_irq_vector_1)
    sl_debug_print_word_hex(2, 3 + str_irq_vector_1_len, $0314)

    // enable sprites
    sl_sprite_enable_all(true)
    sl_sprite_multicolour_enable_all(true)
    sl_sprite_multicolour_set_colours(sl.gfx.brown, sl.gfx.light_green)
    .for (var i = 0; i < sl.sprites.max_sprites; i++) {
        sl_sprite_set_pointer(i, sprites_data_pointer)
        sl_sprite_anim_start(i, anim_frame_count, anim_start_frames.get(i), anim_delay, true)
    }
    set_sprite_positions(trigger_line_1)

    main_loop:
        sl_gfx_wait_for_raster(250)
        sl_sprite_anim_update()
        jmp main_loop

raster_irq_1: raster_irq_handler(trigger_line_2, raster_irq_2)
raster_irq_2: raster_irq_handler(trigger_line_3, raster_irq_3)
raster_irq_3: raster_irq_handler(trigger_line_4, raster_irq_4)
raster_irq_4: raster_irq_handler(trigger_line_5, raster_irq_5)
raster_irq_5: raster_irq_handler(trigger_line_1, raster_irq_1)
