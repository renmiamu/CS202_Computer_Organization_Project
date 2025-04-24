module instruction_control (
    input [31:0] instruction,
    output reg Branch,
    output reg MemRead,
    output reg MemToReg,
    output reg [3:0] ALUop,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite
);
wire [2:0]func3;
wire [6:0]func7;
wire [6:0]opcode;
assign func3 = instruction[14:12];
assign func7 = instruction[31:25];
assign opcode = instruction[6:0];

always @(*) begin
    Branch=1'b0;
    MemRead=1'b0;
    MemToReg=1'b0;
    ALUop=4'b0000;
    MemWrite=1'b0;
    ALUSrc=1'b0;
    RegWrite=1'b0;
    case(opcode)
        //R-type
        7'b0110011:begin
            RegWrite=1'1;
            case({func3,func7})
                10'b000_0000000:begin
                    ALUop=4'b0000;        //add
                end
                10'b000_0100000:begin
                    ALUop=4'b0001;        //sub
                end
                10'b100_0000000:begin
                    ALUop=4'b0010;        //xor
                end
                10'b110_0000000:begin
                    ALUop=4'b0011;        //or
                end
                10'b111_0000000:begin
                    ALUop=4'b0100;        //and
                end
            endcase
        end
        //I-type-1
        7'b0010011:begin
            RegWrite=1'b1;
            ALUSrc=1'b1;
            case(func3)
                3'b000:begin
                    ALUop=4'b0000;     //addi
                end
                3'b100:begin
                    ALUop=4'b0001;     //xori
                end
                3'b110:begin
                    ALUop=4'b0010;     //ori
                end
                3'b111:begin
                    ALUop=4'b0011;     //andi
                end
            endcase
        end
        //I-type-2-load
        7'b0000011:begin
            ALUSrc=1'b1;
            MemRead=1'b1;
            MemToReg=1'b1;
        end
        
    endcase
end

    
endmodule