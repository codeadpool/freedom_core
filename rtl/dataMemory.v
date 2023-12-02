`timescale 1ns / 1ps
`include "defines.vh"

module dataMemory(
    input  clk, 
    input  rst, 
    input  read_enable,
    input  [3:0]  write_byte_select,
    input  [3:0]  read_byte_select,
    input  [31:0] address,
    input  [31:0] data_in,
    output reg [31:0] data_out
);

    localparam MEM_SIZE = 1024; // 4KB memory as 1024 locations of 32-bit each
    localparam ADDR_ROM_1 = 32'h00100000; 
    localparam ADDR_ROM_2 = 32'h00100004; 

    localparam SURYA = 10338916; 
    localparam SAI   = 10452084; 

    reg [31:0] data_memory [0:MEM_SIZE-1];
    reg [31:0] special_rom [0:1];

    initial begin
        $readmemh("dataMemory.mem", data_memory);
        special_rom[0] = SURYA;
        special_rom[1] = SAI;
    end
    
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < MEM_SIZE; i = i + 1) begin
                data_memory[i] <= 32'b0;
            end
        end else begin
            if (read_enable) begin
                case (address)
                    ADDR_ROM_1: data_out <= special_rom[0];
                    ADDR_ROM_2: data_out <= special_rom[1];
                    default: if (address >> 2 < MEM_SIZE) begin
                                if (read_byte_select == 4'b0000) begin
                                    data_out <= data_memory[address >> 2];
                                end else begin
                                    data_out <= 32'h0;
                                    if (read_byte_select[0]) data_out[7:0]   <= data_memory[address >> 2][7:0];
                                    if (read_byte_select[1]) data_out[15:8]  <= data_memory[address >> 2][15:8];
                                    if (read_byte_select[2]) data_out[23:16] <= data_memory[address >> 2][23:16];
                                    if (read_byte_select[3]) data_out[31:24] <= data_memory[address >> 2][31:24];
                                end
                             end else 
                                data_out <= 32'hDEAD_BEEF; // Error code for invalid read
                endcase
            end

            if (|write_byte_select) begin
                if (address >> 2 < MEM_SIZE) begin
                    if (write_byte_select[0]) 
                        data_memory[address >> 2][7:0]   <= data_in[7:0];
                    if (write_byte_select[1]) 
                        data_memory[address >> 2][15:8]  <= data_in[15:8];
                    if (write_byte_select[2]) 
                        data_memory[address >> 2][23:16] <= data_in[23:16];
                    if (write_byte_select[3]) 
                        data_memory[address >> 2][31:24] <= data_in[31:24];
                end
            end
        end
    end
endmodule
