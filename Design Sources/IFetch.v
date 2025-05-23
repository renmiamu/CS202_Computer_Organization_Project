module IFetch (
    input clk,
    input rst,
    input [31:0] imm32,
    input branch_result,
    input zero,
    input jal,
    input jalr,
    input [31:0] Alu_result,

    // UART programmer ports
    input upg_rst,
    input upg_clk,
    input upg_wen_o,
    input [14:0] upg_adr_o,
    input [31:0] upg_dat_o,
    input upg_done_o,

    output wire [31:0] instruction,
    output reg [31:0] pc_out
);

    reg [31:0] pc;
    reg [31:0] next_pc;
    wire [31:0] pc_plus_4 = pc + 4;

    // ========== UART 模式切换 ==========
    wire kickOff = upg_rst | (~upg_rst & upg_done_o);

    // 地址选择（PC or UART）
    wire [13:0] rom_addr = kickOff ? pc[15:2] : upg_adr_o[13:0];
    // 时钟选择
    wire rom_clk = kickOff ? clk : upg_clk;
    // 写使能（仅 UART 模式写）
    wire rom_we = kickOff ? 1'b0 : (upg_wen_o & ~upg_adr_o[14]);  // 高位为0表示写 programrom
    // 写数据（UART 模式才使用）
    wire [31:0] rom_din = upg_dat_o;

    // ========== programrom 实例 ==========
    prgrom urom (
        .clka   (rom_clk),
        .wea    (rom_we),
        .addra  (rom_addr),
        .dina   (rom_din),
        .douta  (instruction)
    );

    // ========== PC控制 ==========
    always @(*) begin
        if (jalr)
            next_pc = Alu_result;
        else if (jal)
            next_pc = pc + imm32;
        else if (branch_result)
            next_pc = pc + imm32;
        else
            next_pc = pc_plus_4;
    end

    // ========== PC更新 ==========
    always @(negedge clk or negedge rst) begin
        if (!rst)
            pc <= 0;
        else if (kickOff)  // 仅在正常模式下更新 PC
            pc <= next_pc;
    end

    always @(negedge clk or negedge rst) begin
        if (!rst)
            pc_out <= 0;
        else if (kickOff)
            pc_out <= pc_plus_4;
    end

endmodule
