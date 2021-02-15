.filenamespace sl

.namespace input {
    .label joy_button_up    = %00000001
    .label joy_button_down  = %00000010
    .label joy_button_left  = %00000100
    .label joy_button_right = %00001000
    .label joy_button_fire  = %00010000

    /*
     * checks status of a joystick button
     * Z flag indicates button status
     */
    .macro @sl_input_joy_pressed(port, button) {
        .if (port != 1 && port != 2) {
            .error("sl_input_joy_pressed: `port` must be 1 or 2")
        }

        .if (
            button != joy_button_up &&
            button != joy_button_down &&
            button != joy_button_left &&
            button != joy_button_right &&
            button != joy_button_fire
        ) {
            .error(
                "sl_input_joy_pressed: `button` must be a joy_button constant"
            )
        }

        .var reg
        .if (port == 1) {
            .eval reg = data_port_b
        } else {
            .eval reg = data_port_a
        }

        lda #button
        bit reg
    }
}