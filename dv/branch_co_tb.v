`timescale 1ns/1ps
`include "defines.vh"


module branch_co_tb();
    
    reg [31:0] data1;
    reg [31:0] data2;
    reg [2:0] opcode;
    wire branch_out;
    
    
    branch_comp dut(.data_in1(data1), .data_in2(data2), .opcode(opcode), .branch_out(branch_out));
    
    initial begin
        
        // data1 = data2
        data1 <= 32'h0F0F0F0F;
        data2 <= 32'h0F0F0F0F;
        #10;
        opcode <= `BEQ;
        #10;
        if(branch_out !=1)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BNE;
        #10;
        if(branch_out !=0)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BLT;
        #10;
        if(branch_out !=0)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BGE;
        #10;
        if(branch_out !=1)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BLTU;
        #10;
        if(branch_out !=0)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BGEU;
        #10;
        if(branch_out !=1)  begin
            $display("Failed");
            $stop;
            end
        #10;
        
        // data1 > data2
        data1 <= 32'h7F00FF00;
        data2 <= 32'h00FF00FF;
        #10;
        opcode <= `BEQ;
        #10;
        if(branch_out !=0)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BNE;
        #10;
        if(branch_out !=1)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BLT;
        #10;
        if(branch_out !=0)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BGE;
        #10;
        if(branch_out !=1)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BLTU;
        #10;
        if(branch_out !=0)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BGEU;
        #10;
        if(branch_out !=1)  begin
            $display("Failed");
            $stop;
            end
        #10;

        // data1 < data2
        data1 <= 32'h0000ffff;
        data2 <= 32'h0fff0000;
        #10;
        opcode <= `BEQ;
        #10;
        if(branch_out !=0) begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BNE;
        #10;
        if(branch_out !=1)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BLT;
        #10;
        if(branch_out !=1)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BGE;
        #10;
        if(branch_out !=0)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BLTU;
        #10;
        if(branch_out !=1)  begin
            $display("Failed");
            $stop;
            end
        #10;
        opcode <= `BGEU;
        #10;
        if(branch_out !=0)  begin
            $display("Failed");
            $stop;
            end
        #10;
        $display("All test cases passed");
        $finish;
    end
    
endmodule
