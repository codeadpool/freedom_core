`timescale 1ns / 1ps
module tb_processorWrapper;
    reg clk, rst;
    reg [15:0] sw;
    wire [15:0] leds;
    reg [63:0] plainText;
    reg [63:0] cipherText;
    reg [4:0] factorialOf;
    
    processorWrapper DUT(
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .leds(leds)
    );   
    
    always #5 clk = ~clk;
    
    initial begin    
        clk = 0;
        rst = 1;
        #10 rst = 0;  
//        #10 synthesisFactorial();     
//        #10 factorial();
//        #10 rc5();
        #10 rc5Decrypt();
        
    end
    
    //  ************************        TEST TASKS      ************************   
     
    task everyInstruction();
        begin
        $readmemh("defaultInstructionSet.mem", DUT.imem.memory_array);
        $readmemh("defaultDMemSet.mem",DUT.dmem.dataMemory);
        end
    endtask
    
    task rc5();
        begin
            $readmemh("rc5InstructionSet.mem", DUT.imem.memory_array);
            $readmemh("rc5DMemSet.mem",DUT.dmem.dataMemory);
            
//            plainText = 64'h01010101_01010101;
            plainText = 64'h00000000_00000000;
            DUT.rf.cpu_registers[1] = plainText[63:32];
            DUT.rf.cpu_registers[2] = plainText[31:0];
           
            while (DUT.cm.cstate != 4'b1110) begin
                @(posedge clk);
            end
            
            $display("**********        RESULT      **********");      
            $display("plainText: %h",plainText);
            $display("cipherText: %h", {DUT.rf.cpu_registers[1],DUT.rf.cpu_registers[2]});
            
            $stop;
        end
    endtask
    
    task rc5Decrypt();
        begin
            $readmemh("rc5Decrypt.mem", DUT.imem.memory_array);
            $readmemh("rc5DMemSet.mem",DUT.dmem.dataMemory);
            
//            cipherText = 64'hca8f6958_6d786f53;
            cipherText = 64'ha2b568ba_c7edc2c1;
            DUT.rf.cpu_registers[1] = cipherText[63:32];
            DUT.rf.cpu_registers[2] = cipherText[31:0];
            
            while (DUT.cm.cstate != 4'b1110) begin
                @(posedge clk);
            end
            
            $display("**********        RESULT      **********");
            $display("cipherText: %h", cipherText);      
            $display("plainText: %h",{DUT.rf.cpu_registers[1],DUT.rf.cpu_registers[2]});
            
            $stop;
        end
    endtask
    
    task factorial();
        begin
            $readmemh("factorialInstructionSet.mem", DUT.imem.memory_array);
            $readmemh("defaultDMemSet.mem", DUT.dmem.dataMemory);
            
            factorialOf = 12; // 0 to 12, 13 goes out of 32 
            DUT.rf.cpu_registers[5] = factorialOf;
            
            while (DUT.cm.cstate != 4'b1110) begin
                    @(posedge clk);
                end
                
            $display("**********        RESULT      **********");     
            $display("factorial of %d is: %d", factorialOf, DUT.rf.cpu_registers[6]);
                
            $stop;
        end
    endtask
    
    task synthesisFactorial();
        begin
            DUT.dmem.switches = 16'h0005;
            while (DUT.cm.cstate != 4'b1110) begin
                    @(posedge clk);
                end
            $display("factorial of 5 is: %d", DUT.rf.cpu_registers[6]);
            $stop;
        end
    endtask

endmodule
