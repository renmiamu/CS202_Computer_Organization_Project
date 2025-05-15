module cpuclk( //A division clock with a period of 10000
    input clk_in1,//built-in clock
    output reg clk_out1//Divided clock
    );
parameter period2 = 10000;
reg[24:0] cnt;
reg rst = 1'b0;
always@(posedge clk_in1)
begin
    if(~rst)begin
        cnt <= 0;
        clk_out1 <= 0;
        rst <= 1'b1;
end
else if (cnt == ((period2 >> 1) - 1)) begin
    clk_out1 <= ~clk_out1;
    cnt <= 0;
end
else begin
cnt<=cnt+1;
end
end
endmodule