module IFetch (
    input clk,
    input rst,
    input [31:0] imm32,
    input branch_result,
    input zero,
    input jal,
    input jalr,
    input [31:0] Alu_result,
    output wire [31:0] instruction,
    output reg [31:0] pc_out  // 保存当前指令对应的PC
);
reg [31:0] pc;
reg [31:0] next_pc;
wire [31:0] pc_plus_4 = pc + 4;

// 指令ROM读取
prgrom urom (
    .clka(clk),
    .addra(pc[15:2]),  // 取指地址
    .douta(instruction)
);

// 计算下一条指令地址
always @(*) begin
    if (jalr) begin
        next_pc = Alu_result;
    end else if (jal) begin
        next_pc = pc + imm32;
    end else if (branch_result) begin
        next_pc = pc + imm32;
    end else begin
        next_pc = pc_plus_4;
    end
end

// 更新PC值
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        pc <=0;
    end else begin
        pc <= next_pc;
    end
end
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        pc_out <=0;
    end else begin
        pc_out <= pc_plus_4;
    end
end

endmodule
