`timescale 1ns / 1ps
`include "defines.vh"

// DNM = Does not matter

module control_unit(
    input wire clk, rst,
    input wire [31:0] instruction,
    input wire Branch_out,
    output reg [1:0] PCSelect, // For PC MUX
    output reg Mem_PC,  // For PC_MEM_ALU Mux into regfile
    output reg RegWrite, 
    output reg IMemRead,
    output reg DMemread,
    output reg DMemWrite, 
    output reg [2:0] branch_op,
    output reg ALUSrcB,
    output reg ALUSrcA,
    output reg [1:0] ALUOp, 
    output reg ALUout_Data_sel  // To choose between ALUout and DataMem out
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

    reg [3:0] current_state, next_state;

    always @(posedge clk) begin
        if (rst) begin
            current_state <= S0; 
        end else begin
            current_state <= next_state;
        end
    end

    always @(posedge clk) begin
        opcode = instruction[6:0];
        func3 = instruction[14:12];
        case (current_state)
            S0 : begin      // Instruction Fetch 
                PCSelect <= 2'b10; // Selects 0X010000000                
                //DMemread <= 0; DNM
                //DMemWrite <= 0; DNM
                //ALUSrcA <= 0; // DNM
                //ALUSrcB <= 2'b01; // DNM
                //ALUOp <= 2'b00; // DNM
                // DNM : Mem_PC, RegWrite, branch_op, ALUout_DATA_sel
                next_state <= S1;
            end
            S1 : begin      // Instruction decode/register fetch 
                case (opcode)
                    `LOAD, `STORE : next_state = S2; // Done
                    `ART, `IMM : next_state = S6; // Done
                    `BRANCH : next_state = S8; // Done
                    `SYSTEM : next_state = S14; // done
                    `JAL, `JALR : next_state = S10; // Half done
                    `FENCE : next_state = S13;  // 
                    `AUIPC : next_state = S11; // done
                    `LUI : next_state = S12; // done
                    default : next_state = S0;
                endcase
            end
            S2 : begin      // Memory address computation
                ALUSrcA <= 1;
                ALUSrcB <= 1; 
                ALUOp <= 2'b00; // Addition is happening here
                case (opcode)
                    `LOAD  :    next_state = S3;
                    `STORE :    next_state = S5; 
                endcase
            end
            S3 : begin      // Load - Not sure if this requires 1 cycle or 2 cycles.
                DMemread <= 1;
                ALUout_Data_sel <= 1; // since data_out
                next_state <= S4;
            end
            S4 : begin      // Memory read completion step 
                RegWrite <= 1;
                Mem_PC <= 1; // since data_out
                PCSelect <= 1; // since PC + 4
                next_state <= S0; // Load complete
            end
            S5 : begin      // Memory access
                DMemWrite <= 1;
                PCSelect <= 1; // since PC + 4
                next_state <= S0; // Store complete
            end
            S6 : begin      // `ART & `IMM Execution 
                ALUSrcA <= 1;
                ALUOp <= 2'b10;
                case(opcode) // $changed here
                    `ART : ALUSrcB = 0;
                    `IMM : ALUSRCB = 1; 
                endcase
                next_state <= S7;
            end
            S7 : begin      // `ART AND `IMM completion - Specific `ART & `IMM type operations will be handled by the Alucontrol module
                RegWrite <= 1;
                ALUout_Data_sel <= 0; // Since ALUout
                Mem_PC <= 1; // Since ALUout
                PCSelect <= 1; // Implying that PC+4 is given to PC before reaching S0
                next_state <= S0;
            end
            S8 : begin      // Branch stage 1
                branch_op <= func3;
                ALUSrcA <= 0; // since PC
                ALUSrcB <= 1; // since sign_ext_IMM
                ALUOp <= 2'b00; 
                next_state <= S9; // assign a new state number for next state
            end 
            S9 : begin  // Branch stage 2 completion
                if(Branch_out) PCSelect <= 0;
                else PCSelect <= 1;
                next_state = S0;
            end
            S10 : begin      // JAL, JALR
                Mem_PC <= 0; // since PC+4 
                RegWrite <= 1;
                ALUOp <= 2'b00;
                case(opcode) // $changed here
                    `JAL : begin
                        ALUSrcA <= 0; // since PC
                        ALUSrcB <= 1;
                        PCSelect <= 0; // since ALUout
                        next_state <= S10;
                    end
                    `JALR : begin 
                        ALUSrcA <= 1; // since rs1
                        ALUSrcB <= 1;
                        PCSelect <= 0; // since ALUout
                        next_state <= S10;
                    end
                endcase 
            end 

            //             S1: begin      // JAl, JALR 2nd stage

            // How do I make sure that PC+4 occurs after JAL,JALR

                        // end 
            S11 : begin     // AUIPC // May need to use ALU to execute the {imm[31:12],12[0]}
                ALUSrcA <= 0;
                ALUSrcB <= 1;
                ALUOp <= 2'b00; // Mostly 2'b11; But will confirm

                //========================== new state ==========================

                ALUout_DATA_sel <= 0; // since aluout
                Mem_PC <= 1; // since aluout
                RegWrite <= 1;
                next_state <= S0; 
            end    
            S12 : begin     // LUI
                ALUSrcB <= 1; // immediate, and ALUsrcA doens't matter
                ALUOp <= 11; 
                ALUout_DATA_sel <= 0; // since aluout
                Mem_PC <= 1; // since aluout
                RegWrite <= 1;
                next_state <= S0;
            end
            S13 : begin     // FENCE
                ALUOp <= 2'b00;
                RegWrite <= 1;
                next_state <= S0;
            end
            S14 : begin 
                //Do nothing
            end
            default : next_state = S0;    
        endcase
    end

endmodule