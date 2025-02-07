`include "uvm_macros.svh"

class fc_agent extends uvm_agent;

  // Components of the agent.
  uvm_sequencer #(fc_txn) sequencer;
  fc_driver               driver;
  fc_monitor              monitor;

  // Constructor.
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Instantiate sequencer, driver, and monitor.
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sequencer = uvm_sequencer#(fc_txn)::type_id::create("sequencer", this);
    driver    = fc_driver::type_id::create("driver", this);
    monitor   = fc_monitor::type_id::create("monitor", this);
  endfunction

  // Connect phase: Connect the sequencer to the driver's sequencer export.
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass

