// ALU defines
`define ADD     4'b0000
`define SUB     4'b1000 
`define OR      4'b0110 
`define AND     4'b0111 
`define XOR     4'b0100 
`define SLL     4'b0001 
`define SRL     4'b0101
`define SRA     4'b1101 
`define SLT     4'b0010 
`define SLTU    4'b0011 
`define OLUI    4'b1010

// Opcode defines
`define LUI     7'b0110111 
`define AUIPC   7'b0010111 
`define JAL     7'b1101111 
`define JALR    7'b1100111 
`define BRANCH  7'b1100011 
`define LOAD    7'b0000011 
`define STORE   7'b0100011 
`define IMM     7'b0010011 
`define ART     7'b0110011 
`define FENCE   7'b0001111 
`define SYSTEM  7'b1110011 

// Load defines
`define LB   3'b000 
`define LH   3'b001 
`define LW   3'b010 
`define LBU  3'b100 
`define LHU  3'b101 

// Store defines
`define SB  3'b000 
`define SH  3'b001 
`define SW  3'b010 

// Branch defines
`define BEQ  3'b000 
`define BNE  3'b001 
`define BLT  3'b100 
`define BGE  3'b101 
`define BLTU 3'b110 
`define BGEU 3'b111 