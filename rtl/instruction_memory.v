`timescale 1ns / 1ps

module instructionMemory(  
    input clk, read_enable,
    input [31:0] address,
    output reg [31:0] instruction 
);

// 4KB memory as 1024 locations of 32-bit each
reg [31:0] memory_array [0:1023];// block rom 

initial begin
    $readmemh("instructions.mem", memory_array);
end

always @(posedge clk) begin
    if(read_enable) begin
        instruction = memory_array[address[15:6]]; // need to change only 10 bits
    end
end

endmodule

