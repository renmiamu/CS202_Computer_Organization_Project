module CPU (
    input wire clk,
    input wire rst,
    input wire [15:0] switch_in,
    output wire [15:0] led_out
);

    // Instruction Fetch
    wire [31:0] inst;
    wire [31:0] pc;
    wire branch, zero;
    wire [31:0] imm32;

    IFetch ifetch (
        .clk(clk),
        .rst(rst),
        .branch(branch),
        .zero(zero),
        .imm32(imm32),
        .inst(inst)
    );

    // Instruction Decode and Control
    wire ALUSrc, MemtoReg, RegWrite, MemRead, MemWrite, ioRead, ioWrite;
    wire [3:0] ALUOp;

    instruction_control controller (
        .inst(inst),
        .ALUSrc(ALUSrc),
        .MemtoReg(MemtoReg),
        .RegWrite(RegWrite),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .ioRead(ioRead),
        .ioWrite(ioWrite),
        .ALUOp(ALUOp),
        .branch(branch)
    );

    // Register and Immediate Decoder
    wire [31:0] reg_data1, reg_data2, imm;
    wire [4:0] rs1, rs2, rd;

    reg_and_imm decoder (
        .inst(inst),
        .clk(clk),
        .rst(rst),
        .RegWrite(RegWrite),
        .write_data(write_back_data),
        .data1(reg_data1),
        .data2(reg_data2),
        .imm32(imm32),
        .rs1(rs1), .rs2(rs2), .rd(rd)
    );

    // ALU
    wire [31:0] alu_b;
    wire [31:0] alu_result;

    assign alu_b = ALUSrc ? imm32 : reg_data2;

    ALU alu (
        .data1(reg_data1),
        .data2(alu_b),
        .ALUOp(ALUOp),
        .result(alu_result),
        .zero(zero)
    );

    // Memory and IO
    wire [31:0] m_rdata;
    wire [31:0] addr_out, write_data, reg_write_data;
    wire [15:0] io_rdata;
    wire LEDCtrl, SwitchCtrl;

    Memory data_mem (
        .clk(clk),
        .rst(rst),
        .mRead(MemRead),
        .mWrite(MemWrite),
        .addr_in(addr_out),
        .write_data(write_data),
        .m_rdata(m_rdata)
    );

    MemOrIO memorio (
        .mRead(MemRead),
        .mWrite(MemWrite),
        .ioRead(ioRead),
        .ioWrite(ioWrite),
        .addr_in(alu_result),
        .addr_out(addr_out),
        .m_rdata(m_rdata),
        .io_rdata(io_rdata),
        .r_wdata(reg_write_data),
        .r_rdata(reg_data2),
        .write_data(write_data),
        .LEDCtrl(LEDCtrl),
        .SwitchCtrl(SwitchCtrl)
    );

    LED led (
        .ledctrl(LEDCtrl),
        .write_data(write_data),
        .clk(clk),
        .rst(rst),
        .led_out(led_out)
    );

    switch sw (
        .switchctrl(SwitchCtrl),
        .clk(clk),
        .rst(rst),
        .switch_in(switch_in),
        .switch_out(io_rdata)
    );

    // Writeback mux
    wire [31:0] write_back_data;

    writeback_mux wb_mux (
        .MemtoReg(MemtoReg),
        .alu_result(alu_result),
        .mem_result(reg_write_data),
        .write_data(write_back_data)
    );

endmodule
