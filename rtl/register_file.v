`timescale 1ns / 1ps
module registerFile (

    input clk,
    input rst, 
    input writeEnable,
    input [4:0] readReg1,
    input [4:0] readReg2,
    input [4:0] writeReg,
    input [31:0] writeData,
    output [31:0] readData1,
    output [31:0] readData2
);

    integer i;
    reg [31:0] cpu_registers [0:31];
    
    // for easing simulation, declaring reg0 to 0
    initial begin
        cpu_registers[0] = 32'b0;
    end
    
    // hardwried reg0 to 0
    assign readData1 = (readReg1 != 0) ? cpu_registers[readReg1] : 32'b0;
    assign readData2 = (readReg2 != 0) ? cpu_registers[readReg2] : 32'b0;
    
    always @(posedge clk) begin
        if (rst) begin   
            for (i = 1; i < 32; i = i + 1) begin
                cpu_registers[i] <= 32'b0;
            end
        end else if (writeEnable && writeReg != 5'b0)
            cpu_registers[writeReg] <= writeData;
    end
endmodule
