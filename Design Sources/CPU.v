module CPU (
    input clk,             
    input reset,
    input [15:0] io_rdata,
    output [15:0] io_wdata,
);
    // 分频后的内部时钟
    wire clk_divided;

    // 分频器实例化
    cpuclk clk_divider (
        .clk_in1(clk),
        .clk_out1(clk_divided)
    );

    // 内部信号声明
    wire [31:0] instruction;
    wire nBranch, Branch, branch_lt, branch_ge, branch_ltu, branch_geu;
    wire jal, jalr, MemRead, MemorIOToReg, MemWrite, ALUSrc, RegWrite, sftmd;
    wire IORead, IOWrite;
    wire [3:0] ALUop;
    wire [31:0] read_data_1, read_data_2;
    wire [31:0] imm32;
    wire [31:0] Alu_result;
    wire zero;
    wire branch_result;
    wire [21:0] Alu_resultHigh = Alu_result[31:10];
    wire [31:0] mem_rdata;
    wire [31:0] addr_out;
    wire [31:0] r_wdata;
    wire [31:0] write_data;
    wire LEDCtrl, SwitchCtrl;
    wire [31:0] writeback_data;

    // 子模块实例化，使用 clk_divided

    IFetch ifetch (
        .clk(clk_divided),
        .rst(reset),
        .imm32(imm32),
        .branch_result(branch_result),
        .zero(zero),
        .jal(jal),
        .jalr(jalr),
        .Alu_result(Alu_result),
        .instruction(instruction),
        .pc_out(pc_current)
    );

    instruction_control ctrl (
        .instruction(instruction),
        .Alu_resultHigh(Alu_resultHigh),
        .nBranch(nBranch),
        .Branch(Branch),
        .branch_lt(branch_lt),
        .branch_ge(branch_ge),
        .branch_ltu(branch_ltu),
        .branch_geu(branch_geu),
        .jal(jal),
        .jalr(jalr),
        .MemRead(MemRead),
        .MemorIOToReg(MemorIOToReg),
        .ALUop(ALUop),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite),
        .sftmd(sftmd),
        .IORead(IORead),
        .IOWrite(IOWrite)
    );

    reg_and_imm regfile (
        .clk(clk_divided),
        .rst(reset),
        .inst(instruction),
        .write_data(writeback_data),
        .RegWrite(RegWrite),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .imm32(imm32)
    );

    ALU alu (
        .ALUop(ALUop),
        .ALUSrc(ALUSrc),
        .sftmd(sftmd),
        .Branch(Branch),
        .nBranch(nBranch),
        .Branch_lt(branch_lt),
        .Branch_ge(branch_ge),
        .Branch_ltu(branch_ltu),
        .Branch_geu(branch_geu),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .imm32(imm32),
        .Alu_result(Alu_result),
        .zero(zero),
        .branch_result(branch_result)
    );

    Data_mem data_memory (
        .clk(clk_divided),
        .m_read(MemRead),
        .m_write(MemWrite),
        .addr(addr_out),
        .d_in(write_data),
        .d_out(mem_rdata)
    );

    MemOrIO mem_io (
        .mRead(MemRead),
        .mWrite(MemWrite),
        .ioRead(IORead),
        .ioWrite(IOWrite),
        .addr_in(Alu_result),
        .addr_out(addr_out),
        .m_rdata(mem_rdata),
        .io_rdata(io_rdata),
        .r_wdata(r_wdata),
        .r_rdata(read_data_2),
        .write_data(write_data),
        .LEDCtrl(LEDCtrl),
        .SwitchCtrl(SwitchCtrl)
    );

    writeback_mux wb_mux (
        .MemorIOToReg(MemorIOToReg),
        .Alu_result(Alu_result),
        .r_wdata(r_wdata),
        .writeback_data(writeback_data)
    );

endmodule
