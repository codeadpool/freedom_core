`timescale 1ns / 1ps
module tb_processorWrapper;
    reg clk, rst;
    wire [31:0] pc;
    wire [31:0] instruction;
    wire iMemRead;
    wire [3:0] cstate;
    wire [1:0] pcSelect;
    wire [6:0] opCode;
//    wire decodeEnable;
    wire [4:0] rs1, rs2, rd;
    wire branchOut;
    wire [31:0] aluResult;
    wire halt;
    wire [31:0] aluDataIn1, aluDataIn2;
    
    processorWrapper pw(
        .clk(clk),
        .rst(rst),
        .pc(pc),
//        .decodeEnable(decodeEnable),
        .instruction(instruction),
        .iMemRead(iMemRead),
        .cstate(cstate),
        .pcSelect(pcSelect),
        .opCode(opCode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .branchOut(branchOut),
        .halt(halt),
        .aluResult(aluResult),
        .aluDataIn1(aluDataIn1),
        .aluDataIn2(aluDataIn2)
    );
    
    always #5 clk = ~clk;
    initial begin
        clk = 0;
        rst = 1;
        #10 rst = 0;
    end

endmodule
