module IFetch (
    input clk,
    input rst,
    input [31:0] imm32,
    input branch_result,
    input zero,
    input jal,
    input jalr,
    input [31:0] Alu_result,
    output wire [31:0] instruction
    
);
reg [31:0] pc;


    
endmodule