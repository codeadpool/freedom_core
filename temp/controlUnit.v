`timescale 1ns / 1ps
`include "defines.vh"

module controlUnit(
    input wire clk, rst,
    input wire [31:0] instruction,
    input wire branchOut,
    output reg [1:0] pcSelect, // For PC MUX
    output reg memPC,  // For PC_MEM_ALU Mux into regfile
    output reg regWrite, 
    output reg iMemRead,
    output reg dMemRead,
    output reg dMemWrite, 
    output reg [2:0] branchOp,
    output reg aluSrcB,
    output reg aluSrcA,
    output reg [1:0] aluOp, 
    output reg aluOutDataSel  // To choose between ALUout and DataMem out
);

    reg [6:0] opcode;
    reg [2:0] func3;
      
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
                     S10 = 4'b1010, // JAL, JALR 
                     S11 = 4'b1011, // AUIPC
                     S12 = 4'b1100, // LUI
                     S13 = 4'b1101, // FENCE
                     S14 = 4'b1110; // SYSTEM && FENCE

    reg [3:0] currentState, nextState;

    always @(posedge clk) begin
        if (rst) begin
            currentState <= S0; 
        end else begin
            currentState <= nextState;
        end
    end

    always @(posedge clk) begin
        opcode = instruction[6:0];
        func3 = instruction[14:12];
        case (currentState)
            S0 : begin      // Instruction Fetch 
                //pcSelect <= 2'b10; // Selects 0X010000000                
                //dMemRead <= 0; DNM
                //dMemWrite <= 0; DNM
                //aluSrcA <= 0; // DNM
                //aluSrcB <= 2'b01; // DNM
                //aluOp <= 2'b00; // DNM
                // DNM : memPC, regWrite, branchOp, aluOutDataSel
                nextState <= S1;
            end
            S1 : begin      // Instruction decode/register fetch 
                case (opcode)
                    `LOAD, `STORE : nextState = S2; // Done
                    `ART, `IMM : nextState = S6; // Done
                    `BRANCH : nextState = S8; // Done
                    `SYSTEM : nextState = S14; // done
                    `JAL, `JALR : nextState = S10; // Half done
                    `FENCE : nextState = S13;  // 
                    `AUIPC : nextState = S11; // done
                    `LUI : nextState = S12; // done
                    default : nextState = S0;
                endcase
            end
            S2 : begin      // Memory address computation
                aluSrcA <= 1;
                aluSrcB <= 1; 
                aluOp <= 2'b00; // Addition is happening here
                case (opcode)
                    `LOAD  :    nextState = S3;
                    `STORE :    nextState = S5; 
                endcase
            end
            S3 : begin      // Load - Not sure if this requires 1 cycle or 2 cycles.
                dMemRead <= 1;
                aluOutDataSel <= 1; // since data_out
                nextState <= S4;
            end
            S4 : begin      // Memory read completion step 
                regWrite <= 1;
                memPC <= 1; // since data_out
                pcSelect <= 1; // since PC + 4
                nextState <= S0; // Load complete
            end
            S5 : begin      // Memory access
                dMemWrite <= 1;
                pcSelect <= 1; // since PC + 4
                nextState <= S0; // Store complete
            end
            S6 : begin      // `ART & `IMM Execution 
                aluSrcA <= 1;
                aluOp <= 2'b10;
                case(opcode) // $changed here
                    `ART : aluSrcB = 0;
                    `IMM : aluSrcB = 1; 
                endcase
                nextState <= S7;
            end
            S7 : begin      // `ART AND `IMM completion - Specific `ART & `IMM type operations will be handled by the Alucontrol module
                regWrite <= 1;
                aluOutDataSel <= 0; // Since ALUout
                memPC <= 1; // Since ALUout
                pcSelect <= 1; // Implying that PC+4 is given to PC before reaching S0
                nextState <= S0;
            end
            S8 : begin      // Branch stage 1
                branchOp <= func3;
                aluSrcA <= 0; // since PC
                aluSrcB <= 1; // since sign_ext_IMM
                aluOp <= 2'b00; 
                nextState <= S9; // assign a new state number for next state
            end 
            S9 : begin  // Branch stage 2 completion
                if(branchOut) pcSelect <= 0;
                else pcSelect <= 1;
                nextState = S0;
            end
            S10 : begin      // JAL, JALR
                memPC <= 0; // since PC+4 
                regWrite <= 1;
                aluOp <= 2'b00;
                case(opcode) // $changed here
                    `JAL : begin
                        aluSrcA <= 0; // since PC
                        aluSrcB <= 1;
                        pcSelect <= 0; // since ALUout
                        nextState <= S10;
                    end
                    `JALR : begin 
                        aluSrcA <= 1; // since rs1
                        aluSrcB <= 1;
                        pcSelect <= 0; // since ALUout
                        nextState <= S10;
                    end
                endcase 
            end 

            //             S1: begin      // JAl, JALR 2nd stage

            // How do I make sure that PC+4 occurs after JAL,JALR

                        // end 
            S11 : begin     // AUIPC // May need to use ALU to execute the {imm[31:12],12[0]}
                aluSrcA <= 0;
                aluSrcB <= 1;
                aluOp <= 2'b00; // Mostly 2'b11; But will confirm

                //========================== new state ==========================

                aluOutDataSel <= 0; // since aluout
                memPC <= 1; // since aluout
                regWrite <= 1;
                nextState <= S0; 
            end    
            S12 : begin     // LUI
                aluSrcB <= 1; // immediate, and aluSrcA doesn't matter
                aluOp <= 11; 
                aluOutDataSel <= 0; // since aluout
                memPC <= 1; // since aluout
                regWrite <= 1;
                nextState <= S0;
            end
            S13 : begin     // FENCE
                aluOp <= 2'b00;
                regWrite <= 1;
                nextState <= S0;
            end
            S14 : begin 
                //Do nothing
            end
            default : nextState = S0;    
        endcase
    end

endmodule
