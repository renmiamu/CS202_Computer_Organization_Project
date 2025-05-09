module swtich (
    input clk,
    input rst,
    input SwitchCtrl,
    input [15:0] switch_input,
    input [31:0] address,
    input confirmation,
    output reg [15:0] data_IO_input
);
always @(negedge clk ) begin
    if (~rst) begin
        data_IO_input={16{1'b0}};
    end else if (SwitchCtrl && address == 33'hffff_fff1)begin      //16λֱ�����
        data_IO_input <= switch_input;
    end else if (SwitchCtrl && address == 32'hffff_fff3)begin      //8λ������չ���
        data_IO_input <= {{8{switch_input[15]}}, switch_input[15:8]};
    end else if (SwitchCtrl && address == 32'hffff_fff5)begin      //��ȡ��8λ������޷��ţ�
        data_IO_input <= {8'b0, switch_input[15:8]};
    end else if (SwitchCtrl && address > 32'hffff_fff9)begin      //��ȡ��8λ������޷��ţ�
        data_IO_input<={8'b0, switch_input[7:0]};               
    end else if (SwitchCtrl && address == 32'hffff_fff7)begin      //��ȡ��3λ�������ȡ���Ա��Ҫ�ã�
        data_IO_input<={8'b0, switch_input[2:0]};
    end
end
    
endmodule