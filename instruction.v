module instruction_control (
    input [31:0] instruction,
    output reg [6:0] opcode,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output reg [31:0] imm,
    output reg [2:0] func3,
    output reg [6:0] func7
);
assign opcode=instruction[6:0];
always @(*) begin
    rd = 5'b0;
    func3 = 3'b0;
    rs1 = 5'b0;
    rs2 = 5'b0;
    func7 = 7'b0;
    imm = 32'b0;
    case (opcode)
        7'b0110011:begin      //R-type
            rs1=instruction[19:15];
            rs2=instruction[24:20];
            rd=instruction[11:7];
            func3=instruction[14:12];
            func7=instruction[31:25];
        end
        7'b0010011:begin    //I-type-1
            rs1=instruction[19:15];
            rd=instruction[11:7];
            imm={{20{instruction[31]}},instruction[31:20]};   //imm符号扩展
            func3=instruction[14:12];
        end
        7'b0000011:begin    //I-type-2
            rs1=instruction[19:15];
            rd=instruction[11:7];
            imm={{20{instruction[31]}},instruction[31:20]};   //imm符号扩展
            func3=instruction[14:12];        
        end
        7'b0100011:begin   //S-type
            rs1=instruction[19:15];
            rs2=instruction[24:20];
            imm={{20{instruction[31]}},instruction[31:25],instruction[11:7]};
            func3=instruction[14:12];
        end 
        7'b1100011:begin  //B-type
            rs1=instruction[19:15];
            rs2=instruction[24:20];
            imm={{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
            func3=instruction[14:12];
        end
        7'b1101111:begin  //J-type
            rd=instruction[11:7];
            imm={{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
        end
        default: 
    endcase
end
    
endmodule