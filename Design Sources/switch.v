module swtich (
    input clk,
    input rst,
    input SwitchCtrl,
    input [15:0] switch_input,
    input [31:0] address,
    input confirmation,
    output [15:0] reg data_IO_input
);
always @(negedge clk ) begin
    if (~rst) begin
        data_IO_input={16{1'b0}};
    end else if (SwitchCtrl && address == 32'hffff_ff00)begin      //16位直接输出（切换样例开关）
        data_IO_input <= switch_input;
    end else if (SwitchCtrl && address == 32'hffff_fff1)begin      //16位直接输出
        data_IO_input <= switch_input;
    end else if (SwitchCtrl && address == 32'hffff_fff3)begin      //8位符号扩展输出
        data_IO_input <= {{8{switch_input[15]}}, switch_input[15:8]};
    end else if (SwitchCtrl && address == 32'hffff_fff5)begin      //提取高8位输出（无符号）
        data_IO_input <= {8'b0, switch_input[15:8]};
    end else if (SwitchCtrl && address >= 32'hffff_fff9)begin      //提取低8位输出（无符号）
        data_IO_input<={8'b0, switch_input[7:0]};               
    end else if (SwitchCtrl && address == 32'hffff_fff7)begin      //提取低3位输出（获取测试编号要用）
        data_IO_input<={8'b0, switch_input[2:0]};
    end
end
    
endmodule