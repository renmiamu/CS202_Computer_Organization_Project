module MemOrIO (
    input mRead,
    input mWrite, // write memory, from Controller
    input ioRead, // read IO, from Controller
    input ioWrite, // write IO, from Controller
    input[31:0] addr_in, // from alu_result in ALU
    output[31:0] addr_out, // address to Data-Memory
    input[31:0] m_rdata, // data read from Data-Memory
    input[15:0] io_rdata, // data read from IO,16 bits
    output[31:0] r_wdata, // data to Decoder(register file)
    input[31:0] r_rdata, // data read from Decoder(register file)
    output reg[31:0] write_data, // data to memory or I/O（m_wdata, io_wdata）
    output LEDCtrl, // LED Chip Select
    output SwitchCtrl // Switch Chip Select
);
assign addr_out=addr_in;
always @(*) begin
    if (ioRead)begin
        SwitchCtrl=1'b1;
    end else begin
        SwitchCtrl=1'b0;
    end

    if (ioWrite) begin
        LEDCtrl=1'b1;
    end else begin
        LEDCtrl=1'b0;
    end

    if (mRead) begin
        r_wdata=m_rdata;
    end else if (ioRead) begin
        if (io_rdata[15]==1'b1) begin
            r_wdata={{16{1'b1}},io_rdata};
        end else begin
            r_wdata={{16{1'b0}},io_rdata};
        end
    end

    if ((mWrite==1)||(ioWrite==1))begin
        write_data=r_rdata;
    end else begin
        write_data=32'hZZZZZZZZ;
    end
end

    
endmodule