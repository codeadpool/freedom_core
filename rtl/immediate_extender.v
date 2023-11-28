`include "defines.vh"

module immediateExtender(
    input wire [31:0] instruction,
    output reg signed [31:0] extended_imm
);

    wire [6:0] opcode;
    wire [2:0] funct3;    
    
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    
    always @(*) begin
        case(opcode)  
            `LOAD   : extended_imm = {{20{instruction[31]}}, instruction[31:20]}; 
            `STORE  : extended_imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            `BRANCH : extended_imm = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            `LUI    ,
            `AUIPC  : extended_imm = {instruction[31:12], 12'b0};
            `JAL    : extended_imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            `JALR   : extended_imm = {{20{instruction[31]}}, instruction[31:20]};
                 
            `IMM    : begin
                          case(funct3)
                              3'b001, // SLLI
                              3'b101: // SRLI and SRAI
                                  extended_imm = {27'b0, instruction[24:20]};
                              default:
                                  extended_imm = {{20{instruction[31]}}, instruction[31:20]};
                          endcase
                      end
            
            default : extended_imm = 32'b0;
        endcase
    end

endmodule
