module Memory (
    input wire clk,
    input wire rst,
    input wire mRead,                 // Memory Read Enable
    input wire mWrite,               // Memory Write Enable
    input wire [31:0] addr_in,       // Address from ALU
    input wire [31:0] write_data,    // Data from register file to be written
    output reg [31:0] m_rdata        // Data read from memory to be passed to MemOrIO
);

    // 4KB memory space, byte-addressable
    reg [7:0] mem_array [0:4095];

    integer i;

    // memory reset (clear all bytes)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < 4096; i = i + 1)
                mem_array[i] <= 8'b0;
        end else if (mWrite) begin
            // Write 32-bit word (little endian)
            mem_array[addr_in]     <= write_data[7:0];
            mem_array[addr_in + 1] <= write_data[15:8];
            mem_array[addr_in + 2] <= write_data[23:16];
            mem_array[addr_in + 3] <= write_data[31:24];
        end
    end

    // combinational read logic
    always @(*) begin
        if (mRead) begin
            m_rdata = {mem_array[addr_in + 3], mem_array[addr_in + 2],
                       mem_array[addr_in + 1], mem_array[addr_in]};
        end else begin
            m_rdata = 32'b0;
        end
    end

endmodule
