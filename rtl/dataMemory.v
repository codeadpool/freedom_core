`timescale 1ns / 1ps
`include "defines.vh"

module dataMemory(
    input  clk, 
    input  rst, 
    input  readEnable,
    input  writeEnable,
    input  [3:0] writeByteSelect,
    input  [3:0] readByteSelect,
    input  [2:0] loadSelect,
    input  [31:0] address,
    input  [31:0] dataIn,
    output reg [31:0] dataOut
);

    localparam MEM_SIZE = 1024; // 4KB memory as 1024 locations of 32-bit each
    localparam BASE_ADDR = 32'h80000000; 
    
    localparam ADDR_ROM_1 = 32'h00100000; 
    localparam ADDR_ROM_2 = 32'h00100004; 

    localparam SURYA = 10338916; 
    localparam SAI   = 10452084; 

    reg [31:0] dataMemory [0:MEM_SIZE-1];
    reg [31:0] specialRom [0:1];

    initial begin
        specialRom[0] = SURYA;
        specialRom[1] = SAI;
    end
    
    integer i;
    always @(posedge clk) begin
        if (rst) begin
        end else begin
            if (readEnable) begin
                case (address)
                    ADDR_ROM_1: dataOut <= specialRom[0];
                    ADDR_ROM_2: dataOut <= specialRom[1];
                    default: if (address >= BASE_ADDR && address < BASE_ADDR + (MEM_SIZE << 2)) begin
                                // Adjusted memory addressing
                                if (readByteSelect == 4'b1111) begin
                                    dataOut <= dataMemory[(address - BASE_ADDR) >> 2];
                                end else begin
                                    // Byte-wise read handling
                                    dataOut <= 32'h0;
                                    if (readByteSelect[0]) dataOut[7:0]   <= dataMemory[(address - BASE_ADDR) >> 2][7:0];
                                    if (readByteSelect[1]) dataOut[15:8]  <= dataMemory[(address - BASE_ADDR) >> 2][15:8];
                                    if (readByteSelect[2]) dataOut[23:16] <= dataMemory[(address - BASE_ADDR) >> 2][23:16];
                                    if (readByteSelect[3]) dataOut[31:24] <= dataMemory[(address - BASE_ADDR) >> 2][31:24];
                                end
                             end else 
                                dataOut <= 32'hDEAD_BEEF; // Error code for invalid read
                endcase
            end

            if (writeEnable) begin
                if (address >= BASE_ADDR && address < BASE_ADDR + (MEM_SIZE << 2)) begin
                    // Adjusted memory addressing for writing
                    if(writeByteSelect == 4'b1111) begin
                        dataMemory[(address - BASE_ADDR) >> 2] <= dataIn;
                    end else begin
                        if (writeByteSelect[0]) 
                            dataMemory[(address - BASE_ADDR) >> 2][7:0]   <= dataIn[7:0];
                        if (writeByteSelect[1]) 
                            dataMemory[(address - BASE_ADDR) >> 2][15:8]  <= dataIn[15:8];
                        if (writeByteSelect[2]) 
                            dataMemory[(address - BASE_ADDR) >> 2][23:16] <= dataIn[23:16];
                        if (writeByteSelect[3]) 
                            dataMemory[(address - BASE_ADDR) >> 2][31:24] <= dataIn[31:24];
                    end        
                end
            end
        end
    end
endmodule
