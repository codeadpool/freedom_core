`timescale 1ns / 1ps
`include "defines.vh"

module aluControl(
    input clk,
    input [1:0] ALUOp,
    input [6:0] funct7,
    input [2:0] funct3,
    output reg [3:0] ALUCtrl
);

always @(posedge clk) begin
    case(ALUOp)
        2'b00: begin    
            ALUCtrl = `ADD; // For load/store instructions
        end
        2'b01: begin
            ALUCtrl = `SUB; // For branch instructions
        end
        2'b10: begin         
            case(funct3)
                3'b000: begin
                    ALUCtrl = (funct7 == 7'b0000000) ? `ADD : `SUB;
                end
                3'b001:  ALUCtrl = `SLL;  
                3'b010:  ALUCtrl = `SLT;  
                3'b011:  ALUCtrl = `SLTU; 
                3'b100:  ALUCtrl = `XOR;  
                3'b101: begin
                    ALUCtrl = (funct7 == 7'b0000000) ? `SRL : `SRA; 
                end
                3'b110:  ALUCtrl = `OR; 
                3'b111:  ALUCtrl = `AND; 
                default: ALUCtrl = 4'b0000; 
            endcase
        end
        default: ALUCtrl = 4'b0000; 
    endcase
end

endmodule
