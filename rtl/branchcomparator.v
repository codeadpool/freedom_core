`timescale 1ns / 1ps
`include "defines.vh"

module branchComparator(
//    input wire clk,
    input wire [31:0] dataIn1, dataIn2,
    input wire [2:0] opCode,
    output reg branchOut
    );
 
    always@(*) begin
        case(opCode)
            `BEQ    : branchOut = (dataIn1 == dataIn2) ? 1:0;
            `BNE    : branchOut = (dataIn1 != dataIn2) ? 1:0;
            `BLT    : branchOut = ($signed(dataIn1) < $signed(dataIn2)) ? 1:0;
            `BGE    : branchOut = ($signed(dataIn1) >= $signed(dataIn2)) ? 1:0;
            `BLTU   : branchOut = (dataIn1 < dataIn2)? 1:0;
            `BGEU   : branchOut = (dataIn1 >= dataIn2)? 1:0;
             default: branchOut = 1'b0; 
        endcase
    end
 
endmodule