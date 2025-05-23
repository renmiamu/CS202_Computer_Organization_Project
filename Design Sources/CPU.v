module CPU (
    input clk,                  // 原始时钟 100MHz
    input reset,                // 全局复位
    input [15:0] switchInput,   // 来自拨码开关的输入
    input enter,         // 模拟确认按键
    input start_pg,     //recieve data by UART
    input rx,           //send data by UART

    output tx,
    output [7:0] tubSel,        // 数码管位选
    output [7:0] seg_led1234,       // 左侧段选
    output [7:0] seg_led5678,      // 右侧段选
    output [15:0] dataOut,
    output [3:0] r,
    output [3:0] g,
    output [3:0] b,
    output hs,
    output vs
//    output [31:0] instruction,
//    output branch_result,
//    output Branch,
//    output [31:0] read_data_1,read_data_2,
//    output [31:0] imm32,
//    output [15:0] sw_data_out,
//    output [31:0] addr_out,
//    output [31:0] Alu_result
);
    wire clk_divided;
    wire clk_out2;

    cpuclk clk_divider (
        .clk_in1(clk),
        .clk_out1(clk_divided),
        .clk_out2(clk_out2)
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
    wire zero, branch_result;
//    wire zero;
//    wire nBranch, branch_lt, branch_ge, branch_ltu, branch_geu;
     wire nBranch, Branch, branch_lt, branch_ge, branch_ltu, branch_geu;
    wire jal, jalr, MemRead, MemorIOToReg, MemWrite, ALUSrc, RegWrite, sftmd;
    wire IORead, IOWrite;
    wire [3:0] ALUop;

    wire [31:0] pc_current;
    
    wire [31:0] instruction;
    wire a7;
    
    // UART 编程控制模块（IP核）
    wire        upg_clk, upg_wen;
    wire [14:0] upg_adr;
    wire [31:0] upg_dat;
    wire        upg_done;
    
    // BUFG 生成的同步复位信号（防止毛刺）
    wire spg_bufg;
    BUFG U1 (.I(start_pg), .O(spg_bufg));
    
    // UART reset 逻辑
    reg upg_rst;
    always @(posedge clk) begin
        if (reset)          upg_rst <= 1;
        else if (spg_bufg) upg_rst <= 0;
    end
    
    uart_bmpg_0 uart_prog (
        .upg_clk_i(clk_out2),   // 你分频后提供的10MHz时钟
        .upg_rst_i(upg_rst),
        .upg_rx_i(rx),
        .upg_clk_o(upg_clk),
        .upg_wen_o(upg_wen),
        .upg_adr_o(upg_adr),
        .upg_dat_o(upg_dat),
        .upg_done_o(upg_done),
        .upg_tx_o(tx)
    );

    
    wire rst = reset | ~upg_rst;
    wire kickOff = upg_rst | (~upg_rst & upg_done);


    // ---------- IF ----------
    IFetch ifetch (
        .clk(clk_divided),
        .rst(rst),
        .imm32(imm32),
        .branch_result(branch_result),
        .zero(zero),
        .jal(jal),
        .jalr(jalr),
        .Alu_result(Alu_result),
    
        .upg_rst(upg_rst),
        .upg_clk(upg_clk),
        .upg_wen_o(upg_wen),
        .upg_adr_o(upg_adr),
        .upg_dat_o(upg_dat),
        .upg_done_o(upg_done),
    
        .instruction(instruction),
        .pc_out(pc_current)
    );

    // ---------- 控制器 ----------
    instruction_control ctrl (
        .instruction(instruction),
        .Alu_result(Alu_result),
        .a7(a7),
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
        .rst(rst),
        .inst(instruction),
        .write_data(writeback_data),
        .RegWrite(RegWrite),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .imm32(imm32),
        .a7(a7)
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
        .d_in(r_wdata),
        .d_out(mem_rdata),
    
        .upg_rst_i(upg_rst),
        .upg_clk_i(upg_clk),
        .upg_wen_i(upg_wen),
        .upg_adr_i(upg_adr[13:0]),
        .upg_dat_i(upg_dat),
        .upg_done_i(upg_done)
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
        .clk(~clk_divided),
        .rst(rst),
        .switchCtrl(SwitchCtrl),
        .r_wdata(r_wdata),
        .LEDCtrl(LEDCtrl),
        .switchInput(switchInput),
        .address(addr_out),
        .confirmation(enter),
        .writeData(write_data),
        .dataIOInput(io_rdata),
        .tubSel(tubSel),
        .tubLeft(seg_led1234),
        .tubRight(seg_led5678),
        .dataOut(dataOut)
    );

endmodule
