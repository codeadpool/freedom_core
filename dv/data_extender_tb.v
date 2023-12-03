`timescale 1ns/1ps
`include "defines.vh"
`default_nettype none

module dataExtender_tb();
    
    reg [2:0] opcode;
    reg [31:0] data_in;
    wire [31:0] data_out;
    
    dataExtender dut (.opcode(opcode), .data_in(data_in), .data_out(data_out));
    
    initial begin
        #5;
        data_in <= 32'h3456789A;
        opcode <= `LB;
        #10;
        if(data_out!=32'hffffff9A) begin
            $display("Failed Testcase 1");
            $stop;
            end
        #10;
        opcode <= `LH;
        #10;
        if(data_out!=32'h0000789A) begin
            $display("Failed Testcase 2");
            $stop;
            end
        #10;
        opcode <= `LW;
        #10;
        if(data_out!=32'h3456789A) begin
            $display("Failed Testcase 3");
            $stop;
            end
        #10;
        opcode <= `LBU;
        #10;
        if(data_out !=32'h0000009A) begin
            $display("Failed Testcase 4");
            $stop;
            end
        #10;
        opcode <= `LHU;
        #10;
        if(data_out!=32'h0000789A) begin
            $display("Failed Testcase 5");
            $stop;
            end
        #10;
        $display("All tests passed");
        $finish;
    end
    
endmodule
