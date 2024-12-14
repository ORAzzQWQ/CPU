.section .data
# 定義測試結果存放地址
result_add: .word 0
result_sub: .word 0
result_and: .word 0
result_or:  .word 0
result_xor: .word 0
result_sll: .word 0
result_srl: .word 0
result_sra: .word 0
result_slt: .word 0
result_sltu: .word 0
result_lw:  .word 0
result_sw:  .word 0
result_beq: .word 0
result_bne: .word 0
result_blt: .word 0
result_bge: .word 0
result_bltu: .word 0
result_bgeu: .word 0
result_jal: .word 0
result_jalr: .word 0

.section .text
.globl _start
_start:
    # 初始化測試數據
    li x1, 10         # 測試數據 10
    li x2, 5          # 測試數據 5

    # 算術指令測試
    add x3, x1, x2    # x3 = x1 + x2
    sw x3, result_add # 存入結果

    sub x4, x1, x2    # x4 = x1 - x2
    sw x4, result_sub

    # 邏輯運算指令測試
    and x5, x1, x2    # x5 = x1 & x2
    sw x5, result_and

    or x6, x1, x2     # x6 = x1 | x2
    sw x6, result_or

    xor x7, x1, x2    # x7 = x1 ^ x2
    sw x7, result_xor

    # 移位指令測試
    sll x8, x1, x2    # x8 = x1 << (x2[4:0])
    sw x8, result_sll

    srl x9, x1, x2    # x9 = x1 >> (x2[4:0]) (logical)
    sw x9, result_srl

    sra x10, x1, x2   # x10 = x1 >> (x2[4:0]) (arithmetic)
    sw x10, result_sra

    # 比較指令測試
    slt x11, x1, x2   # x11 = (x1 < x2) ? 1 : 0
    sw x11, result_slt

    sltu x12, x1, x2  # x12 = (x1 < x2 unsigned) ? 1 : 0
    sw x12, result_sltu

    # 分支指令測試
    li x13, 0
    li x14, 1

    beq x1, x2, branch_equal
    sw x13, result_beq
    j branch_end
branch_equal:
    sw x14, result_beq
branch_end:

    bne x1, x2, branch_not_equal
    sw x13, result_bne
    j branch_ne_end
branch_not_equal:
    sw x14, result_bne
branch_ne_end:

    blt x1, x2, branch_lt
    sw x13, result_blt
    j branch_lt_end
branch_lt:
    sw x14, result_blt
branch_lt_end:

    bge x1, x2, branch_ge
    sw x13, result_bge
    j branch_ge_end
branch_ge:
    sw x14, result_bge
branch_ge_end:

    bltu x1, x2, branch_ltu
    sw x13, result_bltu
    j branch_ltu_end
branch_ltu:
    sw x14, result_bltu
branch_ltu_end:

    bgeu x1, x2, branch_geu
    sw x13, result_bgeu
    j branch_geu_end
branch_geu:
    sw x14, result_bgeu
branch_geu_end:

    # 跳躍指令測試
    jal x15, jump_label
    sw x15, result_jal
jump_label:
    addi x15, x0, 42   # 返回後 x15 = 42
    jalr x16, x0, 0
    sw x16, result_jalr

    # 記憶體指令測試
    li x17, 0x1000     # 模擬的記憶體地址
    sw x1, 0(x17)      # 存儲 x1
    lw x18, 0(x17)     # 加載到 x18
    sw x18, result_lw  # 驗證讀取

    # 無限迴圈以便測試
    j _start
