.filenamespace sl

.namespace extensions {
    .function _16bit_next(arg) {
        .const val = arg.getValue()
        .if (arg.getType() == AT_IMMEDIATE) {
            .return CmdArgument(arg.getType(), >val)
        } else {
            .return CmdArgument(arg.getType(), val + 1)
        }
    }

    .pseudocommand @mov source : destination {
        lda source
        sta destination
    }

    .pseudocommand @mov16 source : destination {
        lda source
        sta destination
        lda _16bit_next(source)
        sta _16bit_next(destination)
    }

    .pseudocommand @inc16 arg {
        inc arg
        bne end
        inc _16bit_next(arg)
    end:
    }
}
