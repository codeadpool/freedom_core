`timescale 1ns / 1ps

module tb_instructionMemory;

    reg clk;
    reg read_enable;
    reg [31:0] address;

    wire [31:0] instruction_address;

    instructionMemory dut (
        .clk(clk), 
        .read_enable(read_enable), 
        .address(address), 
        .instruction_address(instruction_address)
    );

    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    initial begin

        read_enable = 0;
        address = 0;

        #100;

        // Test Case 1: Read at base address
        read_enable = 1;
        address = 32'h01000000; // Base address
        #20;
        $display("TC1: Base Address: Addr = %h, Instr = %h", address, instruction_address);

        // Test Case 2: Read at various offsets
        repeat(4) begin
            address = address + 4; // Increment address by 4
            #20;
            $display("TC2: Incremental Address: Addr = %h, Instr = %h", address, instruction_address);
        end

        // Test Case 3: Read at an address outside the memory range
        address = 32'h02000000;
        #20;
        $display("TC3: Out of Range Address: Addr = %h, Instr = %h", address, instruction_address);

        // Test Case 4: Toggle read enable
        read_enable = 0;
        address = 32'h01000004;
        #20;
        $display("TC4: Read Disable: Addr = %h, Instr = %h", address, instruction_address);
        read_enable = 1;
        #20;
        $display("TC4: Read Enable: Addr = %h, Instr = %h", address, instruction_address);

        // Test Case 5: Test byte alignment
        address = 32'h01000000 | 3; // Test with byte-aligned address
        #20;
        $display("TC5: Byte Alignment: Addr = %h, Instr = %h", address, instruction_address);

        #100;
        $finish;
    end

endmodule
