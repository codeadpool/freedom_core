// FOR LOOP PROBLEM NEED TO CHECK

//        ALUOp = 2'b10;
//        for (funct3 = 0; funct3 <= 3'b111; funct3 = funct3 + 1) begin
//            if (funct3 == 3'b000 || funct3 == 3'b101) begin
//                funct7 = 7'b0000000;  
//                set_inputs(ALUOp, funct7, funct3);  
//                check_expected_output();
        
//                funct7 = 7'b0100000;  
//                set_inputs(ALUOp, funct7, funct3);  
//                check_expected_output();
//            end else begin
//                set_inputs(ALUOp, 7'b0000000, funct3);
//                check_expected_output();
//            end
//        end


`timescale 1ns / 1ps
`include "defines.vh"

module tb_aluControl;

    reg clk;
    reg [1:0] ALUOp;
    reg [6:0] funct7;
    reg [2:0] funct3;

    wire [3:0] ALUCtrl;

    aluControl dut (
        .clk(clk),
        .ALUOp(ALUOp),
        .funct7(funct7),
        .funct3(funct3),
        .ALUCtrl(ALUCtrl)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        ALUOp = 0;
        funct7 = 0;
        funct3 = 0;
        @(posedge clk);

        // Test for ALUOp = 00 (Load/Store Instructions)
        set_inputs(2'b00, 7'b0, 3'b0);
        check_output(`ADD);

        // Test for ALUOp = 01 (Branch Instructions)
        set_inputs(2'b01, 7'b0, 3'b0);
        check_output(`SUB);

        // Test for ALUOp = 10 with different funct7 and funct3 combinations
        ALUOp = 2'b10;

        // Manually iterating through all combinations of funct3 and funct7
        test_combination(3'b000, 7'b0000000); // ADD
        test_combination(3'b000, 7'b0100000); // SUB
        test_combination(3'b001, 7'b0000000); // SLL
        test_combination(3'b010, 7'b0000000); // SLT
        test_combination(3'b011, 7'b0000000); // SLTU
        test_combination(3'b100, 7'b0000000); // XOR
        test_combination(3'b101, 7'b0000000); // SRL
        test_combination(3'b101, 7'b0100000); // SRA
        test_combination(3'b110, 7'b0000000); // OR
        test_combination(3'b111, 7'b0000000); // AND

        $display("All tests completed successfully.");
        $finish;
    end

    task set_inputs(input [1:0] aluop, input [6:0] f7, input [2:0] f3);
        begin
            @(posedge clk);
            ALUOp = aluop;
            funct7 = f7;
            funct3 = f3;
        end
    endtask

    task check_output(input [3:0] expected_output);
        begin
            @(posedge clk); 
            if (ALUCtrl !== expected_output) begin
                $display("Error: ALUOp = %b, funct7 = %b, funct3 = %b, Expected ALUCtrl = %b, Got = %b",
                      ALUOp, funct7, funct3, expected_output, ALUCtrl);
            end
        end
    endtask

    task test_combination(input [2:0] f3, input [6:0] f7);
        begin
            set_inputs(ALUOp, f7, f3);
            check_expected_output();
        end
    endtask

    task check_expected_output;
        begin
            case (funct3)
                3'b000: check_output(funct7 == 7'b0000000 ? `ADD : `SUB);
                3'b001: check_output(`SLL);
                3'b010: check_output(`SLT);
                3'b011: check_output(`SLTU);
                3'b100: check_output(`XOR);
                3'b101: check_output(funct7 == 7'b0000000 ? `SRL : `SRA);
                3'b110: check_output(`OR);
                3'b111: check_output(`AND);
                default: check_output(4'b0000);
            endcase
        end
    endtask

endmodule




