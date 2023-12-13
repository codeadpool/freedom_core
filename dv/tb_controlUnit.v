`timescale 1ns / 1ps

module tb_controlUnit;

   reg clk;
   reg rst;
   reg [31:0] instruction;
   reg branchOut;
   
   wire iMemRead;
   wire [6:0] opCode;
   wire [2:0] funct3;

   wire memPC, regWrite,
        dMemRead, dMemWrite, 
        aluSrcA, aluSrcB, aluOutDataSel;
        
   wire [1:0] pcSelect;
   wire [2:0] branchOp;
   wire [1:0] aluOp;
   
   wire [3:0] cstate;

   controlUnit dut (
        .clk(clk),
        .rst(rst),
        .opCode(opCode),
        .funct3(funct3),
        .iMemRead(iMemRead),
        .branchOut(branchOut),
        .memPC(memPC),
        .regWrite(regWrite),
        .cstate(cstate),
        .dMemRead(dMemRead),
        .dMemWrite(dMemWrite),
        .aluSrcA(aluSrcA),
        .aluSrcB(aluSrcB),
        .pcSelect(pcSelect),
        .branchOp(branchOp),
        .aluOp(aluOp),
        .aluOutDataSel(aluOutDataSel)     
    );
   
   
   initial clk = 0;
   always #5 clk = ~clk;

   initial begin
      rst = 1;
      #10 rst = 0; 
      instruction = 32'h002080B3;       // R-type 
      #45 instruction = 32'h00100093;   // I-type 
      
      #40 branchOut = 1;
      instruction = 32'h00D36363;       // B-type
      
      #40 instruction = 32'h02853623;   // S-type
      #40 instruction = 32'h00024803;   // L type
      #50 instruction = 32'hFFDFF06F;   // J-type 
      #30 instruction = 32'h00001217;   // AUIPC 
      #40 instruction = 32'h00001237;   // LUI


   end

endmodule

