module cpuclk (
    input wire clk_in1,
    output wire clk_out1
);
    
    reg clk_div;
    initial clk_div = 0;
    always #(22) clk_div = ~clk_div;
    assign clk_out1 = clk_div;
endmodule