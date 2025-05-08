module Data_mem(
    input clk,
    input m_read, m_write,
    input [31:0] addr,
    input [31:0] d_in,
    output [31:0] d_out
);

RAM udram(
    .clka(clk),
    .wea(m_write),
    .addra(addr[13:0]),
    .dina(d_in),
    .douta(d_out)
);

endmodule
