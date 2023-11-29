`timescale 1ns / 1ps
`include "defines.vh"

module control_unit(
    input clk, rst,
    input [31:0] instruction,
    output reg PCWriteCond,
    output reg PCWrite,   
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite, 
    output reg IRWrite,
    output reg MemtoReg,
    output reg IorD, 
    output reg [1:0] ALUSrcB,
    output reg ALUSrcA,
    output reg [1:0] PCSource,
    output reg [1:0] ALUOp  // This signal will be used by alucontrol module
);

    reg [6:0] opcode;
      
    localparam [3:0] FETCH             = 4'b0000,
                     DECODE            = 4'b0001,
                     EXECUTE           = 4'b0010,
                     MEM_ACCESS        = 4'b0011,
                     WRITE_BACK        = 4'b0100,
                     BRANCH_COMPLETE   = 4'b0101,
                     HALT              = 4'b0110;

    reg [3:0] current_state, next_state;

    always @(posedge clk) begin
        if (rst) begin
            current_state <= FETCH;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        opcode = instruction[6:0];
        
        case (current_state)
            FETCH: next_state = DECODE;
            DECODE: begin
                case (opcode)
                    `LUI, `AUIPC, `JAL, `JALR, `IMM, `ART: next_state = EXECUTE;
                    `BRANCH: next_state = BRANCH_COMPLETE;
                    `LOAD, `STORE: next_state = MEM_ACCESS;
                    `SYSTEM: next_state = HALT;
                    default: next_state = FETCH;
                endcase
            end
            EXECUTE: begin
                case (opcode)
                    `LUI, `AUIPC: begin
                        ALUSrcA = (opcode == `AUIPC) ? 1 : 0; ALUSrcB = 2'b10;
                        ALUOp = (opcode == `AUIPC) ? 2'b00 : 2'b11; RegWrite = 1;
                    end
                    `JAL, `JALR: begin
                        ALUSrcA = 1; ALUOp = 2'b00; PCWrite = 1; RegWrite = 1;
                        PCSource = (opcode == `JAL) ? 2'b10 : 2'b11;
                    end
                    `BRANCH: begin
                        ALUSrcA = 0; ALUOp = 2'b01; PCWriteCond = 1; PCSource = 2'b01;
                    end
                    `LOAD, `STORE: begin
                        ALUSrcA = 1; ALUSrcB = 2'b10; ALUOp = 2'b00;
                        MemWrite = (opcode == `STORE) ? 1 : 0; MemRead = (opcode == `LOAD) ? 1 : 0;
                    end
                    `IMM: begin
                        ALUSrcA = 1; ALUSrcB = 2'b10; ALUOp = 2'b10; RegWrite = 1;
                    end
                    `ART: begin
                        ALUSrcA = 1; ALUSrcB = 2'b00; ALUOp = 2'b10; RegWrite = 1;
                        // Specific R-type operations will be handled by the alucontrol module
                    end
                endcase
            end
            MEM_ACCESS: begin
                MemtoReg = (opcode == `LOAD) ? 1 : 0; RegWrite = (opcode == `LOAD) ? 1 : 0;
                IorD = 1; // Set IorD for memory access
            end
            WRITE_BACK: begin
                RegWrite = 1; MemtoReg = 1;
            end
            BRANCH_COMPLETE: begin
                PCWriteCond = 1; PCSource = 2'b01;
            end
            HALT: next_state = HALT;
            default: next_state = FETCH;
        endcase
    end

endmodule
