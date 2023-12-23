`timescale 1ns / 1ps
`include "defines.vh"

module dataMemory(
    input clk, 
    input rst, 
    input writeEnable,  
    input [3:0] writeByteSelect,
    input [31:0] address,
    input [31:0] dataIn,
    output [31:0] dataOut,
    input [15:0] sw,
    output reg [15:0] leds
);

    localparam MEM_SIZE = 1024;
    localparam BASE_ADDR = 32'h80000000;    

    localparam ADDR_ROM_1 = 32'h00100000,
               ADDR_ROM_2 = 32'h00100004,
               ADDR_SW    = 32'h00100010, 
               ADDR_LEDS  = 32'h00100014; 

    localparam DATA_MEMORY_BLOCK = 0,
               SWITCH_BLOCK = 1,
               LED_BLOCK = 2,
               INVALID_BLOCK = 3;

    localparam SURYA = 10338916; 
    localparam SAI   = 10452084; 

    (* ram_style = "block" *) reg [31:0] dataMemory [0:MEM_SIZE-1];
    reg [31:0] specialRom [0:1];
    
    wire [31:0] translAddress = (address - BASE_ADDR) >> 2;
    
    reg [31:0] switches, dataOutTemp;
    assign dataOut = dataOutTemp;
    
    wire [1:0] currentBlock;
    assign currentBlock = (address >= BASE_ADDR && address < BASE_ADDR + (MEM_SIZE << 2)) ? DATA_MEMORY_BLOCK :
                          (address == ADDR_SW) ? SWITCH_BLOCK :
                          (address == ADDR_LEDS) ? LED_BLOCK : INVALID_BLOCK;
    
    initial begin
        specialRom[0] = SURYA;
        specialRom[1] = SAI;
        $readmemh("defaultDMemSet.mem", dataMemory);
        leds <= 16'h0000;
    end

    always @(posedge clk) begin
        switches <= sw;
        if (rst) begin  
        end 
        else if (writeEnable && currentBlock == DATA_MEMORY_BLOCK) begin            
            case (writeByteSelect)
                4'b0001: dataMemory[translAddress] <= (dataIn & 32'h000000FF);
                4'b0011: dataMemory[translAddress] <= (dataIn & 32'h0000FFFF);
                4'b1111: dataMemory[translAddress] <= dataIn;
                default: dataMemory[translAddress] <= dataIn; // Default case
            endcase
        end 

        else if (currentBlock == DATA_MEMORY_BLOCK) begin
            dataOutTemp <= dataMemory[translAddress];
        end

        else if (currentBlock == SWITCH_BLOCK) begin
            dataOutTemp <= switches;
        end 
    end

    always @(*) begin
        if (currentBlock == LED_BLOCK && writeEnable) begin
            leds <= dataIn[15:0];
        end
        // else if (currentBlock == SWITCH_BLOCK) begin
        //     dataOutTemp <= switches;
        // end 
    end
endmodule






