module CPU (
    input clk,                  // 原始时钟 100MHz
    input reset,                // 全局复位
    input [15:0] switchInput,   // 来自拨码开关的输入
    input confirmation,         // 模拟确认按键

    output [7:0] tubSel,        // 数码管位选
    output [7:0] tubLeft,       // 左侧段选
    output [7:0] tubRight,      // 右侧段选
    output [31:0] instruction   // 输出当前指令用于调试
);

    wire clk_divided;

    cpuclk clk_divider (
        .clk_in1(clk),
        .clk_out1(clk_divided)
    );

    // ---------- 中间信号 ----------
    wire [15:0] io_rdata;
    wire [15:0] io_wdata;
    wire [31:0] addr_out;
    wire [31:0] write_data;
    wire LEDCtrl;
    wire SwitchCtrl;

    wire [31:0] Alu_result;
    wire [31:0] mem_rdata;
    wire [31:0] r_wdata;
    wire [31:0] writeback_data;
    wire [31:0] read_data_1, read_data_2;
    wire [31:0] imm32;
    wire [21:0] Alu_resultHigh = Alu_result[31:10];
    wire zero, branch_result;

    wire nBranch, Branch, branch_lt, branch_ge, branch_ltu, branch_geu;
    wire jal, jalr, MemRead, MemorIOToReg, MemWrite, ALUSrc, RegWrite, sftmd;
    wire IORead, IOWrite;
    wire [3:0] ALUop;

    wire [31:0] pc_current;

    // ---------- IF ----------
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

    // ---------- 控制器 ----------
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

    // ---------- 寄存器与立即数 ----------
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

    // ---------- ALU ----------
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

    // ---------- 数据存储器 ----------
    Data_mem data_memory (
        .clk(clk_divided),
        .m_read(MemRead),
        .m_write(MemWrite),
        .addr(addr_out),
        .d_in(write_data),
        .d_out(mem_rdata)
    );

    // ---------- 内存和IO仲裁器 ----------
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

    // ---------- 写回多路选择器 ----------
    writeback_mux wb_mux (
        .MemorIOToReg(MemorIOToReg),
        .Alu_result(Alu_result),
        .r_wdata(r_wdata),
        .pc_out(pc_current),
        .jal(jal),
        .writeback_data(writeback_data)
    );

    // ---------- IO 模块实例化 ----------
    IO io_module (
        .clk(clk_divided),
        .rst(reset),
        .switchCtrl(SwitchCtrl),
        .switchInput(switchInput),
        .address(addr_out),
        .confirmation(confirmation),
        .writeData(write_data),
        .dataIOInput(io_rdata),
        .tubSel(tubSel),
        .tubLeft(tubLeft),
        .tubRight(tubRight)
    );

endmodule
