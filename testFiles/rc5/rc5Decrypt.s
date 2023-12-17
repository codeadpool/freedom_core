    .text
    .globl main

main:    
    lui x9, 0x80000   
    addi x9, x9, 0x5e   
    
    addi x20, x20, 8
    addi x21, x21, 2

    addi x6, x0, 0 
    addi x3, x0, 24 

88:
    lw x4, -4(x9)
    lw x5, 0(x9)

    sub x10, x2, x5
    andi x7, x1, 31
    srl x8, x10, x7

    lui x12, 0
    addi x12, x12, 32
    sub x12, x12, x7 
    sll x11, x10, x12 
    or x8, x8, x11
    xor x2, x8, x1

    sub x10, x1, x4
    andi x7, x2, 31
    srl x8, x10, x7
    
    lui x12, 0
    addi x12, x12, 32
    sub x12, x12, x7 
    sll x11, x10, x12 
    or x8, x8, x11
    xor x1, x8, x2

    sub x9, x9, x20
	sub x3, x3, x21
    bne x3, x6, 88

    ecall