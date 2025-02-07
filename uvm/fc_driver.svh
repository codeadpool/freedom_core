`include "uvm_macros.svh"

///---------------------------------------------------------------------
/// Class: fc_driver
/// Description: UVM driver for driving fc_txn packets to the DUT.
///---------------------------------------------------------------------
class fc_driver extends uvm_driver #(fc_txn);

  // Virtual interface handle to drive DUT signals.
  virtual fc_if vif;

  //------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //------------------------------------------------------------
  // Build Phase: Retrieve the virtual interface from the config DB.
  //------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual fc_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for ", get_full_name()})
    end
  endfunction

  //------------------------------------------------------------
  // Run Phase: Get and drive transactions indefinitely.
  //------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    fc_txn txn;

    forever begin
      seq_item_port.get_next_item(txn);
      txn.get_instruction_type();
      drive_item(txn);
      seq_item_port.item_done();
    end
  endtask

  //------------------------------------------------------------
  // Task: drive_item
  // Description: Drives the transaction fields from fc_txn to the DUT.
  //------------------------------------------------------------
  virtual task drive_item(fc_txn txn);
    // Wait for a positive clock edge to synchronize.
    @(posedge vif.clk);

    // Drive the input signals of the DUT using the transaction fields.
    vif.reset         <= txn.reset;
    vif.instr_f       <= txn.instr_f;
    vif.valid         <= 1'b1; // Assert valid during driving.

    // Optionally, drive additional signals such as program counter, memory, etc.
    vif.pc_f          <= txn.pc_f;
    vif.write_data_m  <= txn.write_data_m;
    vif.data_addr_m   <= txn.data_addr_m;
    vif.read_data_m   <= txn.read_data_m;
    vif.mem_write_m   <= txn.mem_write_m;
    vif.lw_stall      <= txn.lw_stall;
    vif.beq_flush     <= txn.beq_flush;

    // Hold the signals for one clock cycle.
    @(posedge vif.clk);

    // De-assert the valid signal after the transaction is driven.
    vif.valid <= 1'b0;
  endtask

endclass

