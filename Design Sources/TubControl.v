module TubControl (
    input [3:0] data,
    output reg [7:0] lightSegment
);
always @(*) begin
    case (data)
        4'b0000:begin
            lightSegment=8'b1111110;
        end
        4'b0001:begin
            lightSegment=8'b0110000;
        end
        4'b0010:begin
            lightSegment=8'b1101101;
        end
        4'b0011:begin
            lightSegment=8'b11110010;
        end
        4'b0100:begin
            lightSegment=8'b01100110;
        end
        4'b0101:begin
            lightSegment=8'b10110110;
        end
        4'b0110:begin
            lightSegment=8'b10111110;
        end
        4'b0111:begin
            lightSegment=8'b11100000;
        end
        4'b1000:begin
            lightSegment=8'b11111110;
        end
        4'b1001:begin
            lightSegment=8'b11110110;
        end
        4'b1010:begin
            lightSegment=8'b11101110;    //A
        end
        4'b1011:begin
            lightSegment=8'b00111110;    //b
        end
        4'b1100:begin
            lightSegment=8'b10011100;    //C
        end
        4'b1101:begin
            lightSegment=8'b01111010;    //d
        end
        4'b1110:begin
            lightSegment=8'b10011110;    //E
        end
        4'b1111:begin
            lightSegment=8'b10001110;   //F
        end
        default:lightSegment=8'b11111111;         
    endcase
end
endmodule