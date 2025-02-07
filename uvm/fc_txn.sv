import fc_pkg::*;

///---------------------------------------------------------------------
/// Class: fc_txn
/// Description: Transaction item representing an instruction and its 
/// associated data for RISC-V verification. Contains randomizable 
/// input fields, output fields, constraints, and helper functions for 
/// resetting the item, decoding the instruction type, and extending 
/// immediate values.
///---------------------------------------------------------------------
class fc_txn extends uvm_sequence_item;

    // ---------------------------------------------------------------
    // Constructor
    // ---------------------------------------------------------------
    function new(string name = "risc_seq_item");
        super.new(name);
    endfunction

    // ---------------------------------------------------------------
    // Randomizable Inputs
    // ---------------------------------------------------------------
    rand logic        reset;       // Reset signal with distribution
    rand bit   [31:0] instr_f;     // 32-bit instruction fetched
    rand instr_type   inst_type;   // Enumerated instruction type

    // ---------------------------------------------------------------
    // Outputs
    // ---------------------------------------------------------------
    logic [31:0] pc_f;           // Program counter value from fetch stage
    logic [31:0] write_data_m;   // Data to be written to memory
    logic [31:0] data_addr_m;    // Memory address for data access
    logic [31:0] read_data_m;    // Data read from memory
    logic        mem_write_m;    // Memory write enable signal
    bit          lw_stall;       // Stall signal for load word operations
    bit          beq_flush;      // Flush signal for branch-equal instructions

    // ---------------------------------------------------------------
    // UVM Automation Macros: Register Fields for Automation
    // ---------------------------------------------------------------
    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(reset,         UVM_DEFAULT + UVM_DEC)
        `uvm_field_int(instr_f,       UVM_DEFAULT + UVM_HEX)
        `uvm_field_int(pc_f,          UVM_DEFAULT + UVM_HEX)
        `uvm_field_int(write_data_m,  UVM_DEFAULT + UVM_HEX)
        `uvm_field_int(data_addr_m,   UVM_DEFAULT + UVM_HEX)
        `uvm_field_int(read_data_m,   UVM_DEFAULT + UVM_HEX)
        `uvm_field_int(mem_write_m,   UVM_DEFAULT)
        `uvm_field_int(lw_stall,      UVM_DEFAULT)
        `uvm_field_int(beq_flush,     UVM_DEFAULT)
        `uvm_field_enum(instr_type, inst_type, UVM_DEFAULT)
    `uvm_object_utils_end

    // ---------------------------------------------------------------
    // Constraints
    // ---------------------------------------------------------------

    // Constraint to ensure valid opcodes are generated.
    // Only the following opcodes are allowed for 'instr_f[6:0]'.
    constraint opcode_range {
        instr_f[6:0] inside {LW, IMM, AUIPC, SW, ARITH, LUI, BRNCH, JALR, JAL};
    }

    // Constraint to check the function bits for each opcode.
    // The constraints specify the valid values for funct3 and funct7 fields 
    // (located at various bit positions) based on the opcode.
    constraint funct_range {
        (instr_f[6:0] == LW)     -> (instr_f[14:12] == 3'b010);
        (instr_f[6:0] == SW)     -> (instr_f[14:12] == 3'b010);
        (instr_f[6:0] == JALR)   -> (instr_f[14:12] == 3'b000);
        (instr_f[6:0] == BRNCH)  -> (instr_f[14:12] inside {BEQ, BNE, BLT, BGE});
        (instr_f[6:0] == IMM && instr_f[14:12] == 3'b101) -> 
            (instr_f[31:25] inside {7'b0000000, 7'b0100000});
        (instr_f[6:0] == IMM && instr_f[14:12] == 3'b001) -> 
            (instr_f[31:25] == 7'b0000000);
        ((instr_f[6:0] == ARITH) && 
         (instr_f[14:12] inside {SLL, SLT, XOR, OR, AND})) -> 
            (instr_f[31:25] == 7'b0000000);
        (instr_f[6:0] == ARITH && instr_f[14:12] == 3'b101) -> 
            (instr_f[31:25] inside {7'b0100000, 7'b0000000});
        // For instructions other than SW and BRNCH, destination register 
        // (bits [11:7]) should not be zero.
        (instr_f[6:0] != SW && instr_f[6:0] != BRNCH) -> (instr_f[11:7] != 0);
    }

    // Constraint to distribute the reset signal:
    // The reset value '0' is significantly more likely than '1'.
    constraint reset_dist {
        reset dist { 1 := 1, 0 := 100000 };
    }

    // ---------------------------------------------------------------
    // Functions
    // ---------------------------------------------------------------

    ///---------------------------------------------------------------
    /// Function: reset_item
    /// Description: Resets all outputs and the instruction type to default
    ///              values.
    ///---------------------------------------------------------------
    function void reset_item();
        instr_f      = 32'b0;
        pc_f         = 32'b0;
        data_addr_m  = 32'b0;
        mem_write_m  = 1'b0;
        write_data_m = 32'b0;
        lw_stall     = 1'b0;
        beq_flush    = 1'b0;
        inst_type    = RESET;
    endfunction

    ///---------------------------------------------------------------
    /// Function: get_instruction_type
    /// Description: Decodes the instruction (instr_f) by examining the 
    ///              opcode and function bits, then assigns the proper 
    ///              instruction type to inst_type.
    ///---------------------------------------------------------------
    function void get_instruction_type();
        unique case (instr_f[6:0])
            // For opcodes where instruction type is directly defined by opcode
            LW, SW, LUI, AUIPC, JALR, JAL:
                inst_type = instr_f[6:0];

            // For immediate-type instructions
            IMM: begin
                unique case (instr_f[14:12])
                    3'b000: inst_type = ADDI;
                    3'b001: inst_type = SLLI;
                    3'b010: inst_type = SLTI;
                    3'b100: inst_type = XORI;
                    3'b110: inst_type = ORI;
                    3'b111: inst_type = ANDI;
                    3'b101: inst_type = (instr_f[30] == 0) ? SRLI : SRAI;
                endcase
            end

            // For register-register arithmetic instructions
            ARITH: begin
                unique case (instr_f[14:12])
                    3'b001: inst_type = SLL;
                    3'b010: inst_type = SLT;
                    3'b100: inst_type = XOR;
                    3'b110: inst_type = OR;
                    3'b111: inst_type = AND;
                    3'b000: inst_type = (instr_f[30] == 0) ? ADD : SUB;
                    3'b101: inst_type = (instr_f[30] == 0) ? SRL : SRA;
                endcase
            end

            // For branch instructions
            BRNCH: begin
                unique case (instr_f[14:12])
                    3'b000: inst_type = BEQ;
                    3'b001: inst_type = BNE;
                    3'b100: inst_type = BLT;
                    3'b101: inst_type = BGE;
                endcase
            end

            // Default assignment for unsupported/unknown opcodes
            default: 
                inst_type = UNKNOWN;
        endcase
    endfunction

    ///---------------------------------------------------------------
    /// Function: extend_immediate
    /// Description: Extracts and sign-extends the immediate field from 
    ///              the instruction (instr_f) based on the instruction 
    ///              format.
    ///
    /// Returns:
    ///   A 32-bit value with the sign-extended immediate.
    ///---------------------------------------------------------------
    function bit [31:0] extend_immediate();
        unique case (instr_f[6:0])
            // I-type instructions: immediate is in bits [31:20]
            IMM, LW, JALR: 
                return {{20{instr_f[31]}}, instr_f[31:20]};

            // S-type instructions: immediate is split between bits [31:25] and [11:7]
            SW:           
                return {{20{instr_f[31]}}, instr_f[31:25], instr_f[11:7]};

            // B-type instructions: immediate is assembled from multiple bit fields
            BRNCH:        
                return {{20{instr_f[31]}}, instr_f[7], instr_f[30:25], instr_f[11:8], 1'b0};

            // J-type instructions: immediate is assembled from several fields
            JAL:          
                return {{12{instr_f[31]}}, instr_f[19:12], instr_f[20], instr_f[30:21], 1'b0};

            // U-type instructions: immediate occupies bits [31:12] with lower bits zeroed
            LUI, AUIPC:   
                return {instr_f[31:12], 12'b0};

            // Default case for unknown instruction types
            default:      
                return 32'bx;
        endcase
    endfunction

endclass

