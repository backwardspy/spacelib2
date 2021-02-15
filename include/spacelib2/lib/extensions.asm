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

    .pseudocommand @dec16 arg {
        lda arg
        bne low // skip high byte dec if arg != 0
        dec _16bit_next(arg)
    low:
        dec arg
    }

    /*
     * Examples:
     *
     * add 5 to 10 and store at $1000
     * > add16 #5 : #10 : $1000
     *
     * subtract $1001 from $1000 and store at $1002
     * > sub16 $1000 : $1001 : $1002
     *
     * add 5 to $1000
     * > add16 $1000 : #5
     */
    .pseudocommand @add arg1 : arg2 : target {
        .if (target.getType() == AT_NONE) {
            .eval target = arg1
        }
        clc
        lda arg1
        adc arg2
        sta target
    }

    .pseudocommand @sub arg1 : arg2 : target {
        .if (target.getType() == AT_NONE) {
            .eval target = arg1
        }
        sec
        lda arg1
        sbc arg2
        sta target
    }

    .pseudocommand @add16 arg1 : arg2 : target {
        .if (target.getType() == AT_NONE) {
            .eval target = arg1
        }
        clc
        lda arg1
        adc arg2
        sta target
        lda _16bit_next(arg1)
        adc _16bit_next(arg2)
        sta _16bit_next(target)
    }

    .pseudocommand @sub16 arg1 : arg2 : target {
        .if (target.getType() == AT_NONE) {
            .eval target = arg1
        }
        sec
        lda arg1
        sbc arg2
        sta target
        lda _16bit_next(arg1)
        sbc _16bit_next(arg2)
        sta _16bit_next(target)
    }
}
