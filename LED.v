module LED (
    input clk,
    input rst,
    input LEDCtrl,
    input [31:0] r_wdata,
    output reg [15:0] LED_output
);
always @(negedge clk ) begin
    if (!rst) begin
        LED_output={16{1'b0}};
    end else if (LEDCtrl) begin
        LED_output=r_wdata[15:0];
    end
end
    
endmodule