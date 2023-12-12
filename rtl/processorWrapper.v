`timescale 1ns / 1ps
`include "defines.vh"

module processorWrapper(
    input wire clk,
    input wire rst
);
    // Interconnect wires    
    // pc
    wire [31:0] pc;
    wire halt; 
       
    //imem
    wire [31:0] instruction;
    
    // decode
    wire [6:0] opcode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire signed [31:0] imm;
    
    //controlUnit
    wire readEnable; //for imem 
    wire [1:0] pcSelect;
    wire memPC, regWrite, dMemRead, dMemWrite, aluSrcB, aluSrcA, aluOutDataSel;
    wire [2:0] branchOp;
    wire [1:0] aluOp;
    wire [3:0] cstate;
    
    //branchComparator
    wire branchOut; 
    
    //alu 
    wire aluResult;

    programCounter pcModule(
        .clk(clk), 
        .rst(rst),
        .pcSelect(pcSelect),
        .aluResult(aluResult), 
        .pc(pc),
        .halt(halt)
    );

    instructionMemory instMem(
        .clk(clk), 
        .readEnable(readEnable),
        .address(pc),
        .instruction(instruction)
    );

    decoder decodeModule(
        .instruction(instruction),
        .clk(clk),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm)
    );

    controlUnit controlModule(
        .clk(clk), 
        .rst(rst),
        .instruction(instruction),
        .branchOut(branchOut),
        .pcSelect(pcSelect),
        .memPC(memPC),
        .regWrite(regWrite),
        .dMemRead(dMemRead),
        .dMemWrite(dMemWrite),
        .branchOp(branchOp),
        .aluSrcB(aluSrcB),
        .aluSrcA(aluSrcA),
        .aluOp(aluOp),
        .aluOutDataSel(aluOutDataSel),
        .cstate(cstate)
    );
endmodule

