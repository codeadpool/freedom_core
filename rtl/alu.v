`include "defines.vh"

module alu (
    input [31:0] operand1, 
    input [31:0] operand2, 
    input [3:0]  operation, 
    output reg [31:0] result
);

always @(*)
begin
    case (operation)

        `ADD :  result = operand1 + operand2;
        `SUB :  result = operand1 - operand2;
        `AND :  result = operand1 & operand2;
        `OR  :  result = operand1 | operand2;
        `XOR :  result = operand1 ^ operand2;

        `SLL :  result = operand1 << operand2[4:0]; 
        `SRL :  result = operand1 >> operand2[4:0];
        `SRA :  result = operand1 >>> operand2[4:0];

        `SLT :  result = $signed(operand1) < $signed(operand2) ? 32'b1 : 32'b0;
        `SLTU:  result = operand1 < operand2 ? 32'b1 : 32'b0;
        
        `OLUI:  result = operand2;

        default: result = 32'b0; // or result
    endcase
end

endmodule
