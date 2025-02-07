`include "uvm_macros.svh"

class fc_monitor extends uvm_monitor;

  // Virtual interface handle to access DUT signals.
  virtual fc_if vif;

  // Analysis port to forward captured transactions.
  uvm_analysis_port #(fc_txn) analysis_port;

  //------------------------------------------------------------
  // Constructor: Create the monitor and its analysis port.
  //------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction

  //------------------------------------------------------------
  // Build Phase: Retrieve the virtual interface from the configuration DB.
  //------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fc_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface not set for ", get_full_name()});
    end
  endfunction

  //------------------------------------------------------------
  // Run Phase: Continuously monitor the DUT signals and capture transactions.
  //------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    fc_txn txn;
    forever begin
      @(posedge vif.clk);
      if (vif.valid) begin
        // Create a new transaction and sample DUT signals.
        txn = fc_txn::type_id::create("txn", this);
        txn.reset         = vif.reset;
        txn.instr_f       = vif.instr_f;
        txn.pc_f          = vif.pc_f;
        txn.write_data_m  = vif.write_data_m;
        txn.data_addr_m   = vif.data_addr_m;
        txn.read_data_m   = vif.read_data_m;
        txn.mem_write_m   = vif.mem_write_m;
        txn.lw_stall      = vif.lw_stall;
        txn.beq_flush     = vif.beq_flush;

        // Optionally, decode the instruction type using the transaction's helper.
        txn.get_instruction_type();

        // Send the transaction to the analysis port.
        analysis_port.write(txn);
      end
    end
  endtask

endclass

