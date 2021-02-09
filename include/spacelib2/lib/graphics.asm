.filenamespace sl

.namespace gfx {
    .label grid_width = 40
    .label grid_height = 25
    .label character_size = 8
    .label screen_width = grid_width * character_size
    .label screen_height = grid_height * character_size

    .label black = $0
    .label white = $1
    .label red = $2
    .label cyan = $3
    .label violet = $4
    .label green = $5
    .label blue = $6
    .label yellow = $7
    .label orange = $8
    .label brown = $9
    .label light_red = $a
    .label dark_grey = $b
    .label grey = $c
    .label light_green = $d
    .label light_blue = $e
    .label light_grey = $f

    .macro @sl_gfx_fill(addr, value) {
        lda #value
        sl_gfx_fill_from_ac(addr)
    }
    
    .macro @sl_gfx_fill_from_ac(addr) {
        ldx #0
        loop:
            sta addr+$0000, x
            sta addr+$0100, x
            sta addr+$0200, x
            sta addr+$02e8, x
            inx
            bne loop
    }

    .macro @sl_gfx_set_background_colour(colour) {
        lda #colour
        sta background_colour
    }

    .macro @sl_gfx_set_border_colour(colour) {
        lda #colour
        sta border_colour
    }

    .macro @sl_gfx_wait_for_raster(line) {
        !loop:
            lda raster_line
            cmp #line - 1
            bne !loop-
        !loop:
            lda raster_line
            cmp #line
            bne !loop-
    }
}
