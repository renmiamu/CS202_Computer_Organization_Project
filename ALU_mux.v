module ALU_mux (
    input [31:0] read_data_2,
    input [31:0] imm,
    input ALUSrc,
    output reg [31:0] ALU_input
);

always @(*) begin
    if (ALUSrc) begin
        ALU_input=imm;
    end else begin
        ALU_input=read_data_2;
    end
end
    
endmodule