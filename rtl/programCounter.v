`timescale 1ns / 1ps
`include "defines.vh"

module programCounter(
    input wire clk,
    input wire rst,
    input wire write_enable,        // Enable PC to be written unconditionally
    input wire PCWriteCond,         // Enable PC to be written conditionally
    input wire [1:0] PCSource,      // Determines the source of the next PC value
    input wire [31:0] ALUResult,    // The result from the ALU, used for branches
    input wire [25:0] JumpTarget,   // The jump target address bits [25:0] from the instruction
    input wire ZeroFlag,          
    output reg [31:0] pc,
    output reg halt 
);

    localparam [31:0] START_ADDRESS = 32'h01000000;
    localparam [31:0] UPPER_ADDRESS_LIMIT = 32'h01000FFC; 
    reg [31:0] next_pc;

    always @(posedge clk) begin
        if (rst) begin
            pc <= START_ADDRESS;
            halt <= 1'b0;
        end else begin
            // Determine the next PC based on PCSource
            case (PCSource)
                2'b00: next_pc = pc + 4; // Increment by 4 to get the next instruction address
                2'b01: next_pc = ALUResult; // Use the ALU result for branches
                2'b10: next_pc = {pc[31:28], JumpTarget << 2}; // Concatenate for jump addressing
                default: next_pc = pc + 4; 
            endcase
    
            // Word Alignment Check
            if (next_pc[1:0] !== 2'b00) begin
                halt <= 1'b1;
            end else if ((PCWriteCond && ZeroFlag) || write_enable) begin
                // Check if next PC is within the valid range
                if (next_pc > UPPER_ADDRESS_LIMIT || next_pc < START_ADDRESS) begin
                    halt <= 1'b1;
                end else begin
                    pc <= next_pc; 
                    halt <= 1'b0;
                end
            end
        end
    end

endmodule
