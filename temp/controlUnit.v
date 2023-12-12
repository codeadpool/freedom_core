`timescale 1ns / 1ps
`include "defines.vh"

module controlUnit(
    input wire clk, rst,
    input wire [31:0] instruction,
    input wire branchOut,
    output reg [1:0] pcSelect, // For PC MUX
    output reg memPC,  // For PC_MEM_ALU Mux into regfile
    output reg regWrite, 
    output reg dMemRead,
    output reg dMemWrite, 
    output reg [2:0] branchOp,
    output reg aluSrcB,
    output reg aluSrcA,
    output reg [1:0] aluOp, 
    output reg aluOutDataSel,  // To choose between ALUout and DataMem out
    output reg [3:0] cstate
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

    reg [3:0] currentState;

    always @(posedge clk) begin
        opcode = instruction[6:0];
        func3 = instruction[14:12];
        if (rst) currentState <= S0;
        else begin
            case (currentState)
                S0 : begin      // Instruction Fetch 
    //                pcSelect <= 2'b10; // Selects 0X010000000                
                    //dMemRead <= 0; DNM
                    //dMemWrite <= 0; DNM
                    //aluSrcA <= 0; // DNM
                    //aluSrcB <= 2'b01; // DNM
                    //aluOp <= 2'b00; // DNM
                    // DNM : memPC, regWrite, branchOp, aluOutDataSel
                    currentState <= S1;
                    cstate <= 0;
                end
                S1 : begin      // Instruction decode/register fetch 
                    case (opcode)
                        `LOAD, `STORE   : currentState = S2; 
                        `ART, `IMM      : currentState = S6; 
                        `BRANCH         : currentState = S8; 
                        `SYSTEM         : currentState = S14; 
                        `JAL, `JALR     : currentState = S10; 
                        `FENCE          : currentState = S13;  
                        `AUIPC          : currentState = S11; 
                        `LUI            : currentState = S12; 
                        default         : currentState = S0;
                    endcase
                    cstate <= 1;
                end
                S2 : begin      // Memory address computation
                    aluSrcA <= 1;
                    aluSrcB <= 1; 
                    aluOp <= 2'b00; // Addition is happening here
                    case (opcode)
                        `LOAD  :    currentState = S3;
                        `STORE :    currentState = S5; 
                    endcase
                    cstate <= 2;
                end
                S3 : begin      // Load - Not sure if this requires 1 cycle or 2 cycles.
                    dMemRead <= 1;
                    aluOutDataSel <= 1; // since data_out
                    currentState <= S4;
                    cstate <= 3;
                end
                S4 : begin      // Memory read completion step 
                    regWrite <= 1;
                    memPC <= 1; // since data_out
                    pcSelect <= 1; // since PC + 4
                    currentState <= S0; // Load complete
                    cstate <= 4;
                end
                S5 : begin      // Memory access
                    dMemWrite <= 1;
                    pcSelect <= 1; // since PC + 4
                    currentState <= S0; // Store complete
                    cstate <= 5;
                end
                S6 : begin      // `ART & `IMM Execution 
                    aluSrcA <= 1;
                    aluOp <= 2'b10;
                    case(opcode) // $changed here
                        `ART : aluSrcB = 0;
                        `IMM : aluSrcB = 1; 
                    endcase
                    currentState <= S7;
                    cstate <= 6;
                end
                S7 : begin      // `ART AND `IMM completion - Specific `ART & `IMM type operations will be handled by the Alucontrol module
                    regWrite <= 1;
                    aluOutDataSel <= 0; // Since ALUout
                    memPC <= 1; // Since ALUout
                    pcSelect <= 1; // Implying that PC+4 is given to PC before reaching S0
                    currentState <= S0;
                    cstate <= 7;
                end
                S8 : begin      // Branch stage 1
                    branchOp <= func3;
                    aluSrcA <= 0; // since PC
                    aluSrcB <= 1; // since sign_ext_IMM
                    aluOp <= 2'b00; 
                    currentState <= S9; // assign a new state number for next state
                    cstate <= 8;
                end 
                S9 : begin  // Branch stage 2 completion
                    if(branchOut) pcSelect <= 0;
                    else pcSelect <= 1;
                    currentState = S0;
                    cstate <= 9;
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
                            currentState <= S0;
                        end
                        `JALR : begin 
                            aluSrcA <= 1; // since rs1
                            aluSrcB <= 1;
                            pcSelect <= 0; // since ALUout
                            currentState <= S0;
                        end
                    endcase 
                    cstate <= 10;
                end 
                
                S11 : begin     // AUIPC // May need to use ALU to execute the {imm[31:12],12[0]}
                    aluSrcA <= 0;
                    aluSrcB <= 1;
                    aluOp <= 2'b00; // Mostly 2'b11; But will confirm
                    currentState <= 14;
                    cstate <= 11;
                end    
                S12 : begin     // LUI
                    aluSrcB <= 1; // immediate, and aluSrcA doesn't matter
                    aluOp <= 11; 
                    aluOutDataSel <= 0; // since aluout
                    memPC <= 1; // since aluout
                    regWrite <= 1;
                    currentState <= S0;
                    cstate <= 12;
                end
                S13 : begin     // FENCE
                    aluOp <= 2'b00;
                    regWrite <= 1;
                    currentState <= S0;
                    cstate <= 13;
                end
                S14 : begin // AUIPC 2nd state
                    aluOutDataSel <= 0; // since aluout
                    memPC <= 1; // since aluout
                    regWrite <= 1;
                    currentState <= S0;                    
                    cstate <= 14;
                end
                default : currentState = S0;    
            endcase
        end
    end

endmodule
