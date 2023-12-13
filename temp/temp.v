`timescale 1ns / 1ps
`include "defines.vh"

module controlUnit(
    input wire clk, rst,
  
    input wire [6:0] opCode,
    input wire [2:0] funct3,
    
    input wire branchOut,
    output reg iMemRead,
    output reg decodeEnable,
    output reg [1:0] pcSelect,  // For PC MUX
    output reg memPC,           // For PC_MEM_ALU Mux into regfile
    output reg regWrite, 
    output reg dMemRead,
    output reg dMemWrite, 
    output reg [3:0] dMemByteRead,
    output reg [3:0] dMemByteWrite,
    output reg [2:0] branchOp,
    output reg aluSrcB,
    output reg aluSrcA,
    output reg [1:0] aluOp, 
    output reg aluOutDataSel,   // To choose between ALUout and DataMem out
    output reg [3:0] cstate
);

    localparam [3:0] S0 = 4'b0000,  // Fetch
                     S1 = 4'b0001,  // Decode
                     S2 = 4'b0010,  // Load
                     S3 = 4'b0011,  // Load
                     S4 = 4'b0100,  // Load
                     S5 = 4'b0101,  // Store
                     S6 = 4'b0110,  // ART & IMM
                     S7 = 4'b0111,  // ART & IMM
                     S8 = 4'b1000,  // Branch
                     S9 = 4'b1001,  // Branch
                     S10 = 4'b1010, // JAL, JALR 
                     S11 = 4'b1011, // AUIPC & LUI
                     S12 = 4'b1100, // AUIPC & LUI
                     S13 = 4'b1101, // FENCE
                     S14 = 4'b1110; // SYSTEM

    reg [3:0] currentState;

    always @(posedge clk) begin
        if (rst) begin 
            currentState <= S0;  // add defaultsfor other signals
            iMemRead <= 1;
            decodeEnable <=1;
            cstate <= 0;
            pcSelect <= 2'b10;
            end 
        else begin
            case (currentState)
                S0 : begin                      // Instruction Fetch 
                    currentState <= S1;
                    iMemRead <= 1;
                    decodeEnable <=1;
                    cstate <= 0;
                    pcSelect <= 2'b10;
                end
                S1 : begin                      // Instruction decode/register fetch 
                    case (opCode)
                        `LOAD, `STORE   : currentState = S2; 
                        `ART, `IMM      : currentState = S6; 
                        `BRANCH         : currentState = S8; 
                        `SYSTEM         : currentState = S14; 
                        `JAL, `JALR     : currentState = S10; 
                        `FENCE          : currentState = S13;  
                        `AUIPC, `LUI    : currentState = S11; 
                        default         : currentState = S0;
                    endcase
                    cstate <= 1;                  
                end
                S2 : begin                      // Memory address computation
                    aluSrcA <= 1;
                    aluSrcB <= 1; 
                    aluOp <= 2'b00;             // Addition is happening here
                    case (opCode)
                        `LOAD  :    currentState = S3;
                        `STORE :    currentState = S5; 
                    endcase
                    cstate <= 2;
                end
                S3 : begin                      // Load - Not sure if this requires 1 cycle or 2 cycles.
                    dMemRead <= 1;
                    dMemByteRead <= 4'b00000;
                    aluOutDataSel <= 1;         // since data_out
                    currentState <= S4;
                    decodeEnable <= 0;
                    cstate <= 3;
                end
                S4 : begin                      // Memory read completion step 
                    regWrite <= 1;
                    memPC <= 1;                 // since data_out
                    pcSelect <= 1;              // since PC + 4
                    currentState <= S14;         // Load complete
                    cstate <= 4;
                end
                S5 : begin                      // Memory access
                    dMemWrite <= 1;
                    dMemByteWrite <= 4'b0000;
                    pcSelect <= 1;              // since PC + 4
                    currentState <= S14;
                    decodeEnable <= 0;         // Store complete
                    cstate <= 5;
                end
                S6 : begin                      // `ART & `IMM Execution 
                    aluSrcA <= 1;
                    aluOp <= 2'b10;
                    case(opCode) 
                        `ART : aluSrcB = 0;
                        `IMM : aluSrcB = 1; 
                    endcase
                    currentState <= S7;
                    cstate <= 6;
                end
                S7 : begin                      // `ART AND `IMM completion - Specific `ART & `IMM type operations will be handled by the Alucontrol module
                    regWrite <= 1;
                    aluOutDataSel <= 0;         // Since ALUout
                    memPC <= 1;                 // Since ALUout
                    pcSelect <= 1;              // Implying that PC+4 is given to PC before reaching S0
                    decodeEnable <=0;
                    currentState <= S14;
                    cstate <= 7;
                end
                S8 : begin                      // Branch stage 1
                    branchOp <= funct3;
                    aluSrcA <= 0;               // since PC
                    aluSrcB <= 1;               // since sign_ext_IMM
                    aluOp <= 2'b00; 
                    currentState <= S9;         // assign a new state number for next state
                    cstate <= 8;
                end 
                S9 : begin                      // Branch stage 2 completion
                    if(branchOut) 
                        pcSelect <= 0;
                    else 
                        pcSelect <= 1;
                    currentState = S14;
                    cstate <= 9;
                    decodeEnable <=0;
                end
                S10 : begin                     // JAL, JALR
                    memPC <= 0;                 // since PC+4 
                    regWrite <= 1;
                    aluOp <= 2'b00;
                    case(opCode) 
                        `JAL : begin
                            aluSrcA <= 0;       // since PC
                            aluSrcB <= 1;
                            pcSelect <= 0;      // since ALUout
                            currentState <= S0;
                        end
                        `JALR : begin 
                            aluSrcA <= 1;       // since rs1
                            aluSrcB <= 1;
                            pcSelect <= 0;      // since ALUout
                            currentState <= S0;
                        end
                    endcase 
                    cstate <= 10;
                end 
                
                S11 : begin                     // AUIPC and LUI
                    aluSrcA <= 0;
                    aluSrcB <= 1;
                    aluOp <= 2'b00;             // Mostly 2'b11; But will confirm
                    case (opCode)
                        `LUI : aluOp <= 2'b11;
                        `AUIPC: aluOp <= 2'b00;
                    endcase
                    currentState <= S12;
                    cstate <= 11;
                end    
                S12 : begin                     // AUIPC and LUI 2nd state
                    aluOutDataSel <= 0;         // since aluout
                    memPC <= 1;                 // since aluout
                    regWrite <= 1;
                    currentState <= S0;                    
                    cstate <= 12;
                end
                S13 : begin                     // FENCE
                    aluOp <= 2'b00;
                    regWrite <= 1;
                    currentState <= S0;
                    cstate <= 13;
                end
                S14 : begin 
                    // Do nothing
                    currentState <= S0;
                    cstate <= 14;
                    pcSelect <= 2'b10;
                end
                default : currentState = S0;    
            endcase
        end
    end

endmodule




`timescale 1ns / 1ps
`include "defines.vh"

module controlUnit(
    input wire clk, rst,
    input wire [6:0] opCode,
    input wire [2:0] funct3,
    input wire branchOut,
    output reg iMemRead,
    output reg [1:0] pcSelect,
    output reg memPC,
    output reg regWrite, 
    output reg dMemRead,
    output reg dMemWrite, 
    output reg [2:0] branchOp,
    output reg aluSrcB,
    output reg aluSrcA,
    output reg [1:0] aluOp, 
    output reg aluOutDataSel,
    output reg [3:0] cstate
);

    localparam [3:0] S0 = 4'b0000, S1 = 4'b0001, S2 = 4'b0010, S3 = 4'b0011, S4 = 4'b0100, 
                      S5 = 4'b0101, S6 = 4'b0110, S7 = 4'b0111, S8 = 4'b1000, S9 = 4'b1001, 
                      S10 = 4'b1010, S11 = 4'b1011, S12 = 4'b1100, S13 = 4'b1101, S14 = 4'b1110;

    reg [3:0] currentState, nextState;

    always @(posedge clk) begin 
        if (rst) currentState <= S0;
        else currentState <= nextState;
    end

    always @(*) begin
        iMemRead = 0; pcSelect = 2'b00; memPC = 0; regWrite = 0;
        dMemRead = 0; dMemWrite = 0; branchOp = 3'b000; aluSrcB = 0;
        aluSrcA = 0; aluOp = 2'b00; aluOutDataSel = 0; cstate = currentState;

        case (currentState)
            S0: begin 
                nextState = S1; iMemRead = 1; pcSelect = 2'b10;
            end
            S1: begin
                nextState = (opCode == `LOAD || opCode == `STORE) ? S2 : 
                            (opCode == `ART || opCode == `IMM) ? S6 : 
                            (opCode == `BRANCH) ? S8 : 
                            (opCode == `SYSTEM) ? S14 : 
                            (opCode == `JAL || opCode == `JALR) ? S10 : 
                            (opCode == `FENCE) ? S13 : 
                            (opCode == `AUIPC || opCode == `LUI) ? S11 : S0;
            end
            S2: begin 
                aluSrcA = 1; aluSrcB = 1; aluOp = 2'b00;
                nextState = (opCode == `LOAD) ? S3 : (opCode == `STORE) ? S5 : S0;
            end
            S3: begin
                dMemRead = 1; aluOutDataSel = 1; nextState = S4;
            end
            S4: begin
                regWrite = 1; memPC = 1; pcSelect = 2'b01; nextState = S0;
            end
            S5: begin
                dMemWrite = 1; pcSelect = 2'b01; nextState = S0;
            end
            S6: begin
                aluSrcA = 1; aluOp = 2'b10; aluSrcB = (opCode == `ART) ? 0 : 1; nextState = S7;
            end
            S7: begin
                regWrite = 1; aluOutDataSel = 0; memPC = 1; pcSelect = 2'b01; nextState = S0;
            end
            S8: begin
                branchOp = funct3; aluSrcA = 0; aluSrcB = 1; aluOp = 2'b00; nextState = S9;
            end
            S9: begin
                pcSelect = branchOut ? 2'b00 : 2'b01; nextState = S0;
            end
            S10: begin
                memPC = 0; regWrite = 1; aluOp = 2'b00; 
                aluSrcA = (opCode == `JALR) ? 1 : 0; aluSrcB = 1; pcSelect = 2'b00; nextState = S0;
            end
            S11: begin
                aluSrcA = 0; aluSrcB = 1; aluOp = (opCode == `LUI) ? 2'b11 : 2'b00; nextState = S12;
            end
            S12: begin
                aluOutDataSel = 0; memPC = 1; regWrite = 1; nextState = S0;
            end
            S13: begin
                aluOp = 2'b00; regWrite = 1; nextState = S0;
            end
            S14: begin
            end
        endcase
    end
endmodule
               
