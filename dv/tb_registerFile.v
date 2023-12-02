`timescale 1ns / 1ps

module tb_registerFile;

    reg clk;
    reg reset;
    reg write_enable;
    reg [4:0] read_reg1;
    reg [4:0] read_reg2;
    reg [4:0] write_reg;
    reg [31:0] write_data;

    wire [31:0] read_data1;
    wire [31:0] read_data2;

    registerFile dut (
        .clk(clk), 
        .reset(reset), 
        .write_enable(write_enable), 
        .read_reg1(read_reg1), 
        .read_reg2(read_reg2), 
        .write_reg(write_reg), 
        .write_data(write_data), 
        .read_data1(read_data1), 
        .read_data2(read_data2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        reset = 1;
        write_enable = 0;
        read_reg1 = 0;
        read_reg2 = 0;
        write_reg = 0;
        write_data = 0;

        #100;
        reset = 0;

        // Test case 1: Write and read from a register
        write_enable = 1;
        write_reg = 5;
        write_data = 32'hA5A5A5A5;
        #10;
        write_enable = 0;
        read_reg1 = 5;
        #10;
        if (read_data1 !== 32'hA5A5A5A5) $display("Test case 1 failed: Expected %h, got %h", 32'hA5A5A5A5, read_data1);

        // Test case 2: Reset and check if registers are cleared
        reset = 1;
        #20;
        reset = 0;
        read_reg1 = 5;
        #10;
        if (read_data1 !== 0) $display("Test case 2 failed: Expected 0, got %h", read_data1);

        // Test case 3: Attempt to write to register 0 and read from it
        write_enable = 1;
        write_reg = 0;
        write_data = 32'hDEADBEEF;
        #10;
        write_enable = 0;
        read_reg1 = 0;
        read_reg2 = 5;
        #10;
        if (read_data1 !== 0) $display("Test case 3 failed: Expected 0 for read_data1, got %h", read_data1);

        // Test case 4: Write and read from multiple registers
        write_enable = 1;
        write_reg = 3;
        write_data = 32'h12345678;
        #10;
        write_reg = 4;
        write_data = 32'h87654321;
        #10;
        write_enable = 0;
        read_reg1 = 3;
        read_reg2 = 4;
        #10;
        if (read_data1 !== 32'h12345678) $display("Test case 4 failed: Expected %h for read_data1, got %h", 32'h12345678, read_data1);
        if (read_data2 !== 32'h87654321) $display("Test case 4 failed: Expected %h for read_data2, got %h", 32'h87654321, read_data2);

        // Test case 5: Check non-write operation with write_enable off
        write_reg = 10;
        write_data = 32'hAAAA5555;
        #10;
        read_reg1 = 10;
        #10;
        if (read_data1 !== 0) $display("Test case 5 failed: Expected 0 for read_data1, got %h", read_data1);
        $finish;
    end
      
endmodule
