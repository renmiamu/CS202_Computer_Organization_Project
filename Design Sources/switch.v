module swtich (
    input clk,
    input rst,
    input SwitchCtrl,
    input [15:0] switch_input,
    input [31:0] address,
    input confirmation,
    output reg [15:0] data_IO_input
);
always @(negedge clk) begin
    if (~rst) begin
        data_IO_input <= 16'b0;
    end else if (SwitchCtrl) begin
        case (address)
            32'hffff_ff00: data_IO_input <= {15'b0, confirmation};                          //读取确认信号，最低位为confirmation
            32'hffff_fff1: data_IO_input <= switch_input;                                   // 读取完整16位拨码开关输�?
            32'hffff_fff3: data_IO_input <= {{8{switch_input[15]}}, switch_input[15:8]};    // 提取�?8位并符号扩展
            32'hffff_fff5: data_IO_input <= {8'b0, switch_input[15:8]};                     // 提取�?8位并零扩�?
            32'hffff_fff7: data_IO_input <= {8'b0, switch_input[2:0]};                      // 提取�?�?3位（用于测试编号�?
            32'hffff_fff9: data_IO_input <= {8'b0, switch_input[7:0]};                      // 提取�?�?8�?
            default: data_IO_input <= 16'b0;
        endcase
    end
end

    
endmodule