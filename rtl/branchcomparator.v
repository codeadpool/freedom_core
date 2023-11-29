`timescale 1ns / 1ps
`include "defines.vh"

module branchComparator(
    input wire [31:0] data_in1, data_in2,
    input wire [2:0] opcode,
    output reg branch_out
    );
 
    always@(*) begin
        case(opcode)
            `BEQ    : branch_out = (data_in1==data_in2) ? 1:0;
            `BNE    : branch_out = (data_in1!=data_in2) ? 1:0;
            `BLT    : branch_out = ($signed(data_in1) < $signed(data_in2)) ? 1:0;
            `BGE    : branch_out = ($signed(data_in1) >= $signed(data_in2)) ? 1:0;
            `BLTU   : branch_out = (data_in1 < data_in2)? 1:0;
            `BGEU   : branch_out = (data_in1 >= data_in2)? 1:0;
             default: branch_out = 1'b0; 
        endcase
    end
 
endmodule