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
always @(negedge clk ) begin
    if (!rst) begin
        pc<={32{1'b0}};
    end
    else begin
        if (branch_result|jal) begin
            pc<=pc+imm32;
        end
        else if (jalr) begin
            pc<=Alu_result;
        end else begin
            pc<=pc+4;
        end
    end
end
prgrom urom( .clka(clk), .addra(pc[15:2]), .douta(inst));

endmodule