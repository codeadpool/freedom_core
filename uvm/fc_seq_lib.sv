  //-------------------------------------------------------------------------
  //-------------------------------------------------------------------------
  // Sequences
  //-------------------------------------------------------------------------
  //-------------------------------------------------------------------------

  // fc_random_seq: Generates a series of random fc_txn transactions.
  class fc_random_seq extends uvm_sequence #(fc_txn);
    function new(string name = "fc_random_seq");
      super.new(name);
    endfunction

    virtual task body();
      fc_txn txn;
      // Generate 20 random transactions.
      for (int i = 0; i < 20; i++) begin
         txn = fc_txn::type_id::create("txn", this);
         if (!txn.randomize()) begin
            `uvm_error("FC_RANDOM_SEQ", "Randomization failed for fc_txn item");
         end
         start_item(txn);
         finish_item(txn);
         #10; // Optional delay between transactions.
      end
    endtask
  endclass


  // fc_reset_seq: Generates a reset transaction.
  class fc_reset_seq extends uvm_sequence #(fc_txn);
    function new(string name = "fc_reset_seq");
      super.new(name);
    endfunction

    virtual task body();
      fc_txn txn;
      txn = fc_txn::type_id::create("reset_txn", this);
      txn.reset_item(); // Force reset defaults.
      start_item(txn);
      finish_item(txn);
      #20;
    endtask
  endclass


  // fc_mixed_seq: Sends a reset transaction followed by random transactions.
  class fc_mixed_seq extends uvm_sequence #(fc_txn);
    function new(string name = "fc_mixed_seq");
      super.new(name);
    endfunction

    virtual task body();
      fc_txn txn;
      // Issue a reset transaction.
      txn = fc_txn::type_id::create("reset_txn", this);
      txn.reset_item();
      start_item(txn);
      finish_item(txn);
      #20;
      // Issue 30 random transactions.
      for (int i = 0; i < 30; i++) begin
         txn = fc_txn::type_id::create("txn", this);
         if (!txn.randomize()) begin
            `uvm_error("FC_MIXED_SEQ", "Randomization failed for fc_txn item");
         end
         start_item(txn);
         finish_item(txn);
         #10;
      end
    endtask
  endclass

