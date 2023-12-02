`timescale 1ns / 1ps

module tb_dataMemory;

    reg clk;
    reg rst;
    reg read_enable;
    reg [3:0] write_byte_select;
    reg [3:0] read_byte_select;
    reg [31:0] address;
    reg [31:0] data_in;

    wire [31:0] data_out;
    integer i;

    dataMemory dut (
        .clk(clk),
        .rst(rst),
        .read_enable(read_enable),
        .write_byte_select(write_byte_select),
        .read_byte_select(read_byte_select),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        read_enable = 0;
        write_byte_select = 0;
        read_byte_select = 4'b1111; // Enable read for all bytes
        address = 0;
        data_in = 0;

        #50; 
        rst = 0;

        // Test Case 1: Write and Read a whole word
        write_byte_select = 4'b1111;
        data_in = 32'hA5A5A5A5;
        address = 32'h4;
        #10;
        write_byte_select = 4'b0000;
        read_enable = 1;
        #10; 
        if (data_out != 32'hA5A5A5A5) $display("Test Case 1 Failed");

        // Test Case 2: Write and Read individual bytes
        for (i = 0; i < 4; i = i + 1) begin
            write_byte_select = 4'b0001 << i;
            data_in = 32'hFF << (i*8);
            address = 32'h8;
            #10; 
        end
        write_byte_select = 4'b0000;
        read_enable = 1;
        #10; 
        if (data_out != 32'hFFFFFFFF) $display("Test Case 2 Failed");

        // Test Case 3: Special ROM handling
        address = dut.ADDR_ROM_1;
        #10; 
        if (data_out != dut.SURYA) $display("Test Case 3 Failed - ADDR_ROM_1");
        address = dut.ADDR_ROM_2;
        #10;
        if (data_out != dut.SAI) $display("Test Case 3 Failed - ADDR_ROM_2");

        // Test Case 4: Out-of-bounds address
        address = 32'hFFFFFFFF;
        #10; 
        if (data_out != 32'hDEAD_BEEF) $display("Test Case 4 Failed - Out of bounds address");
     
        #10 $display("All tests completed");
        $finish;
    end
endmodule
