.text
.globl _start
_start:
    li s11, 0x10010000      # s11 = base address of memory-mapped IO
    li sp, 0x10011000       # initialize stack pointer
    li t6, 0                # t6 = 0, used for comparisons
    li t5, -1               # t5 = -1, used for other comparisons
    li a4, -1
    sw a4, 8(s11)           # turn off LED initially

init:
    jal switchjudge
    sw a4, 8(s11)           # clear LED
    lw a1, 4(s11)           # load test case index from address 0x10010004

    beq a1, t6, case0
    addi a1, a1, -1
    beq a1, t6, case1
    addi a1, a1, -1
    beq a1, t6, case2
    addi a1, a1, -1
    beq a1, t6, case3
    addi a1, a1, -1
    beq a1, t6, case4
    addi a1, a1, -1
    beq a1, t6, case5
    addi a1, a1, -1
    beq a1, t6, case6
    addi a1, a1, -1
    beq a1, t6, case7
    jal init

# case0: Combine and display a + b
case0:
    jal switchjudge
    lw t2, 0(s11)           # load input a from 0x10010000
    jal switchjudge
    lw t3, 4(s11)           # load input b from 0x10010004
    slli t2, t2, 24
    srli t2, t2, 16
    add t2, t2, t3
    sw t2, 8(s11)           # output to LED
    jal init

# case1: Input a and push to stack
case1:
    jal switchjudge
    lw t2, 0(s11)
    sw t2, 12(s11)          # display a
    addi sp, sp, -4
    sw t2, 0(sp)
    jal init

# case2: Input b and push to stack
case2:
    jal switchjudge
    lw t3, 4(s11)
    sw t3, 12(s11)          # display b
    addi sp, sp, -4
    sw t3, 0(sp)
    jal init

# case3: beq ！ check if a == b
case3:
    lw a5, 4(sp)
    lw a6, 0(sp)
    beq a5, a6, LEDcase3
    jal init
LEDcase3:
    li a7, 1
    sw a7, 8(s11)
    jal init

# case4: blt ！ check if a < b (signed)
case4:
    lw a5, 4(sp)
    lw a6, 0(sp)
    blt a5, a6, LEDcase4
    jal init
LEDcase4:
    li a7, 1
    sw a7, 8(s11)
    jal init

# case5: bltu ！ check if a < b (unsigned)
case5:
    lw a5, 4(sp)
    lw a6, 0(sp)
    bltu a5, a6, LEDcase5
    jal init
LEDcase5:
    li a7, 1
    sw a7, 8(s11)
    jal init

# case6: slt ！ a < b (signed) using slt
case6:
    lw a5, 4(sp)
    lw a6, 0(sp)
    slt t0, a5, a6
    bne t0, x0, LEDcase6
    jal init
LEDcase6:
    li a7, 1
    sw a7, 8(s11)
    jal init

# case7: sltu ！ a < b (unsigned) using sltu
case7:
    lw a5, 4(sp)
    lw a6, 0(sp)
    sltu t0, a5, a6
    bne t0, x0, LEDcase7
    jal init
LEDcase7:
    li a7, 1
    sw a7, 8(s11)
    jal init

# switchjudge: Wait for button press and release (debounce)
switchjudge:
    lw t1, 16(s11)              # read button input from address 0x10010010
    beq t1, x0, switchjudge     # wait for press
wait_release:
    lw t1, 16(s11)
    bne t1, x0, wait_release    # wait for release
    jr ra
