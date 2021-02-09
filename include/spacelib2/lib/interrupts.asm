.filenamespace sl

.namespace interrupts {
    /*
     * initialises the system for a custom raster line interrupt handler.
     */
    .macro @sl_interrupts_raster_init(trigger_line, handler_address, quick) {
        // ignore interrupts during init
        sei

        // disable CIA-1 and CIA-2 timer interrupts
        lda #%01111111
        sta irq_control_status
        sta nmi_control_status

        // ack CIA-1 and CIA-2 interrupts
        lda irq_control_status
        lda nmi_control_status

        // set irq raster line
        sl_interrupts_raster_set_trigger_line(
            trigger_line,
            handler_address,
            quick
        )

        // enable vic raster irq
        lda #$01
        sta vic_irq_enable

        // stop ignoring interrupts
        cli
    }

    /*
     * sets a raster line interrupt at the given line for the given handler.
     */
    .macro @sl_interrupts_raster_set_trigger_line(
        trigger_line,
        handler_address,
        quick
    ) {
        // set irq raster line
        mov #<trigger_line : raster_line

        // set raster line bit #9
        lda vic_control
        .if (trigger_line > 255) {
            ora #%10000000
        } else {
            and #%01111111
        }
        sta vic_control

        // point irq vector to custom handler
        .if (quick) {
            mov16 #handler_address : irq_rom_vector
        } else {
            mov16 #handler_address : irq_ram_vector
        }
    }

    /*
     * begins an irq handler.
     * if quick is true, pushes AC, XR, and YR onto the stack.
     */
    .macro @sl_interrupts_irq_handler_begin(quick) {
        .if (quick) {
            pha
            txa
            pha
            tya
            pha
        }
    }

    /*
     * ends an irq handler, acknowledging vic irq.
     * if quick is true, pulls AC, XR, and YR from the stack and returns.
     * if quick is false, jumps to kernal irq handler.
     */
    .macro @sl_interrupts_irq_handler_end(quick) {
        // ack irq
        asl vic_irq_control

        .if (quick) {
            pla
            tay
            pla
            tax
            pla
            rti
        } else {
            // jump to kernal irq handler
            jmp irq_rom_routine
        }
    }

    /*
     * overwrites nmi handler with a no-op.
     * mostly used to avoid bad jumps if kernal has been switched out.
     */
    .macro @sl_interrupts_disable_nmi() {
        mov16 nop_nmi_handler : nmi_rom_vector
    }

    nop_nmi_handler:
        rti
}
