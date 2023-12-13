`timescale 1ns / 1ps
`include "defines.vh"

module dataMemory(
    input  clk,
    input  readEnable,
    input  writeEnable,
    input  [3:0]  writeByteSelect,
    input  [3:0]  readByteSelect,
    input  [31:0] address,
    input  [31:0] dataIn,
    output reg [31:0] dataOut,
    output invalidRead  // New signal to indicate invalid read
);

    localparam MEM_SIZE = 1024; // Memory size
    localparam ADDR_WIDTH = 10; // Address width to match MEM_SIZE
    localparam ADDR_ROM_1 = 32'h00100000;
    localparam ADDR_ROM_2 = 32'h00100004;

    localparam SURYA = 32'h009D8A0C; // Adjusted to 32-bit value
    localparam SAI   = 32'h009EFB4C; // Adjusted to 32-bit value

    reg [31:0] dataMemory [0:MEM_SIZE-1];
    reg [31:0] specialRom [0:1];

    initial begin
        $readmemh("dataMemory.mem", dataMemory);
        specialRom[0] = SURYA;
        specialRom[1] = SAI;
    end
    
    assign invalidRead = !(address >> 2 < MEM_SIZE);

    always @(posedge clk) begin
        if (readEnable) begin
            case (address)
                ADDR_ROM_1: dataOut <= specialRom[0];
                ADDR_ROM_2: dataOut <= specialRom[1];
                default: begin
                    if (address[ADDR_WIDTH+1:2] < MEM_SIZE) begin
                        dataOut <= {4{readByteSelect}} & dataMemory[address[ADDR_WIDTH+1:2]];
                    end else begin
                        dataOut <= 32'hDEAD_BEEF; // Error code for invalid read
                    end
                end
            endcase
        end
        
        if (writeEnable && |writeByteSelect) begin
            if (address[ADDR_WIDTH+1:2] < MEM_SIZE) begin
                for (int i = 0; i < 4; i++) begin
                    if (writeByteSelect[i]) begin
                        dataMemory[address[ADDR_WIDTH+1:2]][8*i +: 8] <= dataIn[8*i +: 8];
                    end
                end
            end
        end
    end
endmodule
