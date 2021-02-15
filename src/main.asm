.disk [filename = "spacelib2.d64", name="SPACELIB2", id="2021"] {
    [name="--------------", type="rel"                    ],
    [name="SPACELIB2 DEMO", type="prg", segments="Default"],
    [name="--------------", type="rel"                    ],
}

// enables various debug readouts & functionality
// #define DEBUG

#import "player.asm"

// setting to true speeds up irq handling by disabling kernal & default handlers
.const quick_irq = true

// colour of background + border lines
.const floor_colour = sl.gfx.dark_grey
.const outside_colour = sl.gfx.grey

.const hall_begin_line = 100
.const hall_end_line = 200

irq_hall_begin:
    sl_interrupts_irq_handler_begin(quick_irq)
    sl_gfx_set_border_colour(floor_colour)
    sl_interrupts_raster_set_trigger_line(hall_end_line, irq_hall_end, quick_irq)
    sl_interrupts_irq_handler_end(quick_irq)

irq_hall_end:
    sl_interrupts_irq_handler_begin(quick_irq)
    sl_gfx_set_border_colour(outside_colour)
    sl_interrupts_raster_set_trigger_line(hall_begin_line, irq_hall_begin, quick_irq)
    sl_interrupts_irq_handler_end(quick_irq)

entry_point:
    .if (quick_irq) {
        // yeet kernal & basic
        sl_bank_disable_kernal()
    }

    sl_interrupts_raster_init(hall_begin_line, irq_hall_begin, quick_irq)

    // set colours & clear screen
    sl_gfx_set_border_colour(outside_colour)
    sl_gfx_set_background_colour(floor_colour)
    sl_gfx_fill(colour_base, sl.gfx.white)
    sl_gfx_fill(screen_base, ' ')

    // init sprites
    sl_sprite_multicolour_enable_all(true)
    sl_sprite_multicolour_set_colours(sl.gfx.green, sl.gfx.blue)

    jsr player.init
    
    sl_sprite_enable_all(true)

    main_loop:
        sl_gfx_wait_for_raster(250)

        jsr player.update

        sl_sprite_anim_update()

        jmp main_loop
