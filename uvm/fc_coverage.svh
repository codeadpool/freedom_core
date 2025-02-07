`include "uvm_macros.svh"

class fc_coverage extends uvm_subscriber #(fc_txn);

  // Coverage sampling variables.
  bit          cov_reset;
  bit [6:0]    cov_opcode;
  instr_type   cov_inst_type;
  bit [31:0]   cov_imm;

  // Covergroup to collect functional coverage.
  covergroup fc_cov_cg;
    option.per_instance = 1;

    // Coverpoint for reset.
    coverpoint cov_reset {
      bins reset_high = {1'b1};
      bins reset_low  = {1'b0};
    }

    // Coverpoint for opcode (bits [6:0] of the instruction).
    coverpoint cov_opcode {
      bins lw_bin    = {LW};
      bins imm_bin   = {IMM};
      bins auipc_bin = {AUIPC};
      bins sw_bin    = {SW};
      bins arith_bin = {ARITH};
      bins lui_bin   = {LUI};
      bins brnch_bin = {BRNCH};
      bins jalr_bin  = {JALR};
      bins jal_bin   = {JAL};
    }

    // Coverpoint for instruction type.
    coverpoint cov_inst_type {
      bins reset_type  = {RESET};
      bins addi_bin    = {ADDI};
      bins slli_bin    = {SLLI};
      bins slti_bin    = {SLTI};
      bins xori_bin    = {XORI};
      bins ori_bin     = {ORI};
      bins andi_bin    = {ANDI};
      bins srli_bin    = {SRLI};
      bins srai_bin    = {SRAI};
      bins sll_bin     = {SLL};
      bins slt_bin     = {SLT};
      bins xor_bin     = {XOR};
      bins or_bin      = {OR};
      bins and_bin     = {AND};
      bins add_bin     = {ADD};
      bins sub_bin     = {SUB};
      bins srl_bin     = {SRL};
      bins sra_bin     = {SRA};
      bins beq_bin     = {BEQ};
      bins bne_bin     = {BNE};
      bins blt_bin     = {BLT};
      bins bge_bin     = {BGE};
      bins unknown_bin = {UNKNOWN};
    }

    // Coverpoint for the immediate extension value.
    coverpoint cov_imm {
      bins low_range  = {[0:1023]};
      bins mid_range  = {[1024:1048575]};
      bins high_range = {[1048576:4294967295]};
    }

    // Cross coverage between opcode and instruction type.
    cross cov_opcode, cov_inst_type;
    // Cross coverage between opcode and immediate.
    cross cov_opcode, cov_imm;
    // Cross coverage between instruction type and immediate.
    cross cov_inst_type, cov_imm;
    // Three-dimensional cross of opcode, instruction type, and immediate.
    cross cov_opcode, cov_inst_type, cov_imm;
  endgroup

  // Instance of the covergroup.
  fc_cov_cg cov_inst;

  //------------------------------------------------------------
  // Constructor: Initializes the coverage collector.
  //------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //------------------------------------------------------------
  // Build Phase: Instantiate the covergroup.
  //------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cov_inst = new();
  endfunction

  //------------------------------------------------------------
  // Write: Samples the covergroup with transaction data.
  //------------------------------------------------------------
  virtual function void write(fc_txn t);
    // Decode instruction type and immediate extension.
    t.get_instruction_type();
    bit [31:0] imm = t.extend_immediate();

    // Assign the values for coverage sampling.
    cov_reset     = t.reset;
    cov_opcode    = t.instr_f[6:0];
    cov_inst_type = t.inst_type;
    cov_imm       = imm;

    // Sample the covergroup.
    cov_inst.sample();
  endfunction

  //------------------------------------------------------------
  // Report Phase: Print coverage results at the end of simulation.
  //------------------------------------------------------------
  virtual function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    cov_inst.print();
  endfunction

endclass
