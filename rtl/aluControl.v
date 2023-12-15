`timescale 1ns / 1ps
`include "defines.vh"

module aluControl(
    input [1:0] aluOp,
    input [6:0] funct7,
    input [2:0] funct3,
    output reg [3:0] aluCtl
);

always @(*) begin
    case(aluOp)
        2'b00: begin    
            aluCtl = `ADD; // For load/store instructions
        end
        2'b01: begin
            aluCtl = `SUB; // For branch instructions
        end
        2'b10: begin         
            case(funct3)
                3'b000: begin
                    aluCtl = (funct7 == 7'b0000000) ? `ADD : `SUB;
                end
                3'b001:  aluCtl = `SLL;  
                3'b010:  aluCtl = `SLT;  
                3'b011:  aluCtl = `SLTU; 
                3'b100:  aluCtl = `XOR;  
                3'b101: begin
                    aluCtl = (funct7 == 7'b0000000) ? `SRL : `SRA; 
                end
                3'b110:  aluCtl = `OR; 
                3'b111:  aluCtl = `AND; 
                default: aluCtl = 4'b0000; 
            endcase
        end
        2'b11: begin
            aluCtl = `OLUI;
        end
        default: aluCtl = 4'b0000; 
    endcase
end

endmodule
