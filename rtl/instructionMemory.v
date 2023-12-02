`timescale 1ns / 1ps

module instructionMemory(
    input wire clk, read_enable,
    input wire [31:0] address,
    output reg [31:0] instruction_address
);

    localparam MEM_SIZE = 1024; 
    localparam BASE_ADDRESS = 32'h01000000;
    localparam ADDR_WIDTH = $clog2(MEM_SIZE);
    localparam NOP_INSTRUCTION = 32'h11111111; // NOP instruction
    
    
    reg [31:0] memory_array [0:MEM_SIZE-1];
    initial begin
        $readmemh("instructions.mem", memory_array);
    end
    
    always @(posedge clk) begin
        if (read_enable) begin
            if (address >= BASE_ADDRESS && address < BASE_ADDRESS + (MEM_SIZE << 2)) begin
                instruction_address = memory_array[(address - BASE_ADDRESS) >> 2];
            end else begin
                instruction_address = NOP_INSTRUCTION; // for now
            end
        end else begin
            instruction_address = NOP_INSTRUCTION;
        end
    end
endmodule

