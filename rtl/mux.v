`timescale 1ns / 1ps

module mux(
    input wire [31:0] in1, in2,
    output wire [31:0] muxOut,
    input wire select
    );
    assign muxOut = select ? in2 : in1;
endmodule
