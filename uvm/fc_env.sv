`include "uvm_macros.svh"

class fc_env extends uvm_env;

  // Components of the environment.
  fc_agent      agent;
  fc_scoreboard scoreboard;
  fc_coverage   coverage;

  // Constructor.
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase: Instantiate the agent, scoreboard, and coverage collector.
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent      = fc_agent::type_id::create("agent", this);
    scoreboard = fc_scoreboard::type_id::create("scoreboard", this);
    coverage   = fc_coverage::type_id::create("coverage", this);
  endfunction

  // Connect phase: Connect the monitor's analysis port to both the scoreboard and coverage.
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    agent.monitor.analysis_port.connect(scoreboard.ap);
    agent.monitor.analysis_port.connect(coverage);
  endfunction

endclass

