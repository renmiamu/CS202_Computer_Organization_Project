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
    output reg [31:0] pc_out
);

reg [31:0] pc;
reg [31:0] next_pc;

prgrom urom (
    .clka(clk),
    .addra(pc[15:2]),
    .douta(instruction)
);

always @(*) begin
    if (jalr) begin
        next_pc = Alu_result;
    end else if (jal) begin
        next_pc = pc + imm32;
    end else if (branch_result) begin
        next_pc = pc + imm32;
    end else begin
        next_pc = pc + 4;
    end
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        pc <= 32'b0;
    end else begin
        pc <= next_pc;
    end
end

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        pc_out <= 32'b0;
    end else begin
        pc_out <= pc;
    end
end

endmodule