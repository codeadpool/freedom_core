`timescale 1ns / 1ps
`include "defines.vh"

module processorWrapper(
    input wire clk,
    input wire rst,
    
    output wire [31:0] pc,
    output wire [31:0] instruction,
    output wire [3:0] cstate
);
    // Interconnect wires    
    // pc
    wire [31:0] incPC;
    wire halt; 
          
    // decode
    wire [6:0] opCode;
    wire [4:0] rs1, rs2, rd;
    wire [2:0] funct3;
    wire [6:0] funct7;
    wire signed [31:0] imm;
    
    //controlUnit
    wire iMemRead; 
    wire [1:0] pcSelect;
    wire memPC, regWrite, dMemRead, dMemWrite, aluSrcB, aluSrcA, aluOutDataSel;
    wire [3:0] dMemByteRead, dMemByteWrite;
    wire [2:0] branchOp;
    wire [1:0] aluOp;
    
    //aluContrl
    wire [3:0] aluCtl;
    
    //registerFile
    wire [31:0] readData1, readData2;
   
    //branchComparator
    wire branchOut; 
    
    //muxes
    wire [31:0] aluDataIn1, aluDataIn2;
    
    //alu 
    wire [31:0] aluResult;
    
    //dataMemory
    wire [31:0] dMemOut;
    
    wire [31:0] regWriteData, dataAluMux;
    
    assign incPC = pc+4;
    
    programCounter pcm(
        .clk            (clk), 
        .rst            (rst),
        .pcSelect       (pcSelect),
        .aluResult      (aluResult),
        .incPC          (incPC), 
        .pc             (pc),
        .halt           (halt)
    );

    instructionMemory imem(
        .clk            (clk), 
        .readEnable     (iMemRead),
        .address        (pc),
        .instruction    (instruction)
    );

    decoder dm(
        .instruction    (instruction),
        .opCode         (opCode),
        .rs1            (rs1),
        .rs2            (rs2),
        .rd             (rd),
        .funct3         (funct3),
        .funct7         (funct7),
        .imm            (imm)
    );

    controlUnit cm(
        .clk            (clk), 
        .rst            (rst),
        .funct3         (funct3),
        .opCode         (opCode),
        .iMemRead       (iMemRead),
        .branchOut      (branchOut),
        .pcSelect       (pcSelect),
        
        .regWrite       (regWrite),
        .dMemRead       (dMemRead),
        .dMemWrite      (dMemWrite),
        .dMemByteRead   (dMemByteRead),
        .dMemByteWrite  (dMemByteWrite),
        .branchOp       (branchOp),
        .aluOp          (aluOp),
        
        .aluSrcB        (aluSrcB),
        .aluSrcA        (aluSrcA),
        .aluOutDataSel  (aluOutDataSel),
        .memPC          (memPC),
        .cstate         (cstate)
    );
    
    aluControl alc(
        .aluOp          (aluOp),
        .opCode         (opCode),
        .funct7         (funct7),
        .funct3         (funct3),
        .aluCtl         (aluCtl)
    );
    
    registerFile rf(
        .clk            (clk),
        .rst            (rst),
        .writeEnable    (regWrite),
        .readReg1       (rs1),
        .readReg2       (rs2),
        .writeReg       (rd),
        .writeData      (regWriteData), // connected via mux
        .readData1      (readData1),
        .readData2      (readData2)
    );
    
    branchComparator bc( 
        .dataIn1        (readData1), // rega and regb
        .dataIn2        (readData2),
        .opCode         (branchOp),
        .branchOut      (branchOut)
    );
    
    assign aluDataIn1 = (aluSrcA) ? readData1 : pc;     // alu A mux 
    assign aluDataIn2 = (aluSrcB) ? imm  : readData2;   // alu B mux

    alu al(
        .operand1       (aluDataIn1),
        .operand2       (aluDataIn2),
        .operation      (aluCtl),
        .result         (aluResult)
    );
    
    dataMemory dmem(
        .clk            (clk),
        .rst            (rst),
        .readEnable     (dMemRead),
        .writeEnable    (dMemWrite),
        .readByteSelect (dMemByteRead),
        .writeByteSelect(dMemByteWrite),
        .loadSelect     (funct3),
        .address        (aluResult),
        .dataIn         (readData2), 
        .dataOut        (dMemOut)   
    );
    
    assign dataAluMux   = (aluOutDataSel) ? dMemOut : aluResult; // data or aluResult MUX   
    assign regWriteData = (memPC) ? dataAluMux : incPC;   
endmodule

