`timescale 1ns / 1ps
`include "defines.vh"

module programCounter(
    input wire clk, 
    input wire rst,
    input wire pcSelect,     
    input wire [31:0] aluResult,      
    output reg [31:0] pc,
    output reg halt 
);

    localparam [31:0] START_ADDRESS = 32'h01000000;
    localparam [31:0] UPPER_ADDRESS_LIMIT = 32'h01000FFC;

    always @(posedge clk) begin
        if (rst) begin
            pc <= START_ADDRESS;
            halt <= 1'b0;
        end else begin
            if (pcSelect) begin
                pc <= aluResult; 
            end else begin
                pc <= pc + 4; 
            end

            // Halt Conditions
            halt <= (pc[1:0] !== 2'b00) || (pc > UPPER_ADDRESS_LIMIT || pc < START_ADDRESS);
        end
    end

endmodule
