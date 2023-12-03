`timescale 1ns / 1ps
`include "defines.vh"

module control_unit(
    input wire clk, rst,
    input wire [31:0] instruction,
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
    output reg RegDst, 
    output reg [1:0] ALUOp 
);

    reg [6:0] opcode;
      

    localparam [3:0] S0 = 4'b0000,
                     S1 = 4'b0001,
                     S2 = 4'b0010,
                     S3 = 4'b0011,
                     S4 = 4'b0100,
                     S5 = 4'b0101,
                     S6 = 4'b0110,
                     S7 = 4'b0111,
                     S8 = 4'b1000,
                     S9 = 4'b1001, 
                     S10 = 4'b1010, // HALT 
                     S11 = 4'b1011, // AUIPC
                     S12 = 4'b1100, // LUI
                     S13 = 4'b1101; // FENCE

    reg [3:0] current_state, next_state;

    always @(posedge clk) begin
        if (rst) begin
            current_state <= S0; 
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        opcode = instruction[6:0];
        case (current_state)
            S0 : begin      // Instruction Fetch 
                MemRead = 1;
                ALUSrcA = 0;
                IorD = 0;
                IRWrite = 1;
                ALUSrcB = 01;
                ALUOp = 00;
                PCWrite = 1;
                PCSource = 0;
                next_state = S1;
            end
            S1 : begin      // Instruction decode/register fetch 
                ALUSrcA = 0;
                ALUSrcB = 10;
                ALUOp = 00;
                case (opcode)
                    `LOAD, `STORE : next_state = S2;
                    `ART, `IMM : next_state = S6; 
                    `BRANCH : next_state = S8;
                    `SYSTEM : next_state = S10; 
                    `JAL, `JALR : next_state = S9;
                    `FENCE : next_state = S13;  
                    `AUIPC : next_state = S11;
                    `LUI : next_state = S12;
                    default : next_state = S0;
                endcase
            end
            S2 : begin      // Memory address computation
                ALUSrcA = 1;
                ALUSrcB = 10;
                ALUOp = 00;
                case (opcode)
                    `LOAD  :    next_state = S3;
                    `STORE :    next_state = S5; 
                endcase
            end
            S3 : begin      // Memory access 
                MemRead = 1;
                IorD = 1;
                next_state = S4;
            end
            S4 : begin      // Memory read completion step 
                RegWrite = 1;
                MemtoReg = 1;
                RegDst = 0; 
                next_state = S0;
            end
            S5 : begin      // Memory access
                MemWrite = 1;
                IorD = 1;
                next_state = S0;
            end
            S6 : begin      // Execution 
                ALUSrcA = 1;
                ALUSrcB = 00;
                ALUOp = 10;
                next_state = S7;
            end
            S7 : begin      // R-completion - Specific R-type operations will be handled by the Alucontrol module
                RegWrite = 1;
                MemtoReg = 0;
                RegDst = 1; 
                next_state = S0;
            end
            S8 : begin      // Branch completion
                ALUSrcA = 1;
                ALUSrcB = 00;
                ALUOp = 01;
                PCWriteCond = 1;
                PCSource = 1;
                next_state = S0;
            end 
            S9 : begin      // JAL, JALR
                PCWrite = 1;
                PCSource = 10;
                next_state = S0; 
            end 
            S10: begin      // HALT
            end 
            S11 : begin     // AUIPC
                ALUOp = 10;
                RegWrite = 1;
                MemtoReg = 0;
                RegDst = 1;
                next_state = S0; 
            end    
            S12 : begin     // LUI
                ALUOp = 11; 
                RegWrite = 1;
                MemtoReg = 0;
                RegDst = 1;
                next_state = S0;
            end
            S13 : begin     // FENCE
                ALUOp = 00;
                RegWrite = 1;
                MemtoReg = 0;
                RegDst = 1;
                next_state = S0;
            end
            default : next_state = S0;    
        endcase
    end

endmodule