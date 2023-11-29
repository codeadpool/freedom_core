`timescale 1ns/1ps
`include "defines.vh"

module dataExtender (
    input [31:0] data_in,
    input [2:0] opcode,
    output reg [31:0] data_out
);
    always@(*) begin
        case(opcode)
            // sign extension
            `LB     : data_out = {{24{data_in[7]}}, data_in[7:0]};  //byte
            `LH     : data_out = {{16{data_in[15]}}, data_in[15:0]};// halfword 16
            `LW     : data_out = data_in;                           // word
            
            // zero extension
            `LBU    : data_out = {{24{1'b0}}, data_in[7:0]};        // byte unsigned
            `LHU    : data_out = {{16{1'b0}}, data_in[15:0]};       // half word unsigned   
                   
            default : data_out = 32'd0;
        endcase
    end  
endmodule
    