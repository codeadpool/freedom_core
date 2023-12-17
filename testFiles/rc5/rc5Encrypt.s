    .text
    .globl main

main:
    lui x9, 524288
    addi x6, x0, 26
    addi x3, x0, 2
88:
    lw x4, 0(x9)
    lw x5, 4(x9)

    xor x7, x1, x2
    andi x10, x2, 31
    sll x8, x7, x10
    lui x12, 0
    addi x12, x12, 32
    sub x12, x12, x10
    srl x11, x7, x12
    or x8, x8, x11
    add x1, x4, x8

    xor x7, x1, x2
    andi x10, x1, 31
    sll x8, x7, x10
    lui x12, 0
    addi x12, x12, 32
    sub x12, x12, x10
    srl x11, x7, x12
    or x8, x8, x11
    add x2, x5, x8

    addi x9, x9, 8
    addi x3, x3, 2
    bne x3, x6, -88
    
    ecall