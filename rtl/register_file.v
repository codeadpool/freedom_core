`timescale 1ns / 1ps
module registerFile (
    input clk,
    input rst, 
    input writeEnable,
    input [4:0] readReg1,
    input [4:0] readReg2,
    input [4:0] writeReg,
    input [31:0] writeData,
    output reg [31:0] readData1,
    output reg [31:0] readData2
);

    integer i;
    reg [31:0] cpu_registers [0:31]; 
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin   
            for (i = 1; i <= 31; i = i + 1) begin
                cpu_registers[i] <= 32'b0;
            end
        end else if (writeEnable && writeReg != 0) begin
            cpu_registers[writeReg] <= writeData;
        end
    end

    always @(*) begin
        // Asynchronous read from registers
        readData1 = (readReg1 != 0) ? cpu_registers[readReg1] : 32'b0;
        readData2 = (readReg2 != 0) ? cpu_registers[readReg2] : 32'b0;
    end
endmodule
