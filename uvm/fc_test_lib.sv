//-------------------------------------------------------------------------
  //-------------------------------------------------------------------------
  // Test Cases
  //-------------------------------------------------------------------------
  //-------------------------------------------------------------------------

  // fc_random_test: Runs the random sequence.
  class fc_random_test extends uvm_test;
    fc_env env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = fc_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fc_random_seq seq;
      seq = fc_random_seq::type_id::create("seq", this);
      seq.start(env.agent.sequencer);
      phase.drop_objection(this);
    endtask
  endclass


  // fc_reset_test: Runs the reset sequence.
  class fc_reset_test extends uvm_test;
    fc_env env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = fc_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fc_reset_seq seq;
      seq = fc_reset_seq::type_id::create("seq", this);
      seq.start(env.agent.sequencer);
      phase.drop_objection(this);
    endtask
  endclass


  // fc_mixed_test: Runs the mixed (reset then random) sequence.
  class fc_mixed_test extends uvm_test;
    fc_env env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = fc_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      fc_mixed_seq seq;
      seq = fc_mixed_seq::type_id::create("seq", this);
      seq.start(env.agent.sequencer);
      phase.drop_objection(this);
    endtask
  endclass

