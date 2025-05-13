module IO (
    input clk,
    input rst,
    input switchCtrl,
    input [15:0] switchInput,
    input [31:0] address,
    input confirmation,
    input [31:0] writeData,      // data written to display
    output [15:0] dataIOInput,
    output [7:0] tubSel,
    output [7:0] tubLeft,
    output [7:0] tubRight
);

    wire [15:0] sw_data_out;

    switch sw(
        .clk(clk),
        .rst(rst),
        .switchCtrl(switchCtrl),
        .switchInput(switchInput),
        .address(address),
        .confirmation(confirmation),
        .dataIOInput(sw_data_out)
    );

    assign dataIOInput = sw_data_out;

    reg segWrite;
    reg [3:0] s1, s2, s3, s4, s5, s6, s7, s8;
    wire [7:0] led1, led2, led3, led4, led5, led6, led7, led8;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            s1 <= 4'd0; s2 <= 4'd0; s3 <= 4'd0; s4 <= 4'd0;
            s5 <= 4'd0; s6 <= 4'd0; s7 <= 4'd0; s8 <= 4'd0;
        end else if (segWrite) begin
            s1 <= writeData[31:28];
            s2 <= writeData[27:24];
            s3 <= writeData[23:20];
            s4 <= writeData[19:16];
            s5 <= writeData[15:12];
            s6 <= writeData[11:8];
            s7 <= writeData[7:4];
            s8 <= writeData[3:0];
        end
    end

    TubControl tub1(.data(s1), .lightSegment(led1));
    TubControl tub2(.data(s2), .lightSegment(led2));
    TubControl tub3(.data(s3), .lightSegment(led3));
    TubControl tub4(.data(s4), .lightSegment(led4));
    TubControl tub5(.data(s5), .lightSegment(led5));
    TubControl tub6(.data(s6), .lightSegment(led6));
    TubControl tub7(.data(s7), .lightSegment(led7));
    TubControl tub8(.data(s8), .lightSegment(led8));

    Tub tub (
        .clk(clk),
        .tub1(led1),
        .tub2(led2),
        .tub3(led3),
        .tub4(led4),
        .tub5(led5),
        .tub6(led6),
        .tub7(led7),
        .tub8(led8),
        .tubSel(tubSel),
        .tubLeft(tubLeft),
        .tubRight(tubRight)
    );

    always @(*) begin
        if (address == 32'hffff_fff0)
            segWrite = 1'b1;
        else
            segWrite = 1'b0;
    end

endmodule
