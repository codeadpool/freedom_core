`timescale 1ns / 1ps
module ALU_tb();
    
    
    reg [31:0] operand_a;
    reg [31:0] operand_b; 
    reg [31:0] result_tb;
    reg [3:0] operation_tb;
    
    wire [31:0] ALU_result;
    
    integer file_integer;
    
    alu dut(
        .operand1(operand_a),
        .operand2(operand_b),
        .operation(operation_tb),
        .result(ALU_result)
        );
    
    initial begin
        file_integer = $fopen("ALU.csv", "r"); // File_integer has a non zero integer value if it can be read
        
        if(file_integer == 0) begin
            $display("ALU.csv not found");
            $finish;
        end
    
    while(!$feof(file_integer)) begin
        $fscanf(file_integer, "%h %h %h %h\n", operand_a, operand_b, operation_tb, result_tb);
        $display("opa: %h, opb: %h, op: %h, result: %h ", operand_a, operand_b, operation_tb, result_tb);
        #5
        if(result_tb != ALU_result)begin
            $display("Failed: Expected: %h, Actual: %h", result_tb, ALU_result);
            $stop;
        end
     end
    $display("ALU working properly");
    $finish;
     
end   
endmodule

