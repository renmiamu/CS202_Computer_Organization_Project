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

prgrom urom (
    .clka(clk),
    .addra(pc[15:2]),
    .douta(instruction)
);

always @(negedge clk) begin
    if (!rst) begin
        pc<={32{1'b0}};
    end else if (jalr) begin
        pc <= Alu_result;
    end else if (jal) begin
        pc <= pc + imm32;
        pc_out<=pc+4;
    end else if (branch_result) begin
        pc <= pc + imm32;
    end else begin
        pc <= pc + 4;
    end
end

endmodule