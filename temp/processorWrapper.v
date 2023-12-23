`timescale 1ns / 1ps
`include "defines.vh"

module processorWrapper(
    input wire clk,
    input wire rst,   
    input wire [15:0] sw,
    output wire [15:0] leds
);
    // Interconnect wires    
    // pc
    (* keep = "true" *) wire [31:0] incPC;
    (* keep = "true" *) wire halt; 
          
    // decode
    (* keep = "true" *) wire [6:0] opCode;
    (* keep = "true" *) wire [4:0] rs1, rs2, rd;
    (* keep = "true" *) wire [2:0] funct3;
    (* keep = "true" *) wire [6:0] funct7;
    (* keep = "true" *) wire signed [31:0] imm;
    
    //controlUnit
    (* keep = "true" *) wire iMemRead; 
    (* keep = "true" *) wire [1:0] pcSelect;
    (* keep = "true" *) wire memPC, regWrite, dMemRead, aluSrcB, aluSrcA, aluOutDataSel;
    (* keep = "true" *) wire [3:0] dMemByteWrite;
    (* keep = "true" *) wire [2:0] branchOp;
    (* keep = "true" *) wire [1:0] aluOp;
    
    //aluContrl
    (* keep = "true" *) wire [3:0] aluCtl;
    
    //registerFile
    (* keep = "true" *) wire [31:0] readData1, readData2;
   
    //branchComparator
    (* keep = "true" *) wire branchOut; 
    
    //muxes
    (* keep = "true" *) wire [31:0] aluDataIn1, aluDataIn2;
    
    //alu 
    (* keep = "true" *) wire [31:0] aluResult;
    
    //dataMemory
    (* keep = "true" *) wire [31:0] dMemOut; 
//    wire [15:0] sw, leds;
    
    (* keep = "true" *) wire [31:0] regWriteData, dataAluMux;
    (* keep = "true" *) wire [31:0] pc;
    (* keep = "true" *) wire [31:0] instruction;
    (* keep = "true" *) wire [3:0] cstate;
    
    (* keep_hierarchy = "yes" *) assign incPC = pc+4;
    
    (* keep_hierarchy = "yes" *) programCounter pcm(
        .clk            (clk), 
        .rst            (rst),
        .pcSelect       (pcSelect),
        .aluResult      (aluResult),
        .incPC          (incPC), 
        .pc             (pc),
        .halt           (halt)
    );

    (* keep_hierarchy = "yes" *) instructionMemory imem(
        .clk            (clk), 
        .readEnable     (iMemRead),
        .address        (pc),
        .instruction    (instruction)
    );

    (* keep_hierarchy = "yes" *) decoder dm(
        .instruction    (instruction),
        .opCode         (opCode),
        .rs1            (rs1),
        .rs2            (rs2),
        .rd             (rd),
        .funct3         (funct3),
        .funct7         (funct7),
        .imm            (imm)
    );

    (* keep_hierarchy = "yes" *) controlUnit cm(
        .clk            (clk), 
        .rst            (rst),
        .funct3         (funct3),
        .opCode         (opCode),
        .iMemRead       (iMemRead),
        .branchOut      (branchOut),
        .pcSelect       (pcSelect),       
        .regWrite       (regWrite),

        .dMemRead       (dMemRead),       
        .dMemByteWrite  (dMemByteWrite),

        .branchOp       (branchOp),
        .aluOp          (aluOp),       
        .aluSrcB        (aluSrcB),
        .aluSrcA        (aluSrcA),
        .aluOutDataSel  (aluOutDataSel),
        .memPC          (memPC),
        .cstate         (cstate)
    );
    
    (* keep_hierarchy = "yes" *) aluControl alc(
        .aluOp          (aluOp),
        .opCode         (opCode),
        .funct7         (funct7),
        .funct3         (funct3),
        .aluCtl         (aluCtl)
    );
    
    (* keep_hierarchy = "yes" *) registerFile rf(
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
    
    (* keep_hierarchy = "yes" *) branchComparator bc( 
        .dataIn1        (readData1), // rega and regb
        .dataIn2        (readData2),
        .opCode         (branchOp),
        .branchOut      (branchOut)
    );
    
//    (* mux_style = "select" *) assign aluDataIn1 = (aluSrcA) ? readData1 : pc;     // alu A mux
    mux ad1 (
        .select (aluSrcA),
        .in1(pc),
        .in2(readData1),
        .muxOut(aluDataIn1) 
    );
    
//    (* mux_style = "select" *) assign aluDataIn2 = (aluSrcB) ? imm  : readData2;   // alu B mux
    mux ad2 (
        .select (aluSrcB),
        .in1(readData2),
        .in2(imm),
        .muxOut(aluDataIn2) 
    );

    (* keep_hierarchy = "yes" *) alu al(
        .operand1       (aluDataIn1),
        .operand2       (aluDataIn2),
        .operation      (aluCtl),
        .result         (aluResult)
    );
    
    (* keep_hierarchy = "yes" *) dataMemory dmem(
        .clk            (clk),
        .rst            (rst),

        .readEnable     (dMemRead),
        .writeByteSelect(dMemByteWrite),

        .loadSelect     (funct3),
        .address        (aluResult),
        .dataIn         (readData2), 
        .dataOut        (dMemOut),
        .sw             (sw),
        .leds           (leds)   
    );
    
//    (* mux_style = "select" *) assign dataAluMux   = (aluOutDataSel) ? dMemOut : aluResult; // data or aluResult MUX       
    mux dam (
        .select (aluOutDataSel),
        .in1(aluResult),
        .in2(dMemOut),
        .muxOut(dataAluMux) 
    );
//    (* mux_style = "select" *) assign regWriteData = (memPC) ? dataAluMux : incPC;
    
    mux rwd (
        .select (memPC),
        .in1(incPC),
        .in2(dataAluMux),
        .muxOut(regWriteData) 
    );   
endmodule

