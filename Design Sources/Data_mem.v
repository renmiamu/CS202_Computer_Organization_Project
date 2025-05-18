module Data_mem (
    input clk,                  // 时钟
    input m_read,              // 读使能
    input m_write,             // 写使能
    input [31:0] addr,         // 地址输入
    input [31:0] d_in,         // 写入数据
    output reg [31:0] d_out    // 读出数据
);

    // 64KB = 16K words (word = 32-bit)
    reg [31:0] memory [0:16383];

    // --------------------------
    // 写入：同步（时钟边沿）
    // --------------------------
    always @(posedge clk) begin
        if (m_write) begin
            memory[addr[15:2]] <= d_in;
        end
    end

    // --------------------------
    // 读取：组合逻辑（异步）
    // --------------------------
    always @(*) begin
        if (m_read) begin
            d_out = memory[addr[15:2]];
        end else begin
            d_out = 32'b0;
        end
    end

    // --------------------------
    // 可选：初始化 memory 内容（仿真用）
    // --------------------------
    initial begin
        // $readmemh("data_mem.hex", memory); // 可选初始化文件
    end

endmodule
