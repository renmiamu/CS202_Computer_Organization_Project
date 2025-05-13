module CPU_TOP (
    input clk,                    // 主时钟（100MHz）
    input rst,                    // 全局复位
    input enter,                  // 确认按键信号
    input [15:0] switchInput,     // 16位拨码开关输入
    output [7:0] tubSel,          // 数码管位选（哪个位被点亮）
    output [7:0] seg_led1234,     // 左4位数码管段选信号
    output [7:0] seg_led5678      // 右4位数码管段选信号
);

    // -------------------- 信号线连接 --------------------
    wire [15:0] io_rdata;         // IO输出给CPU的数据（输入）
    wire [15:0] io_wdata;         // CPU写给IO的数据（用于LED）
    wire [31:0] addr_out;         // 地址线
    wire [31:0] write_data;       // 数据线
    wire LEDCtrl;                 // 写IO控制信号
    wire SwitchCtrl;              // 读IO控制信号

    // -------------------- CPU 实例化 --------------------
    CPU cpu_core (
        .clk(clk),
        .reset(rst),
        .io_rdata(io_rdata),
        .io_wdata(io_wdata),
        .addr_out(addr_out),
        .write_data(write_data),
        .LEDCtrl(LEDCtrl),
        .SwitchCtrl(SwitchCtrl)
    );

    // -------------------- IO 实例化 --------------------
    IO io_module (
        .clk(clk),
        .rst(rst),
        .switchCtrl(SwitchCtrl),
        .switchInput(switchInput),
        .address(addr_out),
        .confirmation(enter),
        .writeData(write_data),
        .dataIOInput(io_rdata),
        .tubSel(tubSel),
        .tubLeft(seg_led1234),
        .tubRight(seg_led5678)
    );

endmodule
