module instruction_memory(
    
    input [31:0] address; 
    output reg [31:0] instruction 
);

// 4KB memory as 1024 locations of 32-bit each
reg [31:0] memory_array [0:1023];

initial begin
    $readmemh("instructions.mem", memory_array);
end

always @(address) begin
    instruction = memory_array[address[:]];
end

endmodule
