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
    jal decode_float12
    sw a0, 0(s11)        # 同步显示到数码管a

    # 第二个浮点数输入
    jal switchjudge
    lw t2, 0(t1)
    sw t2, 4(s3)        # 存储浮点数到 memory[b]
    jal decode_float12
    sw a0, 0(s11)        # 同步显示到 LED 或数码管b
    jal init
decode_float12:
    andi t3, t3, 0xFF         # 强制无符号8位
    srli t0, t3, 7            # 符号位 S
    andi t1, t3, 0x70
    srli t1, t1, 4            # t1 = e_raw
    li t4, 3
    sub t1, t1, t4            # E = e_raw - 3

    andi t2, t3, 0x0F         # t2 = M（4位尾数）
    li t5, 16
    add a0, t2, t5            # a0 = 16 + M → 模拟 1 + M/16

    bgez t1, shift_left
    neg t6, t1
    srl a0, a0, t6            # 右移 E 次（负指数）
    j finalize

shift_left:
    sll a0, a0, t1            # 左移 E 次（正指数）

finalize:
    srli a0, a0, 4             # 最后除以 16
    beqz t0, done
    neg a0, a0                # 如果 S = 1，取负

done:
    jr ra


case3:
    lw t3, 0(s3)
    jal decode_float12
    mv t4, a0
    lw t3, 4(s3)
    jal decode_float12
    add t4, t4, a0
    sw t4, 0(s11)
    jal init


case4:
    jal switchjudge
    li t1, 0xfffffff9
    lw t2, 0(t1)         # 从switch读取值
    andi t2, t2, 0xF     # 提取低4位原始数据
    mv t3, t2            # 保存原始数据
    slli t3, t3, 4       # t3 = 原始数据 << 4 （准备拼接）

    jal crc4_calc        # t2 输入：原始数据，输出：CRC码

    or t4, t3, t2        # 拼接结果
    sw t4, 0(s10)        # 输出到LED
    jal init

# ===== CRC-4 多项式除法，输入: t2 = 原始数据 =====
crc4_calc:
    slli t2, t2, 4       # 左移构成8位被除数（原数据高4位，低4位为0）
    li t3, 0x13          # CRC多项式：X? + X + 1 = 0b10011
    li t4, 4             # 迭代次数：处理4位

crc_loop:
    srli t5, t2, 7        # 检查最高位bit 7是否为1
    beqz t5, skip_xor
    slli t6, t3, 3       # 将多项式左移对齐当前位（bit 7）
    xor t2, t2, t6
skip_xor:
    slli t2, t2, 1       # 左移1位，准备下一次迭代
    addi t4, t4, -1
    bnez t4, crc_loop

    srli t2, t2, 4       # 右移提取CRC结果
    andi t2, t2, 0xF     # 保证只有4位
    jr ra


case5:
    jal switchjudge
    li t1, 0xfffffff9
    lw t2, 0(t1)          # 读取输入数据（8位）

    mv t3, t2             # 备份原始数据（含CRC）
    jal crc4_check        # 校验 CRC：结果保存在 t2

    bnez t2, crc_fail     # 如果余数非0 → 校验失败

    li t4, 1
    sw t4, 0(s10)         # 校验通过 → 点亮LED
    jal init

crc_fail:
    sw zero, 0(s10)       # 校验失败 → 熄灭LED
    jal init

# 输入：t2 = 原始数据（含CRC）
# 输出：t2 = 最终CRC余数（若为0 → 校验成功）
crc4_check:
    li t3, 0x13           # 多项式 0b10011
    li t4, 8              # 处理8位

crc_check_loop:
    srli t5, t2, 7         # 提取最高位
    beqz t5, crc_skip

    slli t6, t3, 3        # t6 = 多项式左移3位，与数据对齐
    xor t2, t2, t6        # 异或操作

crc_skip:
    slli t2, t2, 1
    addi t4, t4, -1
    bnez t4, crc_check_loop

    srli t2, t2, 4        # 取最终余数（低4位）
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
    andi t5, t2, 1
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
