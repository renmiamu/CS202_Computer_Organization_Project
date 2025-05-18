.text
.globl _start
_start:
    li sp, 0x10011000         # Stack pointer
    li t6, 0                  # Zero for comparison
    li t5, -1                 # -1 for tests
    li a4, 0x01234567               
    li s11, 0xffffffe8       # For LED/Output use
    sw a4, 8(s11)             # Turn off LED

init:
    jal switchjudge

    sw t6, 8(s11)             # Clear LED again

    li t1, 0xfffffff7         # Get test case index from switch (low 3 bits)
    lw a1, 0(t1)

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

# case0: 输入 a 与 b，
case0:
    # Input a
    jal switchjudge
    li t1, 0xfffffff9
    li t2, 0xfffffff5
    lw t2, 0(t1)
    sw t2, 8(s11)        # Show a

    # Input b
    jal switchjudge
    lw t3, 0(t2)
    sw t3, 8(s11)        # Overwrite LED with b

    jal init

# case1: 输入 a 并压栈
case1:
    jal switchjudge
    li t1, 0xfffffff9
    lb t2, 0(t1)
    sw t2, 8(s11)
    addi sp, sp, -4
    sw t2, 0(sp)
    jal init

# case2: 输入 b 并压栈
case2:
    jal switchjudge
    li t1, 0xfffffff5
    lbu t3, 0(t1)
    sw t3, 8(s11)
    addi sp, sp, -4
    sw t3, 0(sp)
    jal init

# case3: beq 判断 a == b
case3:
    lw a5, 4(sp)
    lw a6, 0(sp)
    beq a5, a6, LEDcase3
    jal init
LEDcase3:
    li a7, 11111111
    sw a7, 8(s11)
    jal init

# case4: blt a < b (signed)
case4:
    lw a5, 4(sp)
    lw a6, 0(sp)
    blt a5, a6, LEDcase4
    jal init
LEDcase4:
    li a7, 111111111
    sw a7, 8(s11)
    jal init

# case5: bltu a < b (unsigned)
case5:
    lw a5, 4(sp)
    lw a6, 0(sp)
    bltu a5, a6, LEDcase5
    jal init
LEDcase5:
    li a7, 1
    sw a7, 8(s11)
    jal init

# case6: slt a < b (signed)
case6:
    lw a5, 4(sp)
    lw a6, 0(sp)
    slt t0, a5, a6
    bne t0, x0, LEDcase6
    jal init
LEDcase6:
    li a7, 11111111
    sw a7, 8(s11)
    jal init

# case7: sltu a < b (unsigned)
case7:
    lw a5, 4(sp)
    lw a6, 0(sp)
    sltu t0, a5, a6
    bne t0, x0, LEDcase7
    jal init
LEDcase7:
    li a7, 11111111
    sw a7, 8(s11)
    jal init

# switchjudge: 等待按钮按下+释放
switchjudge:
    li t1, 0xffffff00         # 按钮地址
    lw t2, 0(t1)
    beq t2, x0, switchjudge
wait_release:
    lw t2, 0(t1)
    bne t2, x0, wait_release
    jr ra
