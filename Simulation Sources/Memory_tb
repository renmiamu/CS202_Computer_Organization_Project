`timescale 1ns / 1ps
module Memory_tb;

    reg clk;
    reg rst;
    reg mRead;
    reg mWrite;
    reg [31:0] addr_in;
    reg [31:0] write_data;
    wire [31:0] m_rdata;

    // 实例化被测模块
    Memory uut (
        .clk(clk),
        .rst(rst),
        .mRead(mRead),
        .mWrite(mWrite),
        .addr_in(addr_in),
        .write_data(write_data),
        .m_rdata(m_rdata)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns 时钟周期
    end

    initial begin
        // 初始化
        rst = 1; mRead = 0; mWrite = 0;
        addr_in = 0;
        write_data = 0;
        #10 rst = 0;

        // 写入数据
        #10;
        addr_in = 32'h00000010;
        write_data = 32'h12345678;
        mWrite = 1;
        #10;
        mWrite = 0;

        // 读出数据
        #10;
        mRead = 1;
        #10;
        mRead = 0;

    
        // 再次写入新数据
        #10;
        addr_in = 32'h00000020;
        write_data = 32'hAABBCCDD;
        mWrite = 1;
        #10;
        mWrite = 0;

        // 读出新数据
        #10;
        addr_in = 32'h00000020;
        mRead = 1;
        #10;
        mRead = 0;

    end
endmodule
