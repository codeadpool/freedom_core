`timescale 1ns / 1ps

module tb_dataMemory;

    reg clk;
    reg rst;
    reg readEnable;
    reg writeEnable;
    reg [3:0] writeByteSelect;
    reg [3:0] readByteSelect;
    reg [2:0] loadSelect;
    reg [31:0] address;
    reg [31:0] dataIn;
    wire [31:0] dataOut;

    dataMemory dut (
        .clk(clk),
        .rst(rst),
        .readEnable(readEnable),
        .writeEnable(writeEnable),
        .writeByteSelect(writeByteSelect),
        .readByteSelect(readByteSelect),
        .loadSelect(loadSelect),
        .address(address),
        .dataIn(dataIn),
        .dataOut(dataOut)
    );

    always #5 clk = ~clk;
    always @(posedge clk) begin
        if (writeEnable) begin
            #1; 
            $display("Time: %t, Address: %h, Data Written: %h, Memory Content: %h",
                      $time, address, dataIn, dut.dataMemory[(address - dut.BASE_ADDR) >> 2]);
        end
    end

    initial begin

        clk = 0;
        rst = 1;
        readEnable = 0;
        writeEnable = 0;
        writeByteSelect = 4'b1111;
        readByteSelect = 4'b1111;
        loadSelect = 3'b000;
        address = 0;
        dataIn = 0;

        // Reset the system
        #10 rst = 0;
        #5;

        // Test Case 1: Write and Read Full Word
        writeEnable = 1;
        address = 32'h80000004;
        dataIn = 32'hA5A5A5A5;
        #10;
        writeEnable = 0;
        readEnable = 1;
        #10;
        readEnable = 0;
        #10;

        // Test Case 2: Byte-wise Write and Read
        // Ensure that each operation happens on a positive edge of clk
        writeEnable = 1;
        writeByteSelect = 4'b0011; // Writing to lower two bytes
        address = 32'h80000008;
        dataIn = 32'h0000FFFF;
        
        #10
        writeByteSelect = 4'b1100; // Writing to upper two bytes
        dataIn = 32'hFFFF0000;
        
        #10
        writeEnable = 0;
        readEnable = 1; 
        
        #10
        readEnable = 0;
        
        #10
        readEnable =1;
        readByteSelect = 4'b1100;
        #10
        readByteSelect = 4'b1000;
        #10
        readByteSelect = 4'b0100;
        #10
        readByteSelect = 4'b0001;
        #10
        readByteSelect = 4'b0000;
        #30        
        $finish;
    end

endmodule
