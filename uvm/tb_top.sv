// tb_top.sv
`timescale 1ns/1ps
import fc_pkg::*; // Import the package that contains UVM components, sequences, and tests.

module tb_top;

  // Instantiate a clock and reset.
  bit clk;
  bit rst;

  // Instantiate the interface.
  fc_if fc_vif (clk, rst);

  // Dummy DUT instantiation (replace with your actual DUT as needed).
  freedom_core dut (
    .clk         (fc_vif.clk),
    .rst         (rst),
    .instr_f     (fc_vif.instr_f),
    .valid       (fc_vif.valid),
    .pc_f        (fc_vif.pc_f),
    .write_data_m(fc_vif.write_data_m),
    .data_addr_m (fc_vif.data_addr_m),
    .read_data_m (fc_vif.read_data_m),
    .mem_write_m (fc_vif.mem_write_m),
    .lw_stall    (fc_vif.lw_stall),
    .beq_flush   (fc_vif.beq_flush)
  );

  // Clock generator.
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10 ns clock period.
  end

  // Reset generator.
  initial begin
    rst = 1;
    #20;
    rst = 0;
  end

  // UVM configuration and test invocation.
  initial begin
    // Set the virtual interface in the UVM configuration database.
    uvm_config_db#(virtual fc_if)::set(null, "*", "vif", fc_vif);

    // Determine test name from plusargs; default to "fc_mixed_test" if not provided.
    string testname;
    if (!$value$plusargs("TEST_NAME=%s", testname))
      testname = "fc_mixed_test";
      
    // Start UVM.
    run_test(testname);
  end

endmodule
