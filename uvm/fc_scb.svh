`include "uvm_macros.svh"

class fc_scoreboard extends uvm_scoreboard;

  // Analysis port implementation to receive fc_txn transactions.
  uvm_analysis_imp #(fc_txn, fc_scoreboard) ap;

  // Counters for statistics.
  int total_transactions;
  int error_count;
  // Associative array keyed by instruction type (enum value) to count occurrences.
  int instr_counts[int];

  //------------------------------------------------------------
  // Constructor: Initializes the scoreboard and its analysis port.
  //------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
    total_transactions = 0;
    error_count = 0;
  endfunction

  //------------------------------------------------------------
  // write: Called by the analysis port to deliver a transaction.
  // This function decodes the transaction, performs various checks,
  // updates counters, and logs the results.
  //------------------------------------------------------------
  virtual function void write(fc_txn txn);
    // Decode the instruction type.
    txn.get_instruction_type();

    // Update counters.
    total_transactions++;
    instr_counts[txn.inst_type]++;

    // Compute the immediate extension.
    bit [31:0] imm = txn.extend_immediate();

    // Check if reset is asserted. In reset state, outputs should be at default.
    if (txn.reset) begin
      if (txn.pc_f !== 32'b0 || txn.data_addr_m !== 32'b0 ||
          txn.write_data_m !== 32'b0 || txn.read_data_m !== 32'b0 ||
          txn.mem_write_m !== 1'b0 || txn.lw_stall !== 1'b0 ||
          txn.beq_flush !== 1'b0) begin
        `uvm_error("FC_SCOREBOARD", $sformatf(
          "RESET violation: When reset is asserted, output signals are not zero. Instruction = %h", txn.instr_f))
        error_count++;
      end
    end
    else begin
      // U-type instruction check: LUI and AUIPC should have the lower 12 bits of the immediate as zero.
      if ((txn.instr_f[6:0] == LUI) || (txn.instr_f[6:0] == AUIPC)) begin
        if (imm[11:0] != 12'b0) begin
          `uvm_error("FC_SCOREBOARD", $sformatf(
            "U-type immediate error: Instruction = %h, Extended Imm = %h", txn.instr_f, imm))
          error_count++;
        end
      end

      // Branch instruction check: The branch immediate must be even (LSB = 0).
      if (txn.instr_f[6:0] == BRNCH) begin
        if (imm[0] !== 1'b0) begin
          `uvm_error("FC_SCOREBOARD", $sformatf(
            "Branch immediate error: Instruction = %h, Extended Imm = %h", txn.instr_f, imm))
          error_count++;
        end
      end
    end

    // Log the received transaction.
    `uvm_info("FC_SCOREBOARD", $sformatf(
      "Txn %0d: Instruction = %h, Type = %0d, Extended Imm = %h",
      total_transactions, txn.instr_f, txn.inst_type, imm), UVM_MEDIUM);
  endfunction

  //------------------------------------------------------------
  // final_phase: At the end of the simulation, print a summary
  // of total transactions, errors, and counts per instruction type.
  //------------------------------------------------------------
  virtual function void final_phase(uvm_phase phase);
    super.final_phase(phase);
    `uvm_info("FC_SCOREBOARD", $sformatf("Final Summary: Total Transactions = %0d, Errors = %0d", 
                                           total_transactions, error_count), UVM_LOW);
    foreach (instr_counts[i]) begin
      `uvm_info("FC_SCOREBOARD", $sformatf("Instruction Type %0d Count = %0d", i, instr_counts[i]), UVM_LOW);
    end
  endfunction

endclass

