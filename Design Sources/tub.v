module tub (
    input clk,
    input [7:0] tub_1, 
    input [7:0] tub_2,
    input [7:0] tub_3,
    input [7:0] tub_4,
    input [7:0] tub_5,
    input [7:0] tub_6,
    input [7:0] tub_7,
    input [7:0] tub_8,
    output reg [7:0] tub_sel,
    output reg [7:0] tub_left,
    output reg [7:0] tub_right
);
reg [2:0] count = 3'b000;
always @(posedge clk ) begin
    count<=count+1'b1;
    case (count)
        3'b000:begin
            tub_sel<=8'b1000_0000;
            tub_left<=tub_1;
        end
        3'b001:begin
            tub_sel<=8'b0100_0000;
            tub_left<=tub_2;
        end
        3'b010:begin
            tub_sel<=8'b0010_0000;
            tub_left<=tub_3;
        end
        3'b011:begin
            tub_sel<=8'b0001_0000;
            tub_left<=tub_4;
        end
        3'b100:begin
            tub_sel<=8'b0000_1000;
            tub_right<=tub_5;
        end
        3'b101:begin
            tub_sel<=8'b0000_0100;
            tub_right<=tub_6;
        end
        3'b110:begin
            tub_sel<=8'b0000_0010;
            tub_right<=tub_7;
        end
        3'b111:begin
            tub_sel<=8'b0000_0001;
            tub_right<=tub_8;
        end
    endcase
end
    
endmodule