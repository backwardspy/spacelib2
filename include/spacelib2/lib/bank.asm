.filenamespace sl

.namespace bank {
    /*
     * swaps out kernal & basic ROMs by zeroing port register HIRAM bit
     */
    .macro @sl_bank_disable_kernal() {
        ensure_data_direction()

        // disable irq handling since kernal may disappear halfway through
        sei

        // disable CIA-1 and CIA-2 timer interrupts
        lda #%01111111
        sta irq_control_status
        sta nmi_control_status

        // ack CIA-1 and CIA-2 interrupts
        lda irq_control_status
        lda nmi_control_status

        // zero HIRAM bit
        lda cpu_port_register
        and #%11111101
        sta cpu_port_register

        // re-enable irq handling
        cli

        // disable nmi handling to ignore run/stop + restore
        sl_interrupts_disable_nmi()
    }

    .macro ensure_data_direction() {
        lda cpu_data_direction
        ora #%00000111
        sta cpu_data_direction
    }
}
