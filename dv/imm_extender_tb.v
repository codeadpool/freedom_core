`timescale 1ns / 1ps

module imm_extender_tb( );

    reg [31:0] instruction;
    wire [31:0] extended_imm;
    

    immediateExtender DUT(.instruction(instruction), .extended_imm(extended_imm));
   
   initial begin
        
         #10;
         // B
         instruction <= 32'h00D36363;      
         #10;
         if(extended_imm!=32'h00000006) begin
            $display("Failed Testcase 1");
            $stop;
            end
         #10;

         // U
         instruction <= 32'h800076B7;      
         #10;
         if(extended_imm!=32'h80007000) begin
            $display("Failed Testcase 2");
            $stop;
            end
         #10;

         // I
         instruction <= 32'h00106213;     
         #10;
         if(extended_imm!=32'h00000001) begin
            $display("Failed Testcase 3");
            $stop;
            end
         #10;

         // S         
         instruction <= 32'h02853623;      
         #10;
         if(extended_imm!=32'h0000002C) begin
            $display("Failed Testcase 4");
            $stop;
            end
         #10;

         // J
         instruction <= 32'h006303FF;      
         #10;
         if(extended_imm!=32'h00000000) begin
            $display("Failed Testcase 5");
            $stop;
            end
        
         $display("All test cases passed");
        $finish;
    end
endmodule
