#!/bin/bash
# run_all_tests.sh
# This script compiles the design and runs all UVM tests.

# Clean previous work library if it exists.
if [ -d work ]; then
  rm -rf work
fi

# Create a new work library.
vlib work

# Compile all source files.
vlog +acc -sv fc_if.sv fc_pkg.sv tb_top.sv

# Run fc_random_test.
echo "Running fc_random_test..."
vsim -c -do "run -all; quit" -l random_test.log +TEST_NAME=fc_random_test tb_top

# Run fc_reset_test.
echo "Running fc_reset_test..."
vsim -c -do "run -all; quit" -l reset_test.log +TEST_NAME=fc_reset_test tb_top

# Run fc_mixed_test.
echo "Running fc_mixed_test..."
vsim -c -do "run -all; quit" -l mixed_test.log +TEST_NAME=fc_mixed_test tb_top

echo "All tests completed."

