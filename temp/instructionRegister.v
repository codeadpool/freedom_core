module instructionRegister(
    input [31:0] instruction,
    input clk, rst,
    output [4:0] rs1, rs2, rd
);
    reg [31:0] storeInstruction;  
    assign storeInstruction = instruction; 

    always@(posedge clk)
        begin
        end
endmodule

                
            
