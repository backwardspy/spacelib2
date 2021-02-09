str_irq_vector_0:
    .text "irq vector 0 ($fffe/$ffff): "
    .label str_irq_vector_0_len = * - str_irq_vector_0
    .byte 0

str_irq_vector_1:
    .text "irq vector 1 ($0314/$0315): "
    .label str_irq_vector_1_len = * - str_irq_vector_1
    .byte 0
