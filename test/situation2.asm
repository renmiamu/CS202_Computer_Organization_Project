.text
.globl _start


_start:
    li s3, 0x00001000                  # ��ʼ��s3��memory��
    li s11, 0xfffffff0
    li s10, 0xffffffc2       


init:
    jal switchjudge
    sw zero, 0(s11)            
    sw zero 0(s10)	      # Clear LED again
    li t1, 0xfffffff7             # SWITCH_CASE_ADDR
    lw a1, 0(t1)                  # ��ȡ���Ա��

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

case0: #��ת
    jal switchjudge
    li t1, 0xfffffff9
    lw t2, 0(t1)
    jal bit_reverse
    sw t2, 0(s10)        # ���޸�ΪLED_ADDR 
    jal init


case1: # ���ļ��
    jal switchjudge
    li t1, 0xfffffff9
    lw t2, 0(t1)
    mv t3, t2
    jal bit_reverse
    bne t2, t3, not_palindrome
    li t4, 1
    sw t4, 0(s10)   #���޸�Ϊled��ַ
    jal init
not_palindrome:
    sw zero, 0(s10)  #���޸�Ϊled��ַ
    jal init


case2:
    # ��һ������������
    jal switchjudge          # �ȴ�ȷ��
    li t1, 0xfffffff9        # SWITCH_DATA_ADDR
    lw t2, 0(t1)             # t2 = ����ĸ�8λ
    sw t2, 0(s3)        # �洢�������� memory[a]
    jal decode_float8
    sw a0, 0(s11)        # ͬ����ʾ�������a

    # �ڶ�������������
    jal switchjudge
    lw t2, 0(t1)
    sw t2, 4(s3)        # �洢�������� memory[b]
    jal decode_float8
    sw a0, 0(s11)        # ͬ����ʾ�� LED �������b
    jal init
decode_float8:
    srli t0, t2, 7          # t0 = ����λ
    andi t1, t2, 0x70       # t1 = exp_raw << 4
    srli t1, t1, 4          # t1 = exp_raw
    andi t2, t2, 0x0F       # t2 = β����ע������Ḳ�����룩

    li t3, 3
    sub t1, t1, t3          # t1 = exp - 3
    mv a0, t2               # a0 = mantissa
    li t2, 0                # ��Ϊ shift counter������ t2 �����������ˣ�

shift_loop8:
    beq t2, t1, shift_done8
    slli a0, a0, 1
    addi t2, t2, 1
    j shift_loop8

shift_done8:
    beqz t0, decode_end8    # �������Ϊ0������
    sub a0, zero, a0        # ���� a0 = -a0
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
    sw t4, 0(s10) #��Ϊled
    jal init
    
# ���룺t2 = 4-bit ԭʼ���ݣ���4λ��Ч��
# �����t2 = 4-bit CRCУ���루��4λ��
crc4_calc:
    slli t2, t2, 4       # ��������4λ������8λ������
    li t3, 0x13          # CRC-4����ʽ 0b10011
    li t4, 4             # ��ȷ��4λ���ɣ���Ϊ���4�����

crc_loop:
    srl t5, t2, 7        # ��ȡ��ǰ���λ����8λ��
    beqz t5, skip_xor    # ������λ��0���������
    xor t2, t2, t3 << 3  # ��0x13���ƶ��룬�����
skip_xor:
    slli t2, t2, 1
    addi t4, t4, -1
    bnez t4, crc_loop

    srli t2, t2, 4       # CRCλ�ڵ�4λ��������ȡ
    andi t2, t2, 0xF
    jr ra

case5:
    jal switchjudge
    li t1, 0xfffffff9
    lw t2, 0(t1)          # ��ȡ�������ݣ�8λ��

    mv t3, t2             # ����ԭ����
    jal crc4_check        # У�� CRC����������� t2

    bnez t2, crc_fail     # ���������0 �� У��ʧ��

    li t4, 1
    sw t4, 0(s10)        # У��ͨ�� �� ����LED
    jal init

crc_fail:
    sw zero, 0(s10)      # У��ʧ�� �� Ϩ��LED
    jal init


crc4_check:
    li t3, 0x13          # CRC-4 ����ʽ
    li t4, 8             # ��Ҫ��8�ֳ���

crc_check_loop:
    srl t5, t2, 7        # ��ȡ���λ
    beqz t5, crc_skip
    xor t2, t2, t3 << 3  # ��������ʽ�������
crc_skip:
    slli t2, t2, 1
    addi t4, t4, -1
    bnez t4, crc_check_loop

    srli t2, t2, 4       # ȡ��������
    andi t2, t2, 0xF
    jr ra


case6:
    lui t0, 0x12345      # t0 = 0x12345000
    srli t1, t0, 12      # ����12λ��t1ӦΪ0x12345
    li s11, 0xfffffff0
    sw t1, 0(s11)        # �����λ�� LED
    jal init



case7:
    auipc t0, 0          # t0 = PC
    addi t0, t0, 16      # t0 ָ����� label_jalr
    jal ra, label_jal    # ��תִ�� jal ���ԣ�ra = ��һ��ָ���ַ

label_jalr:
    li s11, 0xffffffe8
    sw ra, 0(s11)        # �� ra д�� LED ��ʾ����֤ jal ������ȷ
    jal init

label_jal:
    jalr zero, t0, 0     # �� jalr ���ص� label_jalr



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
