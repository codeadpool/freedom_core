`timescale 1ns / 1ps

module tb_programCounter;

    reg clk;
    reg rst;
    reg write_enable;
    reg PCWriteCond;
    reg [1:0] PCSource;
    reg [31:0] ALUResult;
    reg [25:0] JumpTarget;
    reg ZeroFlag;

    wire [31:0] pc;
    wire halt;

    programCounter dut (
        .clk(clk),
        .rst(rst),
        .write_enable(write_enable),
        .PCWriteCond(PCWriteCond),
        .PCSource(PCSource),
        .ALUResult(ALUResult),
        .JumpTarget(JumpTarget),
        .ZeroFlag(ZeroFlag),
        .pc(pc),
        .halt(halt)
    );

    always #5 clk = ~clk;

    initial begin

        clk = 0;
        rst = 1;
        write_enable = 0;
        PCWriteCond = 0;
        PCSource = 2'b0;
        ALUResult = 0;
        JumpTarget = 0;
        ZeroFlag = 0;

        #20;
        rst = 0;
        write_enable =1;

        // Test Case 1: Standard increment of PC
        #10 if (pc !== 32'h01000004) $display("Test Case 1 Failed: PC did not increment correctly");

        // Test Case 2: Conditional write to PC with ZeroFlag
        PCWriteCond = 1;
        ZeroFlag = 1;
        PCSource = 2'b01;
        ALUResult = 32'h01000010; // Some branch address
        #10 if (pc !== 32'h01000010) $display("Test Case 2 Failed: Conditional write to PC failed");

        // Test Case 3: Jump instruction
        PCWriteCond = 0;
        write_enable = 1;
        PCSource = 2'b10;
        JumpTarget = 26'h000004; // Some jump address
        #10;
        if (pc !== 32'h01000010) $display("Test Case 3 Failed: Jump instruction failed");

        // Test Case 4: Out of bounds address
        ALUResult = 32'h02000000; // Address out of range
        PCSource = 2'b01;
        #10;
        if (halt !== 1) $display("Test Case 4 Failed: Out of bounds address not detected");

        // Test Case 5: Unaligned address
        ALUResult = 32'h01000003; // Unaligned address
        #10;
        if (halt !== 1) $display("Test Case 5 Failed: Unaligned address not detected");

        $display("All test cases completed.");
        $finish;
    end

endmodule
