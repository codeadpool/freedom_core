`timescale 1ns / 1ps
`include "defines.vh"

module aluControl(
    input [1:0] aluOp,
    input [6:0] funct7,
    input [2:0] funct3,
    input [6:0] opCode,
    output reg [3:0] aluCtl
);

always @(*) begin
    case(aluOp)
        2'b00: aluCtl = `ADD;   // Load and store instructions always use ADD
        2'b01: aluCtl = `SUB;   // Branch instructions use SUB
        2'b10: begin            // Arithmetic and immediate instructions
            if (opCode == `ART) begin
                case(funct3)
                    3'b000: aluCtl = (funct7 == 7'b0100000) ? `SUB : `ADD;
                    3'b001: aluCtl = `SLL;
                    3'b010: aluCtl = `SLT;
                    3'b011: aluCtl = `SLTU;
                    3'b100: aluCtl = `XOR;
                    3'b101: aluCtl = (funct7 == 7'b0000000) ? `SRL : `SRA;
                    3'b110: aluCtl = `OR;
                    3'b111: aluCtl = `AND;
                    default: aluCtl = 4'b0000;
                endcase
            end else if (opCode == `IMM) begin
                case(funct3)
                    3'b000: aluCtl = `ADD;  // ADDI
                    3'b001: aluCtl = `SLL;  // SLLI
                    3'b010: aluCtl = `SLT;  // SLTI
                    3'b011: aluCtl = `SLTU; // SLTIU
                    3'b100: aluCtl = `XOR;  // XORI
                    3'b101: aluCtl = (funct7 == 7'b0000000) ? `SRL : `SRA; // SRLI, SRAI
                    3'b110: aluCtl = `OR;   // ORI
                    3'b111: aluCtl = `AND;  // ANDI
                    default: aluCtl = 4'b0000;
                endcase
            end else begin
                aluCtl = 4'b0000;
            end
        end
        2'b11: aluCtl = `OLUI; // LUI instruction
        default: aluCtl = 4'b0000;
    endcase
end

endmodule

