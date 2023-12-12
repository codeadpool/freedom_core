`timescale 1ns / 1ps
module tb_processorWrapper;
    reg clk, rst;
    wire [31:0] pc;
    wire [31:0] instruction;
    wire iMemRead;
    wire [3:0] cstate;
    wire [1:0] pcSelect;
    
    processorWrapper pw(
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .instruction(instruction),
        .iMemRead(iMemRead),
        .cstate(cstate),
        .pcSelect(pcSelect)
    );
    
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
    end

endmodule
