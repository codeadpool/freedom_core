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
