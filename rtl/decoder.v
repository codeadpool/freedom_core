`timescale 1ns / 1ps
`include "defines.vh"

module decoder(
    input wire [31:0] instruction,
    //input wire clk,
    output reg [6:0] opCode,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [4:0] rd,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg signed [31:0] imm
);
    always @(*) begin
        opCode = instruction[6:0];
        funct3 = instruction[14:12];
        funct7 = instruction[31:25];
        
        // Set rs1, rs2, rd, and imm based on opcode
        case (opCode)
            `LUI, `AUIPC: begin
                imm = {instruction[31:12], 12'b0};
                rd = instruction[11:7];
                rs1 = 5'b0;
                rs2 = 5'b0;
            end
            `JAL: begin
                imm = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                rd = instruction[11:7];
                rs1 = 5'b0;
                rs2 = 5'b0;
            end
            `JALR, `LOAD: begin
                imm = {{20{instruction[31]}}, instruction[31:20]};
                rs1 = instruction[19:15];
                rd = instruction[11:7];
                rs2 = 5'b0;
            end
            `STORE: begin
                imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                rd = 5'b0;
            end
            `BRANCH: begin
                imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                rd = 5'b0;
            end
            `IMM: begin
                case(funct3)
                    3'b001, // SLLI
                    3'b101: // SRLI and SRAI
                        imm = {27'b0, instruction[24:20]};
                    default:
                        imm = {{20{instruction[31]}}, instruction[31:20]};
                endcase
                rs1 = instruction[19:15];
                rd = instruction[11:7];
                rs2 = 5'b0;
            end
            `ART: begin
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                rd = instruction[11:7];
                imm = 32'b0;
            end
            `FENCE, `SYSTEM: begin
                rs1 = 5'b0;
                rs2 = 5'b0;
                rd = 5'b0;
                imm = 32'b0;
            end
            default: begin
                rs1 = 5'b0;
                rs2 = 5'b0;
                rd = 5'b0;
                imm = 32'b0;
            end
        endcase
    end
endmodule