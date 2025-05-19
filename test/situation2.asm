.text
.globl _start


_start:
    li s3, 0x00001000                  # 初始化s3（memory）
    li s11, 0xfffffff0
    li s10, 0xffffffc2       


init:
    jal switchjudge
    sw zero, 0(s11)            
    sw zero 0(s10)	      # Clear LED again
    li t1, 0xfffffff7             # SWITCH_CASE_ADDR
    lw a1, 0(t1)                  # 读取测试编号

    beq a1, zero, case0
    addi a1, a1, -1
    beq a1, zero, case1
    addi a1, a1, -1
    beq a1, zero, case2
    addi a1, a1, -1
    beq a1, zero, case3
    addi a1, a1, -1
    beq a1, zero, case4
    addi a1, a1, -1
    beq a1, zero, case5
    addi a1, a1, -1
    beq a1, zero, case6
    addi a1, a1, -1
    beq a1, zero, case7
    jal _start

case0: #反转
    jal switchjudge
    li t1, 0xfffffff9
    lw t2, 0(t1)
    jal bit_reverse
    sw t2, 0(s10)        # 需修改为LED_ADDR 
    jal init


case1: # 回文检测
    jal switchjudge
    li t1, 0xfffffff9
    lw t2, 0(t1)
    mv t3, t2
    jal bit_reverse
    bne t2, t3, not_palindrome
    li t4, 1
    sw t4, 0(s10)   #需修改为led地址
    jal _start
not_palindrome:
    sw zero, 0(s10)  #需修改为led地址
    jal init


case2:
    # 第一个浮点数输入
    jal switchjudge          # 等待确认
    li t1, 0xfffffff9        # SWITCH_DATA_ADDR
    lw t2, 0(t1)             # t2 = 输入的高8位
    sw t2, 0(s3)        # 存储浮点数到 memory[a]
    jal decode_float8
    sw a0, 0(s11)        # 同步显示到数码管a

    # 第二个浮点数输入
    jal switchjudge
    lw t2, 0(t1)
    sw t2, 4(s3)        # 存储浮点数到 memory[b]
    jal decode_float8
    sw a0, 0(s11)        # 同步显示到 LED 或数码管b
    jal init
decode_float8:
    srli t0, t2, 7          # t0 = 符号位
    andi t1, t2, 0x70       # t1 = exp_raw << 4
    srli t1, t1, 4          # t1 = exp_raw
    andi t2, t2, 0x0F       # t2 = 尾数（注意这里会覆盖输入）

    li t3, 3
    sub t1, t1, t3          # t1 = exp - 3
    mv a0, t2               # a0 = mantissa
    li t2, 0                # 作为 shift counter（可用 t2 现在它无用了）

shift_loop8:
    beq t2, t1, shift_done8
    slli a0, a0, 1
    addi t2, t2, 1
    j shift_loop8

shift_done8:
    beqz t0, decode_end8    # 如果符号为0，跳过
    sub a0, zero, a0        # 否则 a0 = -a0
decode_end8:
    jr ra



case3:
    lw t3, 0(s3)
    jal decode_float8
    mv t4, a0
    lw t3, 4(s3)
    jal decode_float8
    add t4, t4, a0
    sw t4, 0(s11)
    jal init


case4:
    jal switchjudge
    li t1, 0xfffffff9
    lw t2, 0(t1)
    andi t2, t2, 0xF
    mv t3, t2
    slli t3, t3, 4
    jal crc4_calc
    or t4, t3, t2
    sw t4, 0(s10) #改为led
    jal init
    
# 输入：t2 = 4-bit 原始数据（低4位有效）
# 输出：t2 = 4-bit CRC校验码（低4位）
crc4_calc:
    slli t2, t2, 4       # 数据左移4位，构造8位被除数
    li t3, 0x13          # CRC-4多项式 0b10011
    li t4, 4             # 精确除4位即可（因为最多4次异或）

crc_loop:
    srl t5, t2, 7        # 提取当前最高位（第8位）
    beqz t5, skip_xor    # 如果最高位是0，不做异或
    xor t2, t2, t3 << 3  # 将0x13左移对齐，做异或
skip_xor:
    slli t2, t2, 1
    addi t4, t4, -1
    bnez t4, crc_loop

    srli t2, t2, 4       # CRC位在低4位，右移提取
    andi t2, t2, 0xF
    jr ra

case5:
    jal switchjudge
    li t1, 0xfffffff9
    lw t2, 0(t1)          # 读取输入数据（8位）

    mv t3, t2             # 备份原数据
    jal crc4_check        # 校验 CRC：结果保存在 t2

    bnez t2, crc_fail     # 如果余数非0 → 校验失败

    li t4, 1
    sw t4, 0(s10)        # 校验通过 → 点亮LED
    jal init

crc_fail:
    sw zero, 0(s10)      # 校验失败 → 熄灭LED
    jal init


crc4_check:
    li t3, 0x13          # CRC-4 多项式
    li t4, 8             # 需要做8轮除法

crc_check_loop:
    srl t5, t2, 7        # 提取最高位
    beqz t5, crc_skip
    xor t2, t2, t3 << 3  # 左对齐多项式，做异或
crc_skip:
    slli t2, t2, 1
    addi t4, t4, -1
    bnez t4, crc_check_loop

    srli t2, t2, 4       # 取最终余数
    andi t2, t2, 0xF
    jr ra


case6:
    lui t0, 0x12345      # t0 = 0x12345000
    srli t1, t0, 12      # 右移12位，t1应为0x12345
    li s11, 0xfffffff0
    sw t1, 0(s11)        # 输出高位到 LED
    jal init



case7:
    auipc t0, 0          # t0 = PC
    addi t0, t0, 16      # t0 指向后面 label_jalr
    jal ra, label_jal    # 跳转执行 jal 测试，ra = 下一条指令地址

label_jalr:
    li s11, 0xffffffe8
    sw ra, 0(s11)        # 将 ra 写到 LED 显示，验证 jal 设置正确
    jal init

label_jal:
    jalr zero, t0, 0     # 用 jalr 返回到 label_jalr



bit_reverse:
    mv t3, zero
    li t4, 8
rev_loop:
    slli t3, t3, 1
    and t5, t2, 1
    or t3, t3, t5
    srli t2, t2, 1
    addi t4, t4, -1
    bnez t4, rev_loop
    mv t2, t3
    jr ra



switchjudge:
    li t1, 0xffffff00
    lw t2, 0(t1)
    beq t2, zero, switchjudge
wait_release:
    lw t2, 0(t1)
    bne t2, zero, wait_release
    jr ra
