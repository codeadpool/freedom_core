`timescale 1ns / 1ps
`include "defines.vh"

module programCounter(
    input wire clk,
    input wire rst,
    input wire write_enable,
    input wire immediate,
    input wire [31:0] immediate_address,
    output reg [31:0] pc
);

    localparam [31:0] START_ADDRESS = 32'h01000000;
    reg [31:0] next_pc;

    always @(posedge clk) begin
        if (rst) begin
            pc <= START_ADDRESS;
        end else if (write_enable) begin
            if (immediate) begin
                next_pc = immediate_address & ~32'h3; //  alignment to 4-byte boundary
            end else begin
                next_pc = pc + 4; // Incremenr by 4 to get the next instruction address
            end
            pc <= next_pc;
        end
    end

endmodule


`timescale 1ns / 1ps
`include "defines.vh"

module programCounter(
    input wire clk,
    input wire rst,
    input wire PCWrite, // This signal enables the PC to be written
    input wire PCWriteCond, // This signal enables the PC to be written conditionally
    input wire [1:0] PCSource, // Determines the source of the next PC value
    input wire [31:0] ALUResult, // The result from the ALU, used for branches and jumps
    input wire [31:0] JumpAddr, // The address to jump to for JAL and JALR
    input wire ZeroFlag, // Zero flag from the ALU, used for conditional branches
    output reg [31:0] pc
);

    localparam [31:0] START_ADDRESS = 32'h01000000;
    reg [31:0] next_pc;

    always @(posedge clk) begin
        if (rst) begin
            pc <= START_ADDRESS;
        end else begin
            case (PCSource)
                2'b00: next_pc = pc + 4;
                2'b01: next_pc = ALUResult;         // Branches: use the ALU result
                2'b10, 2'b11: next_pc = JumpAddr;   // Jumps: use the jump address
                default: next_pc = pc + 4;          
            endcase

            // Check if the PC should be written conditionally (for branches)
            if (PCWriteCond && ZeroFlag) begin
                pc <= next_pc;
            end else if (PCWrite) begin
                // Or if the PC should be written unconditionally (for jumps)
                pc <= next_pc;
            end
            // If neither write enable is active, the PC does not change
        end
    end

endmodule

