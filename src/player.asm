.filenamespace player

.const sprite = 0

.const x_spawn = 173
.const y_spawn = 163

.const x_min = 20
.const x_max = 323
.const y_min = 82
.const y_max = 229

.const speed = 1

.const anim_delay = 6
.const anim_frames = 4
.const anim_down_start = 0
.const anim_up_start = 4
.const anim_left_start = 8
.const anim_right_start = 12

.const state_idle = 0
.const state_up = 1
.const state_down = 2
.const state_left = 3
.const state_right = 4

x_pos: .word x_spawn
y_pos: .byte y_spawn

state: .byte state_idle

state_jump_table:
    .word update_state_idle
    .word update_state_up
    .word update_state_down
    .word update_state_left
    .word update_state_right

init: {
    sl_sprite_set_position_vaa(sprite, x_pos, y_pos)
    sl_sprite_anim_set_frame(sprite, anim_down_start)
    sl_sprite_set_colour(sprite, sl.gfx.yellow)
    rts
}

update: {
    jsr update_position
    jsr update_state

    #if DEBUG
        sl_debug_print_word(1, 1, x_pos)
        sl_debug_print_byte(1, 7, y_pos)
    #endif

    rts
}

update_position: {
    sl_input_joy_pressed(1, sl.input.joy_button_up); bne !+
        sub y_pos : #speed

!:  sl_input_joy_pressed(1, sl.input.joy_button_down); bne !+
        add y_pos : #speed

!:  sl_input_joy_pressed(1, sl.input.joy_button_left); bne !+
        sub16 x_pos : #speed

!:  sl_input_joy_pressed(1, sl.input.joy_button_right); bne !+
        add16 x_pos : #speed

!:  sl_math_clamp16(x_pos, x_min, x_max)
    sl_math_clamp(y_pos, y_min, y_max)
    
    sl_sprite_set_position_vaa(sprite, x_pos, y_pos)
    rts
}

update_state: {
    // use state*2 to index into state jump table
    lda state
    asl
    tax
    mov16 state_jump_table, x : zp_vector_0
    jmp (zp_vector_0)
}

update_state_idle: {
    sl_input_joy_pressed(1, sl.input.joy_button_up); bne !+
        jsr set_state_up
!:  sl_input_joy_pressed(1, sl.input.joy_button_down); bne !+
        jsr set_state_down
!:  sl_input_joy_pressed(1, sl.input.joy_button_left); bne !+
        jsr set_state_left
!:  sl_input_joy_pressed(1, sl.input.joy_button_right); bne !+
        jsr set_state_right
!:  rts
}

update_state_up: {
    sl_input_joy_pressed(1, sl.input.joy_button_up); bne !+
        jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_down); bne !+
        jsr set_state_down; jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_left); bne !+
        jsr set_state_left; jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_right); bne !+
        jsr set_state_right; jmp end
!:  jsr set_state_idle
end:
    rts
}

update_state_down: {
    sl_input_joy_pressed(1, sl.input.joy_button_up); bne !+
        jsr set_state_up; jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_down); bne !+
        jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_left); bne !+
        jsr set_state_left; jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_right); bne !+
        jsr set_state_right; jmp end
!:  jsr set_state_idle
end:
    rts
}

update_state_left: {
    sl_input_joy_pressed(1, sl.input.joy_button_up); bne !+
        jsr set_state_up; jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_down); bne !+
        jsr set_state_down; jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_left); bne !+
        jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_right); bne !+
        jsr set_state_right; jmp end
!:  jsr set_state_idle
end:
    rts
}

update_state_right: {
    sl_input_joy_pressed(1, sl.input.joy_button_up); bne !+
        jsr set_state_up; jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_down); bne !+
        jsr set_state_down; jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_left); bne !+
        jsr set_state_left; jmp end
!:  sl_input_joy_pressed(1, sl.input.joy_button_right); bne !+
        jmp end
!:  jsr set_state_idle
end:
    rts
}

set_state_idle:
    mov #state_idle : state
    sl_sprite_anim_set_frame(sprite, anim_down_start)
    rts

set_state_up:
    mov #state_up : state
    sl_sprite_anim_start(sprite, anim_frames, anim_up_start, anim_delay, true)
    rts

set_state_down:
    mov #state_down : state
    sl_sprite_anim_start(sprite, anim_frames, anim_down_start, anim_delay, true)
    rts

set_state_left:
    mov #state_left : state
    sl_sprite_anim_start(sprite, anim_frames, anim_left_start, anim_delay, true)
    rts

set_state_right:
    mov #state_right : state
    sl_sprite_anim_start(sprite, anim_frames, anim_right_start, anim_delay, true)
    rts
