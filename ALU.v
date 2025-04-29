module ALU (
    input [3:0] ALUop,
    input ALUSrc,
    input sftmd,
    input Branch,
    input nBranch,
    input Branch_lt,
    input Branch_ge,
    input Branch_ltu,
    input Branch_geu,
    input [31:0] read_data_1,
    input [31:0] read_data_2,
    input imm32,
    output reg [31:0] Alu_result,
    output reg zero,
    output reg branch_result
);

wire is_imm = (ALUSrc=1'b1);
wire input_2;

always @(*) begin
    zero=1'b0;
    Alu_result={32{1'b0}};
    branch_result=1'b0;
    //总共13位
    case({ALUop,ALUSrc,sftmd,Branch,nBranch,Branch_lt,Branch_ge,Branch_ltu,Branch_geu,is_imm})
        13'b0000_0_0_0_0_0_0_0_0_0:begin        //add
            Alu_result=read_data_1+read_data_2;
        end
        13'b0001_0_0_0_0_0_0_0_0_0:begin        //sub
            Alu_result=read_data_1-read_data_2;
            if (Alu_result=={32{1'b0}})begin
                zero=1'b1;
            end
        end
        13'b0010_0_0_0_0_0_0_0_0_0:begin        //xor
            Alu_result=read_data_1^read_data_2;
        end
        13'b0011_0_0_0_0_0_0_0_0_0:begin        //or
            Alu_result=read_data_1|read_data_2;
        end
        13'b0100_0_0_0_0_0_0_0_0_0:begin        //and
            Alu_result=read_data_1&read_data_2;
        end
        13'b0101_0_1_0_0_0_0_0_0_0:begin        //sll
            Alu_result=read_data_1<<read_data_2;
        end
        13'b0110_0_1_0_0_0_0_0_0_0:begin        //srl
            Alu_result=read_data_1>>read_data_2;
        end
        13'b0111_0_1_0_0_0_0_0_0_0:begin        //sra
            Alu_result = $signed(read_data_1) >>> read_data_2;
        end
        
    endcase
end
    
endmodule