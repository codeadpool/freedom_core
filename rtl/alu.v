`include "defines.vh"

module alu #(
    parameter WORDSIZE = 32
) (
    input [WORDSIZE-1:0] in1, in2,  
    input [3:0] ctl,              
    output reg [WORDSIZE-1:0] result  
);

    always @(*) begin
        case (ctl)
            `AND: result = in1 & in2;                         // Bitwise AND operation
            `OR:  result = in1 | in2;                         // Bitwise OR operation
            `ADD: result = in1 + in2;                         // Addition operation
            `SUB: result = in1 - in2;                         // Subtraction operation
            `SLL: result = in1 << in2[4:0];                   // Shift Left Logical (by in2[4:0] bits)
            `SLT: result = $signed(in1) < $signed(in2);       // Set Less than Signed
            `SLTU: result = $unsigned(in1) < $unsigned(in2);  // Set Less than Unsigned
            `XOR: result = in1 ^ in2;                         // Bitwise XOR operation
            `SRL: result = in1 >> in2[4:0];                   // Shift Right Logical (by in2[4:0] bits)
            `SRA: result = $signed(in1) >> in2[4:0];          // Shift Right Arithmetic (by in2[4:0] bits)
            default: result = result;                         // Default operation (no change to result)
        endcase
    end

endmodule