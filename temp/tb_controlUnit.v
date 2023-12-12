`timescale 1ns / 1ps

module tb_control_unit;

   reg clk;
   reg rst;
   reg [31:0] instruction;

   wire branchOut, memPC, regWrite, iMemRead,
        dMemRead, dMemWrite, 
        aluSrcA, aluSrcB, aluOutDataSel,
   wire [1:0] pcSelect,
   wire [2:0] branchOp,
   wire [1:0] aluOp

   control_unit dut (
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .branchOut(branchOut),
        .memPC(memPC),
        .regWrite(regWrite),
        .iMemRead(iMemRead),
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

      #5 rst = 1;
      #10 rst = 0; instruction = 32'h002080B3; // R-type 
      #30 if(RegDst != 1 && RegWrite != 1 && MemtoReg != 0) begin 
         $display("R-type control failed");
      end else $display("R-type control successful");
      
      #5 rst = 1;
      #10 rst = 0; instruction = 32'h00100093; // I-type 
      #30 if(RegDst != 1 && RegWrite != 1 && MemtoReg != 0) begin 
         $display("I-type control failed");
      end else $display("I-type control successful");
      
      #5 rst = 1;
      #10 rst = 0; instruction = 32'h00D36363; // B-type
      #20 if(ALUSrcA != 1 && ALUSrcB != 2'b00 && ALUOp != 2'b01 && PCWriteCond != 1 && PCSource != 2'b01) begin
         $display("B-type control failed");
      end else $display("B-type control successful");
      
      #5 rst = 1;
      #10 rst = 0; instruction = 32'h02853623; // S-type
      #20 if(MemWrite !=1 && IorD != 1) begin
         $display("S-type control failed");
      end else $display("S-type control successful");

      #5 rst = 1;
      #10 rst = 0; instruction = 32'hFFDFF06F; // J-type 
      #20 if(PCWrite != 1 && PCSource != 2'b10) begin
         $display("J-type control failed");
      end else $display("J-type control successful");

      #5 rst = 1;
      #10 rst = 0; instruction = 32'h00001245; // U-type 
      #20 if(ALUOp != 11 && RegWrite != 1 && MemtoReg != 0 && RegDst != 1) begin
         $display("U-type control failed");
      end else $display("U-type control successful");

      $display("Test cases passed!"); 
      $finish;

   end

endmodule
